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

    var body: some View {
        ZStack {
            Color(nsColor: .lightGray)
                .ignoresSafeArea()

            Color.black.opacity(0.15)
                .ignoresSafeArea()

            VStack {
                HStack {
                    Button {
                        viewModel.quitHardcoreMode()
                    } label: {
                        Label("Quit", systemImage: "xmark.circle.fill")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color.red.opacity(0.75))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Hardcore Mode")
                            .font(.headline)
                            .foregroundStyle(.white)
                        Text(String(format: "Time: %.1fs", viewModel.hardcoreElapsedTime))
                            .font(.title3.bold())
                            .monospacedDigit()
                            .foregroundStyle(.white)
                        Text(String(format: "Optimal guesses: %.1f%%", viewModel.hardcoreAccuracyPercent))
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.9))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)

                GameView(viewModel: viewModel)
            }
        }
    }
}
