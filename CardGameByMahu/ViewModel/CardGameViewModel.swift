//
//  CardGameViewModel.swift
//  CardGameByMahu
//
//  Created by Gergo Mahunka on 2026. 03. 07..
//
//  Purpose: Manages the application's core game state and rules for the
//  normal (non-hardcore) game mode. Responsibilities include deck and
//  score management, round flow (draw, guess resolution), and bridging to
//  the hardcore engine when that mode is started. Keep comments concise —
//  the implementation should remain authoritative for behavior.

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

/// ViewModel coordinating game state for normal gameplay and delegating
/// hardcore-mode behavior to `HardCoreGameViewModel` when enabled.
///
/// - Note: Use `setupGame(context:)` to attach a `ModelContext` before
///   invoking gameplay methods that access persistent models.
@Observable
@MainActor
final class CardGameViewModel {
    
    private let deckSettings: DeckSettings
    private let hardCoreGameViewModel: HardCoreGameViewModel
    
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
    
    /// Create a new view model using the provided `DeckSettings`.
    /// - Parameter deckSettings: Configuration describing how many copies
    ///   of each card value exist in the deck.
    init(deckSettings: DeckSettings) {
        self.deckSettings = deckSettings
        self.hardCoreGameViewModel = HardCoreGameViewModel(deckSettings: deckSettings)
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
    
    // Forwarded from hardcore engine for backward compatibility
    var isHardcoreMode: Bool {
        get { hardCoreGameViewModel.isHardcoreMode }
        set {
            if newValue && !hardCoreGameViewModel.isHardcoreMode {
                // Starting hardcore mode
                startHardcoreMode()
            } else if !newValue && hardCoreGameViewModel.isHardcoreMode {
                // Allows dismissal of the sheet
                quitHardcoreMode()
            }
        }
    }
    var hardcoreElapsedTime: Double {
        get { hardCoreGameViewModel.elapsedTime }
    }
    var hardcoreOptimalGuessCount: Int {
        get { hardCoreGameViewModel.optimalGuessCount }
    }
    var hardcoreGuessCount: Int {
        get { hardCoreGameViewModel.guessCount }
    }
    
    private var computerValue: Int = 0
    private var playerValue: Int = 0
    private var scoreRecord: GameScore?
    
    var modelContext: ModelContext?
    
    func setupGame(context: ModelContext) {
        self.modelContext = context
        hardCoreGameViewModel.setModelContext(context)
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

        try? context.delete(model: PlayingCard.self)

        for value in DeckSettings.minCardValue...DeckSettings.maxCardValue {
            let count = deckSettings.count(for: value)
            guard count > 0 else { continue }
            for _ in 0..<count {
                context.insert(PlayingCard(value: value))
            }
        }

        playerScore = 0
        computerScore = 0
        scoreRecord?.playerScore = playerScore
        scoreRecord?.computerScore = computerScore

        try? context.save()
        updateCardCount()

        computerCard = "back"
        playerCard = "back"
        waitingForGuess = false

        try? context.delete(model: RoundHistoryItem.self)
        try? context.save()
    }
    
    /// Draw a random card from the persistent deck and remove it.
    /// - Returns: The drawn card's integer value, or `nil` if the deck is empty.
    /// - Important: This mutates persistent state via `ModelContext`.
    private func drawCard() -> Int? {
        guard let context = modelContext else { return nil }
        
        // Fetch all remaining cards
        let descriptor = FetchDescriptor<PlayingCard>()
        guard let remainingCards = try? context.fetch(descriptor), !remainingCards.isEmpty else {
            return nil // Deck is empty!
        }
        
        // Pick a random card, get its value, and delete it from the deck
        guard let drawnCard = remainingCards.randomElement() else {
            return nil
        }
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
    
    /// Resolve the player's `guess` against a newly drawn player card.
    /// Updates scores, records the round to history, and forwards
    /// hardcore-related bookkeeping to the hardcore view model when active.
    /// - Parameter guess: The player's guessed relation between cards.
    func makeGuess(_ guess: Guess) {
        guard waitingForGuess else { return }

        let chances = calculateChances(for: computerValue)
        let optimalChoices = optimalScenarios(from: chances)

        guard let newCardValue = drawCard() else { return }

        playerValue = newCardValue
        playerCard = "card\(playerValue)"

        let playerChoiceOption = guess.option
        let correctAnswerOption = correctAnswerOption(computer: computerValue, player: playerValue)
        let guessCorrect = playerChoiceOption == correctAnswerOption

        let round = RoundHistoryItem(
            computerCard: "card\(computerValue)",
            playerCard: "card\(playerValue)",
            playerChoiceOption: playerChoiceOption,
            correctAnswerOption: correctAnswerOption,
            wasCorrect: guessCorrect,
            higherChance: chances.higher,
            equalChance: chances.equal,
            lowerChance: chances.lower,
            isHardcoreMode: isHardcoreMode
        )
        modelContext?.insert(round)

        if guessCorrect {
            playerScore += 1
            scoreRecord?.playerScore = playerScore
        } else {
            computerScore += 1
            scoreRecord?.computerScore = computerScore
        }

        if isHardcoreMode {
            hardCoreGameViewModel.recordGuess(isOptimal: optimalChoices.contains(playerChoiceOption))
            if remainingCards < 2 {
                hardCoreGameViewModel.stopTimerWhenRunExhausted()
            }
        }

        try? modelContext?.save()
        waitingForGuess = false
    }
    
    private func optimalScenarios(from chances: (higher: Double, equal: Double, lower: Double)) -> Set<GuessOption> {
        let ranked: [(GuessOption, Double)] = [
            (.higher, chances.higher),
            (.equal, chances.equal),
            (.lower, chances.lower)
        ]
        
        guard let maxValue = ranked.map(\.1).max() else { return [] }
        return Set(ranked.filter { $0.1 == maxValue }.map(\.0))
    }
    
    private func correctAnswerOption(computer: Int, player: Int) -> GuessOption {
        if player > computer { return .higher }
        if player < computer { return .lower }
        return .equal
    }
    
    /// Calculate probabilistic chances for higher/equal/lower given the
    /// current remaining cards in the deck.
    /// - Parameter computer: The value of the computer's revealed card.
    /// - Returns: Tuple of probabilities (higher, equal, lower) in the range 0...1.
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
    
    func startHardcoreMode() {
        guard let context = modelContext else { return }

        // Save normal-mode progress once before hardcore replaces deck state.
        if normalModeSnapshot == nil {
            let descriptor = FetchDescriptor<PlayingCard>()
            let normalCards = (try? context.fetch(descriptor)) ?? []
            normalModeSnapshot = NormalModeSnapshot(
                cardValues: normalCards.map(\.value),
                playerScore: playerScore,
                computerScore: computerScore,
                remainingCards: remainingCards,
                playerCard: playerCard,
                computerCard: computerCard,
                waitingForGuess: waitingForGuess
            )
        }

        // Start hardcore engine
        hardCoreGameViewModel.start(with: context, playerScoreRecord: scoreRecord)
        
        // Reset UI state
        playerScore = 0
        computerScore = 0
        computerCard = "back"
        playerCard = "back"
        waitingForGuess = false

        try? context.save()
        updateCardCount()
    }

    func quitHardcoreMode() {
        hardCoreGameViewModel.quit()
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
        _ = hardCoreGameViewModel.finish(playerScore: playerScore)
        quitHardcoreMode()
    }
    
    var hardcoreAccuracyPercent: Double {
        hardCoreGameViewModel.accuracyPercent
    }
    
}
