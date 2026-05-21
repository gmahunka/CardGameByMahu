//
//  LeaderboardTableView.swift
//  CardGameByMahu
//
//  Created by Gergo Mahunka on 2026. 05. 19..
//

import SwiftUI

struct LeaderboardTableView: View {
    @Bindable var viewModel: HistoryViewModel
    let results: [HardcoreResult]
    let availableWidth: CGFloat
    let onDelete: (HardcoreResult) -> Void
    
    var sortedResults: [HardcoreResult] {
        viewModel.sortedLeaderboardResults(results)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            TableHeaderView(viewModel: viewModel, availableWidth: availableWidth)
            
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
                List {
                    ForEach(Array(sortedResults.enumerated()), id: \.element.id) { index, result in
                        TableRowView(
                            result: result,
                            rank: index + 1,
                            isAlternate: index % 2 == 1,
                            availableWidth: availableWidth,
                            onDelete: onDelete
                        )
                        .listRowInsets(EdgeInsets())
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .background(Color.clear)
            }
        }
        .background(CyberpunkTheme.background)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
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
        availableWidth: 900,
        onDelete: { _ in }
    )
    .padding()
    .background(CyberpunkTheme.background)
    .frame(maxHeight: 500)
}
