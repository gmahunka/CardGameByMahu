//
//  TableHeaderView.swift
//  CardGameByMahu
//
//  Created by Gergo Mahunka on 2026. 05. 19..
//

import SwiftUI

struct TableHeaderView: View {
    var viewModel: HistoryViewModel
    let availableWidth: CGFloat

    private var tableSpacing: CGFloat {
        LeaderboardResponsiveMetrics.spacing(
            base: LeaderboardResponsiveMetrics.tableSpacing,
            max: LeaderboardResponsiveMetrics.tableSpacingMax,
            width: availableWidth
        )
    }

    private var horizontalPadding: CGFloat {
        LeaderboardResponsiveMetrics.padding(
            base: LeaderboardResponsiveMetrics.rowHorizontalPadding,
            max: LeaderboardResponsiveMetrics.rowHorizontalPaddingMax,
            width: availableWidth
        )
    }

    private var verticalPadding: CGFloat {
        LeaderboardResponsiveMetrics.padding(
            base: LeaderboardResponsiveMetrics.headerVerticalPadding,
            max: LeaderboardResponsiveMetrics.headerVerticalPaddingMax,
            width: availableWidth
        )
    }

    private var headerFontSize: CGFloat {
        LeaderboardResponsiveMetrics.fontSize(
            base: LeaderboardResponsiveMetrics.headerFontSize,
            max: LeaderboardResponsiveMetrics.headerFontSizeMax,
            width: availableWidth
        )
    }

    private var arrowFontSize: CGFloat {
        LeaderboardResponsiveMetrics.fontSize(
            base: LeaderboardResponsiveMetrics.arrowFontSize,
            max: LeaderboardResponsiveMetrics.arrowFontSizeMax,
            width: availableWidth
        )
    }

    private var rankColumnWidth: CGFloat {
        LeaderboardResponsiveMetrics.columnWidth(
            base: LeaderboardResponsiveMetrics.rankColumnWidth,
            max: LeaderboardResponsiveMetrics.rankColumnWidthMax,
            width: availableWidth
        )
    }

    private var scoreColumnWidth: CGFloat {
        LeaderboardResponsiveMetrics.columnWidth(
            base: LeaderboardResponsiveMetrics.scoreColumnWidth,
            max: LeaderboardResponsiveMetrics.scoreColumnWidthMax,
            width: availableWidth
        )
    }

    private var accuracyColumnWidth: CGFloat {
        LeaderboardResponsiveMetrics.columnWidth(
            base: LeaderboardResponsiveMetrics.accuracyColumnWidth,
            max: LeaderboardResponsiveMetrics.accuracyColumnWidthMax,
            width: availableWidth
        )
    }

    private var timeColumnWidth: CGFloat {
        LeaderboardResponsiveMetrics.columnWidth(
            base: LeaderboardResponsiveMetrics.timeColumnWidth,
            max: LeaderboardResponsiveMetrics.timeColumnWidthMax,
            width: availableWidth
        )
    }

    private var actionsColumnWidth: CGFloat {
        LeaderboardResponsiveMetrics.columnWidth(
            base: LeaderboardResponsiveMetrics.actionsColumnWidth,
            max: LeaderboardResponsiveMetrics.actionsColumnWidthMax,
            width: availableWidth
        )
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: tableSpacing) {
                // Rank column
                headerCell(label: "RANK", width: rankColumnWidth, alignment: .center)
                
                // Score column
                headerCellButton(label: "SCORE", width: scoreColumnWidth, alignment: .trailing, isActive: viewModel.leaderboardSortOption == .score) {
                    viewModel.toggleLeaderboardSort(by: .score)
                }
                
                // Accuracy column
                headerCellButton(label: "ACCURACY", width: accuracyColumnWidth, alignment: .trailing, isActive: viewModel.leaderboardSortOption == .accuracy) {
                    viewModel.toggleLeaderboardSort(by: .accuracy)
                }
                
                // Time column
                headerCellButton(label: "TIME", width: timeColumnWidth, alignment: .trailing, isActive: viewModel.leaderboardSortOption == .time) {
                    viewModel.toggleLeaderboardSort(by: .time)
                }
                
                // Date/Time column
                headerCell(label: "DATE", width: nil, alignment: .leading)
                
                // Actions column
                headerCell(label: "ACTIONS", width: actionsColumnWidth, alignment: .center)
                
                Spacer().frame(width: 0)
            }
            .padding(.vertical, verticalPadding)
            .padding(.horizontal, horizontalPadding)
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
        alignment: Alignment
    ) -> some View {
        Text(label)
            .font(.system(size: headerFontSize, weight: .semibold, design: .rounded))
            .foregroundStyle(CyberpunkTheme.textSecondary)
            .if(width != nil, transform: { $0.frame(width: width, alignment: alignment) })
            .if(width == nil, transform: { $0.frame(maxWidth: .infinity, alignment: alignment) })
            .lineLimit(1)
            .minimumScaleFactor(0.8)
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
            HStack(spacing: LeaderboardResponsiveMetrics.spacing(base: LeaderboardResponsiveMetrics.headerLabelSpacing, max: LeaderboardResponsiveMetrics.headerLabelSpacingMax, width: availableWidth)) {
                Text(label)
                    .font(.system(size: headerFontSize, weight: .semibold, design: .rounded))
                    .foregroundStyle(isActive ? CyberpunkTheme.cyan : CyberpunkTheme.textSecondary)
                
                if isActive {
                    Image(systemName: viewModel.leaderboardSortDirection ? "arrow.down" : "arrow.up")
                        .font(.system(size: arrowFontSize, weight: .bold, design: .rounded))
                        .foregroundStyle(CyberpunkTheme.cyan)
                }
            }
            .frame(width: width, alignment: alignment)
            .lineLimit(1)
            .minimumScaleFactor(0.8)
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
    TableHeaderView(viewModel: viewModel, availableWidth: 900)
        .background(CyberpunkTheme.background)
}
