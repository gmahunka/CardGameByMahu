//
//  HistoryView.swift
//  CardGameByMahu
//
//  Created by Gergo Mahunka on 2026. 03. 09..
//

import SwiftUI
import SwiftData

struct HistoryView: View {
    @Query(sort: \RoundHistoryItem.createdAt, order: .reverse) private var history: [RoundHistoryItem]
    @Environment(\.modelContext) private var modelContext
    private let viewModel = HistoryViewModel()
    @State private var showHistoryStatusAlert = false
    @State private var historyStatusTitle = ""
    @State private var historyStatusMessage = ""

    private let gridSpacing: CGFloat = 16
    private let minimumCardWidth: CGFloat = 340
    private let headerOverlayHeight: CGFloat = 94

    var body: some View {
        ZStack {
            CyberBackdrop()

            GeometryReader { geometry in
                let contentWidth = max(0, geometry.size.width - 32)
                let columnCount = max(1, Int((contentWidth + gridSpacing) / (minimumCardWidth + gridSpacing)))
                let columns = Array(repeating: GridItem(.flexible(), spacing: gridSpacing, alignment: .top), count: columnCount)

                VStack(spacing: 16) {
                    if history.isEmpty {
                        headerBar

                        VStack(spacing: 12) {
                            Image(systemName: "list.clipboard")
                                .font(.system(size: 40))
                                .foregroundColor(CyberpunkTheme.textSecondary)
                            Text("No rounds yet")
                                .font(.headline)
                                .foregroundStyle(CyberpunkTheme.textPrimary)
                            Text("Play a round and it will appear here.")
                                .font(.subheadline)
                                .foregroundStyle(CyberpunkTheme.textSecondary)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .cyberPanel(accent: CyberpunkTheme.cyan, fillOpacity: 0.04)
                    } else {
                        ZStack(alignment: .top) {
                            ScrollView(.vertical, showsIndicators: false) {
                                LazyVGrid(columns: columns, spacing: gridSpacing) {
                                    ForEach(viewModel.rows(from: history)) { row in
                                        HistoryCardView(row: row)
                                    }
                                }
                                .padding(.top, headerOverlayHeight + 12)
                                .padding(.vertical, 4)
                            }

                            Rectangle()
                                .fill(.ultraThinMaterial)
                                .frame(height: headerOverlayHeight + 20)
                                .mask(
                                    LinearGradient(
                                        colors: [.black, .black, .clear],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .allowsHitTesting(false)

                            headerBar
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .alert(historyStatusTitle, isPresented: $showHistoryStatusAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(historyStatusMessage)
        }
    }
}

private extension HistoryView {
    var headerBar: some View {
        HStack(alignment: .center, spacing: 10) {
            Image(systemName: "clock.fill")
                .font(.title)
                .foregroundStyle(CyberpunkTheme.cyan)
            Text("Match History")
                .font(.largeTitle.weight(.heavy))
                .foregroundStyle(CyberpunkTheme.textPrimary)
            if !history.isEmpty {
                Button(action: {
                    let result = viewModel.clearAllHistory(modelContext: modelContext)
                    switch result {
                    case .success:
                        historyStatusTitle = "History Cleared"
                        historyStatusMessage = "All rounds were removed successfully."
                    case .failure(let details):
                        historyStatusTitle = "Unable to Clear History"
                        historyStatusMessage = "Please try again. \(details)"
                    }
                    showHistoryStatusAlert = true
                }) {
                    Image(systemName: "trash.fill")
                        .font(.title3)
                        .foregroundColor(CyberpunkTheme.magenta)
                }
                .help("Clear all history")
            }
        }
        .cyberPanel(accent: CyberpunkTheme.cyan, fillOpacity: 0.05)
    }
}

private struct HistoryCardView: View {
    let row: HistoryViewModel.RowViewData

    var body: some View {
        let glowColor = row.isHardcoreMode ? CyberpunkTheme.magenta : row.resultColor

        VStack(spacing: 12) {
            HStack(spacing: 24) {
                Spacer()
                VStack(spacing: 6) {
                    Text("Player")
                        .font(row.isHardcoreMode ? .caption.weight(.bold) : .caption)
                        .foregroundColor(row.isHardcoreMode ? CyberpunkTheme.magenta : CyberpunkTheme.textSecondary)
                    Image(row.playerCard)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: 80, maxHeight: 115)
                        .shadow(color: CyberpunkTheme.cyan.opacity(0.16), radius: 8)
                }
                VStack(spacing: 6) {
                    Text("Computer")
                        .font(row.isHardcoreMode ? .caption.weight(.bold) : .caption)
                        .foregroundColor(row.isHardcoreMode ? CyberpunkTheme.magenta : CyberpunkTheme.textSecondary)
                    Image(row.computerCard)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: 80, maxHeight: 115)
                        .shadow(color: CyberpunkTheme.magenta.opacity(0.16), radius: 8)
                }
                Spacer()
            }

            HStack(spacing: 16) {
                Spacer()
                Label(row.resultTitle, systemImage: row.resultSystemImage)
                    .font(row.isHardcoreMode ? .subheadline.weight(.heavy) : .subheadline.weight(.bold))
                    .foregroundColor(row.isHardcoreMode && !row.resultTitle.contains("Correct") ? CyberpunkTheme.magenta : row.resultColor)
                Spacer()
            }

            VStack(spacing: 6) {
                HStack(spacing: 8) {
                    Spacer()
                    ForEach(row.pills) { pill in
                        Text(pill.text)
                            .font(.caption.weight(row.isHardcoreMode && pill.isEmphasized ? .heavy : (pill.isEmphasized ? .bold : .regular)))
                            .foregroundColor(pill.foregroundColor)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 5)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(pill.backgroundColor)
                            )
                    }
                    Spacer()
                }
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity)
        .background {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(glowColor.opacity(0.75))
                    .padding(0)
                    .shadow(color: glowColor.opacity(0.85), radius: 28)
                    .scrollTransition(axis: .vertical) { content, phase in
                        // Inline computations to avoid main-actor isolation warnings
                        let intensity = max(0, min(1, abs(CGFloat(phase.value))))
                        let baseOpacity = row.isHardcoreMode ? 0.50 : 0.40
                        let opacity = baseOpacity + (1.0 * Double(intensity))
                        let blur = 12 + (40 * intensity)
                        let yOffset = 6 + (30 * intensity)
                        let scale = 1.0 + (0.08 * intensity)

                        return content
                            .opacity(opacity)
                            .blur(radius: blur)
                            .offset(y: yOffset)
                            .scaleEffect(scale)
                    }

                RoundedRectangle(cornerRadius: 12)
                    .fill(row.isHardcoreMode ? Color.black.opacity(0.30) : Color.black.opacity(0.22))
                    .padding(6)
            }
        }
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(row.isHardcoreMode ? CyberpunkTheme.magenta.opacity(0.75) : row.borderColor.opacity(0.8), lineWidth: row.isHardcoreMode ? 2 : 1.5)
        )
    }
}

private func historyGlowIntensity(for phase: ScrollTransitionPhase) -> CGFloat {
    max(0, min(1, abs(CGFloat(phase.value))))
}

private func historyGlowOpacity(for phase: ScrollTransitionPhase, hardcore: Bool) -> Double {
    let intensity = historyGlowIntensity(for: phase)
    let baseOpacity = hardcore ? 0.50 : 0.40
    return baseOpacity + (1.0 * Double(intensity))
}

private func historyGlowBlur(for phase: ScrollTransitionPhase) -> CGFloat {
    12 + (40 * historyGlowIntensity(for: phase))
}

private func historyGlowOffset(for phase: ScrollTransitionPhase) -> CGFloat {
    6 + (30 * historyGlowIntensity(for: phase))
}

#Preview("History Scroll Shadow") {
    HistoryView()
        .modelContainer(for: RoundHistoryItem.self, inMemory: true)
}
