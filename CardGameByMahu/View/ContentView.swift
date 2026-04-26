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
    @State private var touchBarViewModel: TouchBarViewModel
    @State private var didSetupGameContext = false


    init() {
        let sharedDeckSettings = DeckSettings()
        let gameViewModel = CardGameViewModel(deckSettings: sharedDeckSettings)
        _setupViewModel = State(initialValue: SetupViewModel(deckSettings: sharedDeckSettings))
        _gameViewModel = State(initialValue: gameViewModel)
        _touchBarViewModel = State(initialValue: TouchBarViewModel(gameViewModel: gameViewModel))
    }

    var body: some View {
        TabView {
            SetupView(viewModel: setupViewModel, onApply: {
                gameViewModel.resetDeck()
            })
            .accessibilityIdentifier("setupTab")
            .tabItem {
                Label("Setup", systemImage: "slider.horizontal.3")
                    .accessibilityIdentifier("setupTab")
            }
            .onAppear {
                touchBarViewModel.setPlayTabVisible(false)
                guard !didSetupGameContext else { return }
                gameViewModel.setupGame(context: modelContext)
                didSetupGameContext = true
            }

            GameView(viewModel: gameViewModel, onVisibilityChange: { isVisible in
                touchBarViewModel.setPlayTabVisible(isVisible)
            })
            .accessibilityIdentifier("playTab")
                .tabItem {
                    Label("Play", systemImage: "play.circle.fill")
                    .accessibilityIdentifier("playTab")
                }
                    
            HistoryView()
                .accessibilityIdentifier("historyTab")
                .tabItem {
                    Label("History", systemImage: "list.clipboard.fill")
                    .accessibilityIdentifier("historyTab")
                }

            LeaderboardView()
                .accessibilityIdentifier("leaderboardTab")
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
        .onChange(of: gameViewModel.waitingForGuess) { _, _ in
            touchBarViewModel.refresh()
        }
    }
}
