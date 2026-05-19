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
    let onDelete: (HardcoreResult) -> Void
    
    @State private var isHovering = false
    
    var body: some View {
        HStack(spacing: 12) {
            // Rank column
            Text("#\(rank)")
                .font(.headline)
                .frame(width: 60, alignment: .center)
                .foregroundStyle(CyberpunkTheme.cyan)
            
            // Score column
            Text("\(result.scoreReached)")
                .font(.subheadline)
                .frame(width: 80, alignment: .trailing)
                .foregroundStyle(CyberpunkTheme.textPrimary)
            
            // Accuracy column
            Text(String(format: "%.1f%%", result.accuracy * 100))
                .font(.subheadline)
                .frame(width: 90, alignment: .trailing)
                .foregroundStyle(CyberpunkTheme.textPrimary)
            
            // Time column
            Text(String(format: "%.1fs", result.timeTaken))
                .font(.subheadline)
                .frame(width: 80, alignment: .trailing)
                .foregroundStyle(CyberpunkTheme.textPrimary)
            
            // Date/Time column
            Text(result.date, format: .dateTime.year().month().day().hour().minute())
                .font(.caption)
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundStyle(CyberpunkTheme.textSecondary)
            
            // Actions column
            Button(action: { onDelete(result) }) {
                Image(systemName: "trash.fill")
                    .font(.system(size: 14))
                    .foregroundStyle(CyberpunkTheme.magenta)
            }
            .buttonStyle(.plain)
            .frame(width: 60, alignment: .center)
            .opacity(isHovering ? 1.0 : 0.6)
            
            Spacer().frame(width: 0)
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 16)
        .background(
            isHovering
                ? CyberpunkTheme.tableRowHoverHighlight
                : (isAlternate ? CyberpunkTheme.rowBackgroundSecondary : CyberpunkTheme.rowBackgroundPrimary)
        )
        .overlay(alignment: .bottom) {
            Divider()
                .background(CyberpunkTheme.panelStroke.opacity(0.5))
        }
        .contentShape(Rectangle())
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.1)) {
                isHovering = hovering
            }
        }
        .contextMenu {
            Button(role: .destructive, action: { onDelete(result) }) {
                Label("Delete", systemImage: "trash.fill")
            }
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
        TableHeaderView(viewModel: HistoryViewModel())
        
        TableRowView(
            result: result,
            rank: 1,
            isAlternate: false,
            onDelete: { _ in }
        )
        
        TableRowView(
            result: result,
            rank: 2,
            isAlternate: true,
            onDelete: { _ in }
        )
        
        Spacer()
    }
    .background(CyberpunkTheme.background)
}
