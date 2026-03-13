//
//  HistoryView.swift
//  CardGameByMahu
//
//  Created by Gergo Mahunka on 2026. 03. 09..
//

import SwiftUI

struct HistoryView: View {
    @Bindable var viewModel: CardGameViewModel

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "clock.fill")
                    .font(.largeTitle)
                Text("Match History")
                    .font(.title)
                    .bold()
            }
            .padding(.top)

            if viewModel.roundHistory.isEmpty {
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
                List(viewModel.roundHistory) { round in
                    VStack(spacing: 12) {
                        // Cards row
                        HStack(spacing: 24) {
                            Spacer()
                            VStack(spacing: 6) {
                                Text("Player")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Image(round.playerCard)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 60, height: 88)
                                    .shadow(radius: 2)
                            }
                            VStack(spacing: 6) {
                                Text("Computer")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Image(round.computerCard)
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
                            Label(
                                round.wasCorrect ? "Correct" : "Wrong",
                                systemImage: round.wasCorrect ? "checkmark.circle.fill" : "xmark.circle.fill"
                            )
                            .font(.subheadline.weight(.bold))
                            .foregroundColor(round.wasCorrect ? .green : .red)

                           
                            Spacer()
                        }

                        // Chances row
                        VStack(spacing: 6) {
//                            Text("Chances before draw")
//                                .font(.caption)
//                                .foregroundColor(.secondary)
                            HStack(spacing: 8) {
                                Spacer()
                                chancePill(
                                    title: "Lower",
                                    value: round.lowerChance,
                                    isEmphasized: round.playerChoice == "Lower",
                                    isCorrectAnswer: round.correctAnswer == "Lower"
                                )
                                chancePill(
                                    title: "Equal",
                                    value: round.equalChance,
                                    isEmphasized: round.playerChoice == "Equal",
                                    isCorrectAnswer: round.correctAnswer == "Equal"
                                )
                                chancePill(
                                    title: "Higher",
                                    value: round.higherChance,
                                    isEmphasized: round.playerChoice == "Higher",
                                    isCorrectAnswer: round.correctAnswer == "Higher"
                                )
                                Spacer()
                            }
                        }
                    }
                    .padding(14)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(nsColor: .windowBackgroundColor).opacity(0.8))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(round.wasCorrect ? Color.green.opacity(0.6) : Color.red.opacity(0.5), lineWidth: 1.5)
                    )
                    .padding(.vertical, 6)
                }
                .listStyle(.plain)
            }
        }
        .padding(.horizontal)
    }

    private func chancePill(title: String, value: Double, isEmphasized: Bool, isCorrectAnswer: Bool) -> some View {
        let percent = Int((value * 100).rounded())
        return Text("\(title): \(percent)%")
            .font(.caption.weight(isEmphasized ? .bold : .regular))
            .foregroundColor(isEmphasized ? .white : .primary)
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(
                        isEmphasized
                        ? (isCorrectAnswer ? Color.green : Color.red)
                        : Color.gray.opacity(0.2)
                    )
            )
    }
}
