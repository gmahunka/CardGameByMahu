//
//  TableHeaderView.swift
//  CardGameByMahu
//
//  Created by Gergo Mahunka on 2026. 05. 19..
//

import SwiftUI

struct TableHeaderView: View {
    var viewModel: HistoryViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                // Rank column
                headerCell(label: "RANK", width: 60, alignment: .center, isClickable: false)
                
                // Score column
                headerCellButton(label: "SCORE", width: 80, alignment: .trailing, isActive: viewModel.leaderboardSortOption == .score) {
                    viewModel.toggleLeaderboardSort(by: .score)
                }
                
                // Accuracy column
                headerCellButton(label: "ACCURACY", width: 90, alignment: .trailing, isActive: viewModel.leaderboardSortOption == .accuracy) {
                    viewModel.toggleLeaderboardSort(by: .accuracy)
                }
                
                // Time column
                headerCellButton(label: "TIME", width: 80, alignment: .trailing, isActive: viewModel.leaderboardSortOption == .time) {
                    viewModel.toggleLeaderboardSort(by: .time)
                }
                
                // Date/Time column
                headerCell(label: "DATE", width: nil, alignment: .leading, isClickable: false)
                
                // Actions column
                headerCell(label: "ACTIONS", width: 60, alignment: .center, isClickable: false)
                
                Spacer().frame(width: 0)
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(CyberpunkTheme.tableHeaderFill)
            .overlay(alignment: .bottom) {
                Divider()
                    .background(CyberpunkTheme.panelStroke)
            }
        }
    }
    
    @ViewBuilder
    private func headerCell(
        label: String,
        width: CGFloat?,
        alignment: Alignment,
        isClickable: Bool = true
    ) -> some View {
        Text(label)
            .font(.caption.weight(.semibold))
            .foregroundStyle(CyberpunkTheme.textSecondary)
            .if(width != nil, transform: { $0.frame(width: width, alignment: alignment) })
            .if(width == nil, transform: { $0.frame(maxWidth: .infinity, alignment: alignment) })
    }
    
    @ViewBuilder
    private func headerCellButton(
        label: String,
        width: CGFloat,
        alignment: Alignment,
        isActive: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Text(label)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(isActive ? CyberpunkTheme.cyan : CyberpunkTheme.textSecondary)
                
                if isActive {
                    Image(systemName: viewModel.leaderboardSortDirection ? "arrow.down" : "arrow.up")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(CyberpunkTheme.cyan)
                }
            }
            .frame(width: width, alignment: alignment)
        }
        .buttonStyle(.plain)
        .contentShape(Rectangle())
        .onHover { isHovering in
            if isHovering {
                NSCursor.pointingHand.push()
            } else {
                NSCursor.pop()
            }
        }
    }
}

extension View {
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

#Preview {
    @Previewable var viewModel = HistoryViewModel()
    TableHeaderView(viewModel: viewModel)
        .background(CyberpunkTheme.background)
}
