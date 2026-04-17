//
//  LeaderboardView.swift
//  CardGameByMahu
//
//  Created by Gergo Mahunka on 2026. 03. 20..
//

import SwiftUI
import SwiftData

struct LeaderboardView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var resultToDelete: HardcoreResult?
    @State private var sortOption: SortOption = .score
    
    enum SortOption {
        case score
        case accuracy
        case time
    }
    
    @Query(sort: [
        SortDescriptor(\HardcoreResult.scoreReached, order: .reverse),
        SortDescriptor(\HardcoreResult.accuracy, order: .reverse),
        SortDescriptor(\HardcoreResult.timeTaken, order: .forward)
    ]) private var results: [HardcoreResult]
    
    var sortedResults: [HardcoreResult] {
        switch sortOption {
        case .score:
            return results.sorted { $0.scoreReached > $1.scoreReached }
        case .accuracy:
            return results.sorted { $0.accuracy > $1.accuracy }
        case .time:
            return results.sorted { $0.timeTaken < $1.timeTaken }
        }
    }

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "trophy.fill")
                    .font(.largeTitle)
                    .foregroundStyle(.orange)
                Text("Hardcore Leaderboard")
                    .font(.title)
                    .bold()
            }
            .padding(.top)

            // Sort Options
            HStack(spacing: 12) {
                Picker("Sort by:", selection: $sortOption) {
                    Text("Score").tag(SortOption.score)
                    Text("Accuracy").tag(SortOption.accuracy)
                    Text("Time").tag(SortOption.time)
                }
                .pickerStyle(.segmented)
            }
            .padding(.horizontal)

            if results.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "list.number")
                        .font(.system(size: 40))
                        .foregroundColor(.secondary)
                    Text("No hardcore runs yet")
                        .font(.headline)
                    Text("Finish a Hardcore Mode run to appear here.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(Array(sortedResults.enumerated()), id: \.element.id) { index, result in
                        HStack(spacing: 12) {
                            Text("#\(index + 1)")
                                .font(.headline)
                                .frame(width: 36, alignment: .leading)

                            VStack(alignment: .leading, spacing: 4) {
                                // Score styling based on sort
                                if sortOption == .score {
                                    Text("Score: \(result.scoreReached)")
                                        .font(.headline.bold())
                                } else {
                                    Text("Score: \(result.scoreReached)")
                                        .font(.subheadline)
                                }
                                
                                if sortOption == .accuracy {
                                    Text(String(format: "Accuracy: %.1f%%", result.accuracy * 100))
                                        .font(.headline.bold())
                                } else {
                                    Text(String(format: "Accuracy: %.1f%%", result.accuracy * 100))
                                        .font(.subheadline)
                                }
                                
                                if sortOption == .time {
                                    Text(String(format: "Time: %.1fs", result.timeTaken))
                                        .font(.headline.bold())
                                } else {
                                    Text(String(format: "Time: %.1fs", result.timeTaken))
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }
                            }

                            Spacer()

                            Text(result.date, format: .dateTime.year().month().day().hour().minute())
                                .font(.caption)
                                .foregroundStyle(.secondary)

                            Button(action: {
                                resultToDelete = result
                            }) {
                                Image(systemName: "trash.fill")
                                    .font(.system(size: 14))
                                    .foregroundStyle(.red)
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.vertical, 6)
                    }
                }
                .listStyle(.plain)
            }
        }
        .padding(.horizontal)
        .alert("Delete Entry?", isPresented: .constant(resultToDelete != nil)) {
            Button("Cancel", role: .cancel) {
                resultToDelete = nil
            }
            Button("Delete", role: .destructive) {
                if let result = resultToDelete {
                    deleteResult(result)
                    resultToDelete = nil
                }
            }
        } message: {
            Text("Are you sure you want to delete this leaderboard entry? This action cannot be undone.")
        }
    }

    private func deleteResult(_ result: HardcoreResult) {
        modelContext.delete(result)

        do {
            try modelContext.save()
        } catch {
            assertionFailure("Failed to delete leaderboard entry: \(error)")
        }
    }
}
