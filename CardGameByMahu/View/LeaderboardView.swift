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
        ZStack {
            CyberBackdrop()

            VStack(spacing: 16) {
                HStack(alignment: .center) {
                    Image(systemName: "trophy.fill")
                        .font(.title)
                        .foregroundStyle(CyberpunkTheme.cyan)
                    Text("Hardcore Leaderboard")
                        .font(.largeTitle.weight(.heavy))
                        .foregroundStyle(CyberpunkTheme.textPrimary)
                }
                .cyberPanel(accent: CyberpunkTheme.cyan, fillOpacity: 0.05)

                HStack(spacing: 12) {
                    Picker("Sort by:", selection: $sortOption) {
                        Text("Score").tag(SortOption.score)
                            .accessibilityIdentifier("sortByScoreButton")
                        Text("Accuracy").tag(SortOption.accuracy)
                            .accessibilityIdentifier("sortByAccuracyButton")
                        Text("Time").tag(SortOption.time)
                            .accessibilityIdentifier("sortByTimeButton")
                    }
                    .pickerStyle(.segmented)
                }
                .padding(.horizontal)

                if results.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "list.number")
                            .font(.system(size: 40))
                            .foregroundColor(CyberpunkTheme.textSecondary)
                        Text("No hardcore runs yet")
                            .font(.headline)
                            .foregroundStyle(CyberpunkTheme.textPrimary)
                        Text("Finish a Hardcore Mode run to appear here.")
                            .font(.subheadline)
                            .foregroundStyle(CyberpunkTheme.textSecondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .cyberPanel(accent: CyberpunkTheme.cyan, fillOpacity: 0.04)
                } else {
                    List {
                        ForEach(Array(sortedResults.enumerated()), id: \.element.id) { index, result in
                            HStack(spacing: 12) {
                                Text("#\(index + 1)")
                                    .font(.headline)
                                    .frame(width: 36, alignment: .leading)
                                    .foregroundStyle(CyberpunkTheme.cyan)

                                VStack(alignment: .leading, spacing: 4) {
                                    if sortOption == .score {
                                        Text("Score: \(result.scoreReached)")
                                            .font(.headline.bold())
                                            .foregroundStyle(CyberpunkTheme.textPrimary)
                                    } else {
                                        Text("Score: \(result.scoreReached)")
                                            .font(.subheadline)
                                            .foregroundStyle(CyberpunkTheme.textPrimary)
                                    }

                                    if sortOption == .accuracy {
                                        Text(String(format: "Accuracy: %.1f%%", result.accuracy * 100))
                                            .font(.headline.bold())
                                            .foregroundStyle(CyberpunkTheme.magenta)
                                    } else {
                                        Text(String(format: "Accuracy: %.1f%%", result.accuracy * 100))
                                            .font(.subheadline)
                                            .foregroundStyle(CyberpunkTheme.textSecondary)
                                    }

                                    if sortOption == .time {
                                        Text(String(format: "Time: %.1fs", result.timeTaken))
                                            .font(.headline.bold())
                                            .foregroundStyle(CyberpunkTheme.cyan)
                                    } else {
                                        Text(String(format: "Time: %.1fs", result.timeTaken))
                                            .font(.subheadline)
                                            .foregroundStyle(CyberpunkTheme.textSecondary)
                                    }
                                }

                                Spacer()

                                Text(result.date, format: .dateTime.year().month().day().hour().minute())
                                    .font(.caption)
                                    .foregroundStyle(CyberpunkTheme.textSecondary)

                                Button(action: {
                                    resultToDelete = result
                                }) {
                                    Image(systemName: "trash.fill")
                                        .font(.system(size: 14))
                                        .foregroundStyle(CyberpunkTheme.magenta)
                                }
                                .buttonStyle(.plain)
                            }
                            .accessibilityIdentifier("deleteLeaderboardEntrybutton")
                            .padding(.vertical, 6)
                            .listRowBackground(Color.black.opacity(0.22))
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                    .background(Color.clear)
                }
            }
        }
        .padding(.horizontal)
        .alert("Delete Entry?", isPresented: .constant(resultToDelete != nil)) {
            Button("Cancel", role: .cancel) {
                resultToDelete = nil
            }
            .accessibilityIdentifier("cancelDeleteEntryButton")
            Button("Delete", role: .destructive) {
                if let result = resultToDelete {
                    deleteResult(result)
                    resultToDelete = nil
                }
            }
            .accessibilityIdentifier("confirmDeleteEntryButton")
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
