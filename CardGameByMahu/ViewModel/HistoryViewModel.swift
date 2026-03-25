import Foundation
import SwiftUI

final class HistoryViewModel {
    struct RowViewData: Identifiable {
        let id: UUID
        let playerCard: String
        let computerCard: String
        let resultTitle: String
        let resultSystemImage: String
        let resultColor: Color
        let borderColor: Color
        let isHardcoreMode: Bool
        let pills: [ChancePillViewData]
    }

    struct ChancePillViewData: Identifiable {
        let id: String
        let title: String
        let text: String
        let isEmphasized: Bool
        let foregroundColor: Color
        let backgroundColor: Color
    }

    func rows(from rounds: [RoundHistoryItem]) -> [RowViewData] {
        rounds.map { round in
            let isCorrect = round.wasCorrect
            let playerChoice = round.playerChoiceOption
            let correctAnswer = round.correctAnswerOption

            return RowViewData(
                id: round.id,
                playerCard: round.playerCard,
                computerCard: round.computerCard,
                resultTitle: isCorrect ? "Correct" : "Wrong",
                resultSystemImage: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill",
                resultColor: isCorrect ? .green : .red,
                borderColor: isCorrect ? Color.green.opacity(0.6) : Color.red.opacity(0.5),
                isHardcoreMode: round.isHardcoreMode,
                pills: [
                    makePill(option: .lower, value: round.lowerChance, playerChoice: playerChoice, correctAnswer: correctAnswer),
                    makePill(option: .equal, value: round.equalChance, playerChoice: playerChoice, correctAnswer: correctAnswer),
                    makePill(option: .higher, value: round.higherChance, playerChoice: playerChoice, correctAnswer: correctAnswer)
                ]
            )
        }
    }

    private func makePill(option: GuessOption, value: Double, playerChoice: GuessOption?, correctAnswer: GuessOption?) -> ChancePillViewData {
        let isEmphasized = playerChoice == option
        let isCorrectAnswer = correctAnswer == option
        let percent = Int((value * 100).rounded())
        let title = option.displayText

        return ChancePillViewData(
            id: option.rawValue,
            title: title,
            text: "\(title): \(percent)%",
            isEmphasized: isEmphasized,
            foregroundColor: isEmphasized ? .white : .primary,
            backgroundColor: isEmphasized
                ? (isCorrectAnswer ? .green : .red)
                : Color.gray.opacity(0.2)
        )
    }
}
