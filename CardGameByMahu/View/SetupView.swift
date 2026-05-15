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

            VStack(alignment: .center, spacing: 16) {
                HStack(alignment: .center, spacing: 10) {
                    Image(systemName: "gearshape.fill")
                        .font(.title)
                        .foregroundStyle(CyberpunkTheme.cyan)
                    Text("Game Setup")
                        .font(.largeTitle.weight(.heavy))
                        .foregroundStyle(CyberpunkTheme.textPrimary)
                        .padding(.vertical, 2)
                }
                .cyberPanel(accent: CyberpunkTheme.cyan, fillOpacity: 0.05)

                Button(action: {
                    viewModel.resetToRegularDeck()
                }) {
                    Label("Regular Deck (4 of each)", systemImage: "suit.spade.fill")
                }
                .buttonStyle(NeonButtonStyle(accent: CyberpunkTheme.cyan, fillOpacity: 0.12, cornerRadius: 14, fillsWidth: true))
                .accessibilityIdentifier("resetDeckOfCardstoRegularButton")
                .accessibilityLabel("Regular Deck")
                .padding(.horizontal)

                GeometryReader { geometry in
                    let availableWidth = geometry.size.width - 32
                    let cardSize: CGFloat = 70
                    let buttonSize: CGFloat = 44
                    let textFieldWidth: CGFloat = 60
                    let spacing: CGFloat = 12
                    let itemWidth = cardSize + spacing + buttonSize + spacing + textFieldWidth + spacing + buttonSize
                    let columnCount = max(1, Int((availableWidth + spacing) / (itemWidth + spacing)))
                    
                    ScrollView(.vertical, showsIndicators: false) {
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: spacing), count: columnCount), spacing: spacing) {
                            ForEach(viewModel.cardConfigs) { config in
                                VStack(alignment: .center, spacing: 8) {
                                    Image("card\(config.id)")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 100)
                                        .shadow(color: CyberpunkTheme.cyan.opacity(0.15), radius: 8)

                                    HStack(alignment: .center, spacing: 8) {
                                        Button(action: {
                                            viewModel.decreaseCount(for: config.id)
                                        }) {
                                            Image(systemName: "minus.circle.fill")
                                                .font(.system(size: 20, weight: .semibold))
                                                .frame(width: 32, height: 32)
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
                                        .frame(width: 50)
                                        .multilineTextAlignment(.center)

                                        Button(action: {
                                            viewModel.increaseCount(for: config.id)
                                        }) {
                                            Image(systemName: "plus.circle.fill")
                                                .font(.system(size: 20, weight: .semibold))
                                                .frame(width: 32, height: 32)
                                                .contentShape(Rectangle())
                                        }
                                        .buttonStyle(.plain)
                                        .foregroundStyle(CyberpunkTheme.cyan)
                                        .accessibilityLabel("Increase quantity")
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .padding(10)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.black.opacity(0.24))
                                )
                            }
                        }
                        .padding(16)
                    }
                }
                .frame(maxHeight: .infinity)

                Button(action: {
                    NSApp.keyWindow?.makeFirstResponder(nil)
                    onApply()
                }) {
                    Label("Save & Apply", systemImage: "checkmark.circle.fill")
                }
                .buttonStyle(NeonButtonStyle(accent: CyberpunkTheme.magenta, fillOpacity: 0.14, cornerRadius: 14, fillsWidth: true))
                .accessibilityIdentifier("saveApplyButton")
                .accessibilityLabel("Save & Apply")
                .padding()
            }
        }
    }
}

