import Foundation
import Combine

@MainActor
final class CardGameViewModel: ObservableObject {
    @Published var playerScore: Int = 0
    @Published var computerScore: Int = 0
    @Published var playerCard: String = "back"
    @Published var computerCard: String = "back"
    @Published var isPlayerFlipped: Bool = false
    @Published var isComputerFlipped: Bool = false
    
    private var lastPlayerValue: Int = 0
    private var lastComputerValue: Int = 0
    
    func dealFacesOnly() {
        lastPlayerValue = Int.random(in: 2...14)
        lastComputerValue = Int.random(in: 2...14)
        playerCard = "card\(lastPlayerValue)"
        computerCard = "card\(lastComputerValue)"
    }
    
    func updateScoreFromLastDeal() {
        if lastPlayerValue > lastComputerValue {
            playerScore += 1
        } else if lastComputerValue > lastPlayerValue {
            computerScore += 1
        }
    }
    
    func deal() {
        dealFacesOnly()
        updateScoreFromLastDeal()
    }
}
