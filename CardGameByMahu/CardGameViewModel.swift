//
//  CardGameViewModel.swift
//  CardGameByMahu
//
//  Created by Gergo Mahunka on 2026. 03. 07..
//

import Foundation
import Combine
import SwiftData

enum Guess {
    case higher
    case equal
    case lower
}

@MainActor
final class CardGameViewModel: ObservableObject {
    @Published var playerScore: Int = 0
    @Published var computerScore: Int = 0
    @Published var remainingCards: Int = 0
    @Published var playerCard: String = "back"
    @Published var computerCard: String = "back"
    @Published var isPlayerFlipped: Bool = false
    @Published var isComputerFlipped: Bool = false
    @Published var showReshuffleAlert: Bool = false
    @Published var waitingForGuess: Bool = false
    
    private var computerValue: Int = 0
    private var playerValue: Int = 0
    private var scoreRecord: GameScore?
    
    // We will pass this in from the View
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
        
        // 2. Create 4 of each card (values 2 through 14)
        for value in 2...14 {
            for _ in 1...4 { // DEBUG
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
        
        // Draw player's card
        guard let newCardValue = drawCard() else {
            // Handle empty deck mid-round if necessary
            return
        }
        
        playerValue = newCardValue
        playerCard = "card\(playerValue)"
        
        // Determine if guess was correct
        let guessCorrect: Bool
        switch guess {
        case .higher:
            guessCorrect = playerValue > computerValue
        case .equal:
            guessCorrect = playerValue == computerValue
        case .lower:
            guessCorrect = playerValue < computerValue
        }
        
        // Award point
        if guessCorrect {
            playerScore += 1
            scoreRecord?.playerScore = playerScore
        } else {
            computerScore += 1
            scoreRecord?.computerScore = computerScore
        }
        
        try? modelContext?.save()
        waitingForGuess = false
    }
}
