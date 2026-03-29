//
//  ContentView.swift
//  CardGameByMahu
//
//  Created by Gergo Mahunka on 2026. 03. 01..
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var setupViewModel: SetupViewModel
    @State private var gameViewModel: CardGameViewModel
    @State private var didSetupGameContext = false


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
                    .accessibilityIdentifier("setupTab")
                    .accessibilityLabel("Setup")
            }
            .onAppear {
                        guard !didSetupGameContext else { return }
                        gameViewModel.setupGame(context: modelContext)
                        didSetupGameContext = true
                    }

            GameView(viewModel: gameViewModel)
                .tabItem {
                    Label("Play", systemImage: "play.circle.fill")
                        .accessibilityIdentifier("playTab")
                        .accessibilityLabel("Play")
                }
                    
            HistoryView()
                .tabItem {
                    Label("History", systemImage: "list.clipboard.fill")
                        .accessibilityIdentifier("historyTab")
                }

            LeaderboardView()
                .tabItem {
                    Label("Leaderboard", systemImage: "trophy.fill")
                        .accessibilityIdentifier("leaderboardTab")
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
