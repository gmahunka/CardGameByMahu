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

    var body: some View {
        ZStack {
            CyberBackdrop()

            VStack(spacing: 16) {
                HStack(spacing: 10) {
                    Image(systemName: "clock.fill")
                        .font(.title)
                        .foregroundStyle(CyberpunkTheme.cyan)
                    Text("Match History")
                        .font(.largeTitle.weight(.heavy))
                        .foregroundStyle(CyberpunkTheme.textPrimary)
                    Spacer()
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
                .padding(.top)
                .cyberPanel(accent: CyberpunkTheme.cyan, fillOpacity: 0.05)

                if history.isEmpty {
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
                    List(viewModel.rows(from: history)) { row in
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
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(row.isHardcoreMode ? Color.black.opacity(0.30) : Color.black.opacity(0.22))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(row.isHardcoreMode ? CyberpunkTheme.magenta.opacity(0.75) : row.borderColor.opacity(0.8), lineWidth: row.isHardcoreMode ? 2 : 1.5)
                        )
                        .padding(.vertical, 6)
                        .listRowBackground(Color.clear)
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                    .background(Color.clear)
                }
            }
            .padding(.horizontal)
        }
        .alert(historyStatusTitle, isPresented: $showHistoryStatusAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(historyStatusMessage)
        }
    }
}
