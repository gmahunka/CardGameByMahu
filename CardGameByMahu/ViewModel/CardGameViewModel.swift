//
//  CardGameViewModel.swift
//  CardGameByMahu
//
//  Created by Gergo Mahunka on 2026. 03. 07..
//

import Foundation
import Combine
import SwiftData
import Observation

enum Guess {
    case higher
    case equal
    case lower

    var option: GuessOption {
        switch self {
        case .higher: return .higher
        case .equal: return .equal
        case .lower: return .lower
        }
    }
}

@Observable
@MainActor
final class CardGameViewModel {
    
    private let deckSettings: DeckSettings

    // Stores normal-mode in-progress state while hardcore temporarily owns the deck.
    private var normalModeSnapshot: NormalModeSnapshot?

    private struct NormalModeSnapshot {
        let cardValues: [Int]
        let playerScore: Int
        let computerScore: Int
        let remainingCards: Int
        let playerCard: String
        let computerCard: String
        let waitingForGuess: Bool
    }

    init(deckSettings: DeckSettings) {
        self.deckSettings = deckSettings
    }

    var playerScore: Int = 0
    var computerScore: Int = 0
    var remainingCards: Int = 0
    var playerCard: String = "back"
    var computerCard: String = "back"
    var isPlayerFlipped: Bool = false
    var isComputerFlipped: Bool = false
    var showReshuffleAlert: Bool = false
    var waitingForGuess: Bool = false
    var isHardcoreMode: Bool = false
    var hardcoreElapsedTime: Double = 0
    var hardcoreOptimalGuessCount: Int = 0
    var hardcoreGuessCount: Int = 0

    private var computerValue: Int = 0
    private var playerValue: Int = 0
    private var scoreRecord: GameScore?
    private var hardcoreTimer: Timer?
    private var hardcoreStartDate: Date?
    
    var modelContext: ModelContext?
    
    func setupGame(context: ModelContext) {
        self.modelContext = context
        loadScores()
        
        // Move the "is the deck empty?" check here
        let descriptor = FetchDescriptor<PlayingCard>()
        let cardCount = (try? context.fetchCount(descriptor)) ?? 0
        if cardCount == 0 {
            resetDeck()
        } else {
            updateCardCount()
        }
    }
    
    // MARK: - Score Management
    func loadScores() {
        guard let context = modelContext else { return }
        let descriptor = FetchDescriptor<GameScore>()
        
        // Try to find an existing score record
        if let existingRecord = (try? context.fetch(descriptor))?.first {
            scoreRecord = existingRecord
            playerScore = existingRecord.playerScore
            computerScore = existingRecord.computerScore
        } else {
            // If no record exists (first time playing), create one
            let newRecord = GameScore(playerScore: 0, computerScore: 0)
            context.insert(newRecord)
            scoreRecord = newRecord
            playerScore = 0
            computerScore = 0
            try? context.save()
        }
    }
    
    // MARK: - Deck Management
    func updateCardCount() {
        guard let context = modelContext else { return }
        let descriptor = FetchDescriptor<PlayingCard>()
        remainingCards = (try? context.fetchCount(descriptor)) ?? 0
    }
    
    func resetDeck() {
        guard let context = modelContext else { return }
        
        // 1. Clear out any existing cards in the database
        try? context.delete(model: PlayingCard.self)
        
        // 2. Build the deck from current setup configuration
        for value in DeckSettings.minCardValue...DeckSettings.maxCardValue {
            let count = deckSettings.count(for: value)
            guard count > 0 else { continue }
            for _ in 0..<count {
                let newCard = PlayingCard(value: value)
                context.insert(newCard)
            }
        }
        
        // Save the fresh deck
        playerScore = 0
        computerScore = 0
        scoreRecord?.playerScore = playerScore
        scoreRecord?.computerScore = computerScore
        
        try? context.save()
        updateCardCount()
        
        
        
        computerCard = "back"
        playerCard = "back"
        waitingForGuess = false

        // Reshuffle starts a new game session, so clear persisted round history.
        try? context.delete(model: RoundHistoryItem.self)
        try? context.save()
    }
    
    private func drawCard() -> Int? {
        guard let context = modelContext else { return nil }
        
        // Fetch all remaining cards
        let descriptor = FetchDescriptor<PlayingCard>()
        guard let remainingCards = try? context.fetch(descriptor), !remainingCards.isEmpty else {
            return nil // Deck is empty!
        }
        
        // Pick a random card, get its value, and delete it from the deck
        let drawnCard = remainingCards.randomElement()!
        let cardValue = drawnCard.value
        context.delete(drawnCard)
        
        try? context.save()
        updateCardCount()
        
        return cardValue
    }
    
    // MARK: - Game Logic
    func startRound() {
        // Draw a card for the computer. If the deck is empty, reset it.
        guard let newCardValue = drawCard() else {
            resetDeck()
            startRound() // Try again with the fresh deck
            return
        }
        
        computerValue = newCardValue
        computerCard = "card\(computerValue)"
        playerCard = "back"
        waitingForGuess = true
    }
    
    func makeGuess(_ guess: Guess) {
        guard waitingForGuess else { return }

        let chances = calculateChances(for: computerValue)
        let likelyScenario = mostLikelyScenario(from: chances)

        // Draw player's card
        guard let newCardValue = drawCard() else {
            // Handle empty deck mid-round if necessary
            return
        }

        playerValue = newCardValue
        playerCard = "card\(playerValue)"

        let playerChoiceOption = guess.option
        let correctAnswerOption = correctAnswerOption(computer: computerValue, player: playerValue)

        // Determine if guess was correct using stable values
        let guessCorrect = playerChoiceOption == correctAnswerOption

        let round = RoundHistoryItem(
            computerCard: "card\(computerValue)",
            playerCard: "card\(playerValue)",
            playerChoiceOption: playerChoiceOption,
            correctAnswerOption: correctAnswerOption,
            wasCorrect: guessCorrect,
            higherChance: chances.higher,
            equalChance: chances.equal,
            lowerChance: chances.lower
        )
        modelContext?.insert(round)

        // Award point
        if guessCorrect {
            playerScore += 1
            scoreRecord?.playerScore = playerScore
        } else {
            computerScore += 1
            scoreRecord?.computerScore = computerScore
        }

        if isHardcoreMode {
            hardcoreGuessCount += 1
            if likelyScenario == playerChoiceOption {
                hardcoreOptimalGuessCount += 1
            }
        }

        try? modelContext?.save()
        waitingForGuess = false

        if isHardcoreMode && remainingCards < 2 {
            finishHardcoreMode()
        }
    }

    private func correctAnswerOption(computer: Int, player: Int) -> GuessOption {
        if player > computer { return .higher }
        if player < computer { return .lower }
        return .equal
    }

    private func calculateChances(for computer: Int) -> (higher: Double, equal: Double, lower: Double) {
        guard let context = modelContext else {
            return (higher: 0, equal: 0, lower: 0)
        }

        let descriptor = FetchDescriptor<PlayingCard>()
        guard let cards = try? context.fetch(descriptor), !cards.isEmpty else {
            return (higher: 0, equal: 0, lower: 0)
        }

        let total = Double(cards.count)
        let higher = Double(cards.filter { $0.value > computer }.count) / total
        let equal = Double(cards.filter { $0.value == computer }.count) / total
        let lower = Double(cards.filter { $0.value < computer }.count) / total

        return (higher: higher, equal: equal, lower: lower)
    }

    private func mostLikelyScenario(from chances: (higher: Double, equal: Double, lower: Double)) -> GuessOption {
        let ranked: [(GuessOption, Double)] = [
            (.higher, chances.higher),
            (.equal, chances.equal),
            (.lower, chances.lower)
        ]

        // Stable tie break keeps leaderboard outcomes deterministic.
        return ranked.max { lhs, rhs in
            if lhs.1 == rhs.1 {
                return tieBreakOrder(lhs.0) > tieBreakOrder(rhs.0)
            }
            return lhs.1 < rhs.1
        }?.0 ?? .equal
    }

    private func tieBreakOrder(_ option: GuessOption) -> Int {
        switch option {
        case .higher: return 3
        case .equal: return 2
        case .lower: return 1
        }
    }

    func startHardcoreMode() {
        guard let context = modelContext else { return }

        // Save normal-mode progress once before hardcore replaces deck state.
        if normalModeSnapshot == nil {
            let descriptor = FetchDescriptor<PlayingCard>()
            let normalCards = (try? context.fetch(descriptor)) ?? []
            normalModeSnapshot = NormalModeSnapshot(
                cardValues: normalCards.map(\ .value),
                playerScore: playerScore,
                computerScore: computerScore,
                remainingCards: remainingCards,
                playerCard: playerCard,
                computerCard: computerCard,
                waitingForGuess: waitingForGuess
            )
        }

        stopHardcoreTimer()

        isHardcoreMode = true
        hardcoreElapsedTime = 0
        hardcoreOptimalGuessCount = 0
        hardcoreGuessCount = 0

        // Hardcore deck is always exactly 52 cards: 4x each value from 2...14.
        try? context.delete(model: PlayingCard.self)
        for value in DeckSettings.minCardValue...DeckSettings.maxCardValue {
            for _ in 0..<4 {
                context.insert(PlayingCard(value: value))
            }
        }

        playerScore = 0
        computerScore = 0
        scoreRecord?.playerScore = 0
        scoreRecord?.computerScore = 0

        computerCard = "back"
        playerCard = "back"
        waitingForGuess = false

        try? context.save()
        updateCardCount()

        hardcoreStartDate = Date()
        hardcoreTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self, let start = self.hardcoreStartDate else { return }
            self.hardcoreElapsedTime = Date().timeIntervalSince(start)
        }
        RunLoop.main.add(hardcoreTimer!, forMode: .common)
    }

    func quitHardcoreMode() {
        stopHardcoreTimer()
        isHardcoreMode = false
        hardcoreElapsedTime = 0
        hardcoreOptimalGuessCount = 0
        hardcoreGuessCount = 0

        restoreNormalModeSnapshotIfNeeded()
    }

    private func restoreNormalModeSnapshotIfNeeded() {
        guard let context = modelContext, let snapshot = normalModeSnapshot else {
            waitingForGuess = false
            computerCard = "back"
            playerCard = "back"
            return
        }

        try? context.delete(model: PlayingCard.self)
        for value in snapshot.cardValues {
            context.insert(PlayingCard(value: value))
        }

        playerScore = snapshot.playerScore
        computerScore = snapshot.computerScore
        scoreRecord?.playerScore = snapshot.playerScore
        scoreRecord?.computerScore = snapshot.computerScore

        playerCard = snapshot.playerCard
        computerCard = snapshot.computerCard
        waitingForGuess = snapshot.waitingForGuess
        remainingCards = snapshot.remainingCards

        try? context.save()
        updateCardCount()
        normalModeSnapshot = nil
    }

    func finishHardcoreMode() {
        guard let context = modelContext, isHardcoreMode else { return }

        let accuracy = hardcoreGuessCount > 0
            ? Double(hardcoreOptimalGuessCount) / Double(hardcoreGuessCount)
            : 0

        let result = HardcoreResult(timeTaken: hardcoreElapsedTime, accuracy: accuracy)
        context.insert(result)
        try? context.save()

        quitHardcoreMode()
    }

    var hardcoreAccuracyPercent: Double {
        guard hardcoreGuessCount > 0 else { return 0 }
        return (Double(hardcoreOptimalGuessCount) / Double(hardcoreGuessCount)) * 100
    }

    private func stopHardcoreTimer() {
        hardcoreTimer?.invalidate()
        hardcoreTimer = nil
        hardcoreStartDate = nil
    }
}
