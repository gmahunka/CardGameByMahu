import Foundation
import SwiftUI
import SwiftData

@Observable
final class HistoryViewModel {
    enum LeaderboardSortOption: Equatable {
        case score
        case accuracy
        case time
    }
    enum ClearHistoryResult {
        case success
        case failure(String)
    }

    var leaderboardSortOption: LeaderboardSortOption = .score
    var leaderboardSortDirection: Bool = true // true = descending for score/accuracy, ascending for time

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

    // MARK: - Leaderboard Sorting

    func toggleLeaderboardSort(by newOption: LeaderboardSortOption) {
        if leaderboardSortOption == newOption {
            // Same column clicked - toggle direction
            leaderboardSortDirection.toggle()
        } else {
            // Different column clicked - set to appropriate default direction
            leaderboardSortOption = newOption
            leaderboardSortDirection = true // descending for score/accuracy, ascending for time is handled in sort
        }
    }

    func sortedLeaderboardResults(_ results: [HardcoreResult]) -> [HardcoreResult] {
        switch leaderboardSortOption {
        case .score:
            return leaderboardSortDirection
                ? results.sorted { $0.scoreReached > $1.scoreReached }
                : results.sorted { $0.scoreReached < $1.scoreReached }
        case .accuracy:
            return leaderboardSortDirection
                ? results.sorted { $0.accuracy > $1.accuracy }
                : results.sorted { $0.accuracy < $1.accuracy }
        case .time:
            // Time: ascending (lower time = faster) is the default
            return !leaderboardSortDirection
                ? results.sorted { $0.timeTaken < $1.timeTaken }
                : results.sorted { $0.timeTaken > $1.timeTaken }
        }
    }

    @discardableResult
    func clearAllHistory(modelContext: ModelContext) -> ClearHistoryResult {
        do {
            try modelContext.delete(model: RoundHistoryItem.self)
            try modelContext.save()
            return .success
        } catch {
            print("Error clearing history: \(error.localizedDescription)")
            return .failure(error.localizedDescription)
        }
    }
}
