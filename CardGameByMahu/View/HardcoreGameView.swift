//
//  HardcoreGameView.swift
//  CardGameByMahu
//
//  Created by Gergo Mahunka on 2026. 03. 20..
//

import SwiftUI
import SwiftData

struct HardcoreGameView: View {
    @Bindable var viewModel: CardGameViewModel
    var touchBarViewModel: TouchBarViewModel? = nil

    var body: some View {
        ZStack {
            CyberBackdrop()

            LinearGradient(
                colors: [CyberpunkTheme.magenta.opacity(0.10), .clear],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack {
                HStack {
                    Button {
                        viewModel.quitHardcoreMode()
                    } label: {
                        Label("Quit", systemImage: "xmark.circle.fill")
                    }
                    .buttonStyle(NeonButtonStyle(accent: CyberpunkTheme.magenta, fillOpacity: 0.16, cornerRadius: 12))
                    .accessibilityIdentifier("quitHardcoreButton")

                    Spacer()

                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Hardcore Mode")
                            .font(.headline.weight(.bold))
                            .foregroundStyle(CyberpunkTheme.magenta)
                        Text(String(format: "Time: %.1fs", viewModel.hardcoreElapsedTime))
                            .font(.title3.bold())
                            .monospacedDigit()
                            .foregroundStyle(CyberpunkTheme.textPrimary)
                        Text(String(format: "Optimal guesses: %.1f%%", viewModel.hardcoreAccuracyPercent))
                            .font(.caption)
                            .foregroundStyle(CyberpunkTheme.textSecondary)
                    }
                    .cyberPanel(accent: CyberpunkTheme.magenta, fillOpacity: 0.08)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)

                GameView(viewModel: viewModel, touchBarViewModel: touchBarViewModel)
            }
        }
    }
}
