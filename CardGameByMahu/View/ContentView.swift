//
//  ContentView.swift
//  CardGameByMahu
//
//  Created by Gergo Mahunka on 2026. 03. 01..
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var setupViewModel: SetupViewModel
    @State private var gameViewModel: CardGameViewModel

    init() {
        let sharedDeckSettings = DeckSettings()
        _setupViewModel = State(initialValue: SetupViewModel(deckSettings: sharedDeckSettings))
        _gameViewModel = State(initialValue: CardGameViewModel(deckSettings: sharedDeckSettings))
    }

    var body: some View {
        TabView {
            SetupView(viewModel: setupViewModel, onApply: {
                gameViewModel.resetDeck()
            })
            .tabItem {
                Label("Setup", systemImage: "slider.horizontal.3")
            }

            GameView(viewModel: gameViewModel)
                .overlay(alignment: .topLeading) {
                    Button {
                        gameViewModel.isHardcoreMode = true
                    } label: {
                        Label("Hardcore Mode", systemImage: "flame.fill")
                            .font(.subheadline.bold())
                            .foregroundStyle(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color.red.opacity(0.8))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    .padding(.top, 20)
                    .padding(.leading, 20)
                }
                .tabItem {
                    Label("Play", systemImage: "play.circle.fill")
                }

            HistoryView()
                .tabItem {
                    Label("History", systemImage: "list.clipboard.fill")
                }

            LeaderboardView()
                .tabItem {
                    Label("Leaderboard", systemImage: "trophy.fill")
                }
        }
        .tabViewStyle(.grouped)
        .sheet(isPresented: $gameViewModel.isHardcoreMode) {
            HardcoreGameView(viewModel: gameViewModel)
                .interactiveDismissDisabled(true)
        }
        .tint(.orange)
    }
}
