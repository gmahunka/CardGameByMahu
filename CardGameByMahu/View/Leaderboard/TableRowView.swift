//
//  TableRowView.swift
//  CardGameByMahu
//
//  Created by Gergo Mahunka on 2026. 05. 19..
//

import SwiftUI

struct TableRowView: View {
    let result: HardcoreResult
    let rank: Int
    let isAlternate: Bool
    let availableWidth: CGFloat
    let onDelete: (HardcoreResult) -> Void

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
            base: LeaderboardResponsiveMetrics.rowVerticalPadding,
            max: LeaderboardResponsiveMetrics.rowVerticalPaddingMax,
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

    private var rankFontSize: CGFloat {
        LeaderboardResponsiveMetrics.fontSize(
            base: LeaderboardResponsiveMetrics.rowPrimaryFontSize,
            max: LeaderboardResponsiveMetrics.rowPrimaryFontSizeMax,
            width: availableWidth
        )
    }

    private var primaryFontSize: CGFloat {
        LeaderboardResponsiveMetrics.fontSize(
            base: LeaderboardResponsiveMetrics.rowSecondaryFontSize,
            max: LeaderboardResponsiveMetrics.rowSecondaryFontSizeMax,
            width: availableWidth
        )
    }

    private var dateFontSize: CGFloat {
        LeaderboardResponsiveMetrics.fontSize(
            base: LeaderboardResponsiveMetrics.dateFontSize,
            max: LeaderboardResponsiveMetrics.dateFontSizeMax,
            width: availableWidth
        )
    }

    private var deleteIconSize: CGFloat {
        LeaderboardResponsiveMetrics.fontSize(
            base: LeaderboardResponsiveMetrics.iconFontSize,
            max: LeaderboardResponsiveMetrics.iconFontSizeMax,
            width: availableWidth
        )
    }
    
    var body: some View {
        HStack(spacing: tableSpacing) {
            Text("#\(rank)")
                .font(.system(size: rankFontSize, weight: .semibold, design: .rounded))
                .frame(width: rankColumnWidth, alignment: .center)
                .foregroundStyle(CyberpunkTheme.cyan)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            
            Text("\(result.scoreReached)")
                .font(.system(size: primaryFontSize, weight: .semibold, design: .rounded))
                .frame(width: scoreColumnWidth, alignment: .trailing)
                .foregroundStyle(CyberpunkTheme.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            
            Text(String(format: "%.1f%%", result.accuracy * 100))
                .font(.system(size: primaryFontSize, weight: .semibold, design: .rounded))
                .frame(width: accuracyColumnWidth, alignment: .trailing)
                .foregroundStyle(CyberpunkTheme.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            
            Text(String(format: "%.1fs", result.timeTaken))
                .font(.system(size: primaryFontSize, weight: .semibold, design: .rounded))
                .frame(width: timeColumnWidth, alignment: .trailing)
                .foregroundStyle(CyberpunkTheme.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            
            Text(result.date, format: .dateTime.year().month().day().hour().minute())
                .font(.system(size: dateFontSize, weight: .regular, design: .rounded))
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundStyle(CyberpunkTheme.textSecondary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            
            Button(action: { onDelete(result) }) {
                Image(systemName: "trash.fill")
                    .font(.system(size: deleteIconSize, weight: .semibold))
                    .foregroundStyle(CyberpunkTheme.magenta)
            }
            .accessibilityIdentifier("deleteLeaderboardEntrybutton")
            .buttonStyle(.plain)
            .frame(width: actionsColumnWidth, alignment: .center)
            .opacity(0.6)
            
            Spacer().frame(width: 0)
        }
        .padding(.vertical, verticalPadding)
        .padding(.horizontal, horizontalPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            isAlternate ? CyberpunkTheme.rowBackgroundSecondary : CyberpunkTheme.rowBackgroundPrimary
        )
        .overlay(alignment: .bottom) {
            Divider()
                .background(CyberpunkTheme.panelStroke.opacity(0.5))
        }
        .contentShape(Rectangle())
        .contextMenu {
            Button(role: .destructive, action: { onDelete(result) }) {
                Label("Delete", systemImage: "trash.fill")
            }
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive, action: { onDelete(result) }) {
                Text("Delete")
            }
            .tint(.red)
        }
    }
}

#Preview {
    @Previewable let result = HardcoreResult(
        id: UUID(),
        timeTaken: 45.2,
        accuracy: 0.92,
        scoreReached: 1250,
        date: .now
    )
    
    VStack {
        TableHeaderView(viewModel: HistoryViewModel(), availableWidth: 900)
        
        TableRowView(
            result: result,
            rank: 1,
            isAlternate: false,
            availableWidth: 900,
            onDelete: { _ in }
        )
        
        TableRowView(
            result: result,
            rank: 2,
            isAlternate: true,
            availableWidth: 900,
            onDelete: { _ in }
        )
        
        Spacer()
    }
    .background(CyberpunkTheme.background)
}
