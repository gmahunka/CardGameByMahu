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
    private let viewModel = HistoryViewModel()

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "clock.fill")
                    .font(.largeTitle)
                    .foregroundColor(.primary)
                Text("Match History")
                    .font(.title)
                    .bold()
            }
            .padding(.top)

            if history.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "list.clipboard")
                        .font(.system(size: 40))
                        .foregroundColor(.secondary)
                    Text("No rounds yet")
                        .font(.headline)
                    Text("Play a round and it will appear here.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List(viewModel.rows(from: history)) { row in
                    VStack(spacing: 12) {
                        // Cards row
                        HStack(spacing: 24) {
                            Spacer()
                            VStack(spacing: 6) {
                                Text("Player")
                                    .font(row.isHardcoreMode ? .caption.weight(.bold) : .caption)
                                    .foregroundColor(row.isHardcoreMode ? .red : .secondary)
                                Image(row.playerCard)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 60, height: 88)
                                    .shadow(radius: 2)
                            }
                            VStack(spacing: 6) {
                                Text("Computer")
                                    .font(row.isHardcoreMode ? .caption.weight(.bold) : .caption)
                                    .foregroundColor(row.isHardcoreMode ? .red : .secondary)
                                Image(row.computerCard)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 60, height: 88)
                                    .shadow(radius: 2)
                            }
                            Spacer()
                        }

                        // Result row
                        HStack(spacing: 16) {
                            Spacer()
                            Label(row.resultTitle, systemImage: row.resultSystemImage)
                                .font(row.isHardcoreMode ? .subheadline.weight(.heavy) : .subheadline.weight(.bold))
                                .foregroundColor(row.isHardcoreMode && !row.resultTitle.contains("Correct") ? .red : row.resultColor)
                            Spacer()
                        }

                        // Chances row
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
                            .fill(
                                row.isHardcoreMode
                                    ? Color.red.opacity(0.12)
                                    : Color(nsColor: .windowBackgroundColor).opacity(0.8)
                            )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                row.isHardcoreMode
                                    ? Color.red.opacity(0.8)
                                    : row.borderColor,
                                lineWidth: row.isHardcoreMode ? 2 : 1.5
                            )
                    )
                    .padding(.vertical, 6)
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .background(Color.red.opacity(0.06))
            }
        }
        .padding(.horizontal)
    }
}
