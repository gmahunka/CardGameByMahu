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

            return RowViewData(
                id: round.id,
                playerCard: round.playerCard,
                computerCard: round.computerCard,
                resultTitle: isCorrect ? "Correct" : "Wrong",
                resultSystemImage: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill",
                resultColor: isCorrect ? .green : .red,
                borderColor: isCorrect ? Color.green.opacity(0.6) : Color.red.opacity(0.5),
                pills: [
                    makePill(title: "Lower", value: round.lowerChance, playerChoice: round.playerChoice, correctAnswer: round.correctAnswer),
                    makePill(title: "Equal", value: round.equalChance, playerChoice: round.playerChoice, correctAnswer: round.correctAnswer),
                    makePill(title: "Higher", value: round.higherChance, playerChoice: round.playerChoice, correctAnswer: round.correctAnswer)
                ]
            )
        }
    }

    private func makePill(title: String, value: Double, playerChoice: String, correctAnswer: String) -> ChancePillViewData {
        let isEmphasized = playerChoice == title
        let isCorrectAnswer = correctAnswer == title
        let percent = Int((value * 100).rounded())

        return ChancePillViewData(
            id: title,
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
