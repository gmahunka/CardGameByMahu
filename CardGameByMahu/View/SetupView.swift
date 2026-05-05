//
//  SetupView.swift
//  CardGameByMahu
//
//  Created by Gergo Mahunka on 2026. 03. 09..
//

import SwiftUI
import AppKit

struct SetupView: View {
    @Bindable var viewModel: SetupViewModel
    let onApply: () -> Void

    var body: some View {
        ZStack {
            CyberBackdrop()

            VStack(spacing: 16) {
                HStack(spacing: 10) {
                    Image(systemName: "gearshape.fill")
                        .font(.title)
                        .foregroundStyle(CyberpunkTheme.cyan)
                    Text("Game Setup")
                        .font(.largeTitle.weight(.heavy))
                        .foregroundStyle(CyberpunkTheme.textPrimary)
                }
                .padding(.top)
                .cyberPanel(accent: CyberpunkTheme.cyan, fillOpacity: 0.05)

                Button(action: {
                    viewModel.resetToRegularDeck()
                }) {
                    Label("Regular Deck (4 of each)", systemImage: "suit.spade.fill")
                }
                .buttonStyle(NeonButtonStyle(accent: CyberpunkTheme.cyan, fillOpacity: 0.12, cornerRadius: 14, fillsWidth: true))
                .accessibilityIdentifier("resetDeckOfCardstoRegularButton")
                .padding(.horizontal)

                List(viewModel.cardConfigs) { config in
                    HStack(alignment: .center, spacing: 12) {
                        Spacer(minLength: 0)

                        Image("card\(config.id)")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 70, height: 100)
                            .shadow(color: CyberpunkTheme.cyan.opacity(0.15), radius: 8)
                            .padding(.trailing, 4)

                        Button(action: {
                            viewModel.decreaseCount(for: config.id)
                        }) {
                            Image(systemName: "minus.circle.fill")
                                .font(.system(size: 26, weight: .semibold))
                                .frame(width: 44, height: 44)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .foregroundStyle(CyberpunkTheme.magenta)
                        .accessibilityLabel("Decrease quantity")

                        TextField(
                            "Count",
                            value: Binding(
                                get: { config.count },
                                set: { newValue in
                                    viewModel.updateCount(config.id, count: newValue)
                                }
                            ),
                            format: .number
                        )
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 60)
                        .multilineTextAlignment(.center)

                        Button(action: {
                            viewModel.increaseCount(for: config.id)
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 26, weight: .semibold))
                                .frame(width: 44, height: 44)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .foregroundStyle(CyberpunkTheme.cyan)
                        .accessibilityLabel("Increase quantity")

                        Spacer(minLength: 0)
                    }
                    .padding(.vertical, 10)
                    .listRowBackground(Color.black.opacity(0.24))
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .background(Color.clear)

                Button(action: {
                    NSApp.keyWindow?.makeFirstResponder(nil)
                    DispatchQueue.main.async {
                        onApply()
                    }
                }) {
                    Label("Save & Apply", systemImage: "checkmark.circle.fill")
                }
                .buttonStyle(NeonButtonStyle(accent: CyberpunkTheme.magenta, fillOpacity: 0.14, cornerRadius: 14, fillsWidth: true))
                .accessibilityIdentifier("saveApplyButton")
                .padding()
            }
        }
    }
}
