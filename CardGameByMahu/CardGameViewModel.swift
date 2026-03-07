import Foundation
import Combine

enum Guess {
    case higher
    case equal
    case lower
}

@MainActor
final class CardGameViewModel: ObservableObject {
    @Published var playerScore: Int = 0
    @Published var computerScore: Int = 0
    @Published var playerCard: String = "back"
    @Published var computerCard: String = "back"
    @Published var isPlayerFlipped: Bool = false
    @Published var isComputerFlipped: Bool = false
    @Published var waitingForGuess: Bool = false
    
    private var computerValue: Int = 0
    private var playerValue: Int = 0
    
    // Start a new round - computer draws a card
    func startRound() {
        computerValue = Int.random(in: 2...14)
        computerCard = "card\(computerValue)"
        playerCard = "back"
        waitingForGuess = true
    }
    
    // Player makes a guess
    func makeGuess(_ guess: Guess) {
        guard waitingForGuess else { return }
        
        // Draw player's card
        playerValue = Int.random(in: 2...14)
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
        } else {
            computerScore += 1
        }
        
        waitingForGuess = false
    }
}
