//
//  LeaderboardTableView.swift
//  CardGameByMahu
//
//  Created by Gergo Mahunka on 2026. 05. 19..
//

import SwiftUI

struct LeaderboardTableView: View {
    var viewModel: HistoryViewModel
    let results: [HardcoreResult]
    let onDelete: (HardcoreResult) -> Void
    
    var sortedResults: [HardcoreResult] {
        viewModel.sortedLeaderboardResults(results)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            TableHeaderView(viewModel: viewModel)
            
            if sortedResults.isEmpty {
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
                .padding(.vertical, 32)
            } else {
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(Array(sortedResults.enumerated()), id: \.element.id) { index, result in
                            TableRowView(
                                result: result,
                                rank: index + 1,
                                isAlternate: index % 2 == 1,
                                onDelete: onDelete
                            )
                        }
                    }
                }
                .scrollIndicators(.hidden)
            }
        }
        .background(CyberpunkTheme.background)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(CyberpunkTheme.panelStroke, lineWidth: 0.5)
        )
    }
}

#Preview {
    @Previewable var viewModel = HistoryViewModel()
    @Previewable let results = [
        HardcoreResult(id: UUID(), timeTaken: 45.2, accuracy: 0.92, scoreReached: 1250, date: .now),
        HardcoreResult(id: UUID(), timeTaken: 52.8, accuracy: 0.88, scoreReached: 1100, date: .now.addingTimeInterval(-3600)),
        HardcoreResult(id: UUID(), timeTaken: 38.5, accuracy: 0.95, scoreReached: 1450, date: .now.addingTimeInterval(-7200)),
    ]
    
    LeaderboardTableView(
        viewModel: viewModel,
        results: results,
        onDelete: { _ in }
    )
    .padding()
    .background(CyberpunkTheme.background)
    .frame(maxHeight: 500)
}
