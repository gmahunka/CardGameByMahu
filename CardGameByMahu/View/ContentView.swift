//
//  ContentView.swift
//  CardGameByMahu
//
//  Created by Gergo Mahunka on 2026. 03. 01..
//

import SwiftUI
import SwiftData

struct ContentView: View {
    private enum AppTab: Hashable {
        case setup
        case play
        case history
        case leaderboard
    }

    @Environment(\.modelContext) private var modelContext
    @State private var setupViewModel: SetupViewModel
    @State private var gameViewModel: CardGameViewModel
    @State private var touchBarViewModel: TouchBarViewModel
    @State private var didSetupGameContext = false
    @State private var selectedTab: AppTab = .setup


    init() {
        let sharedDeckSettings = DeckSettings()
        let gameViewModel = CardGameViewModel(deckSettings: sharedDeckSettings)
        _setupViewModel = State(initialValue: SetupViewModel(deckSettings: sharedDeckSettings))
        _gameViewModel = State(initialValue: gameViewModel)
        _touchBarViewModel = State(initialValue: TouchBarViewModel(gameViewModel: gameViewModel))
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            SetupView(viewModel: setupViewModel, onApply: {
                gameViewModel.resetDeck()
            })
            .accessibilityIdentifier("setupTab")
            .tabItem {
                Label("Setup", systemImage: "slider.horizontal.3")
                    .accessibilityIdentifier("setupTab")
            }
            .tag(AppTab.setup)

            GameView(viewModel: gameViewModel, touchBarViewModel: touchBarViewModel)
            .accessibilityIdentifier("playTab")
                .tabItem {
                    Label("Play", systemImage: "play.circle.fill")
                    .accessibilityIdentifier("playTab")
                }
                .tag(AppTab.play)
                    
            HistoryView()
                .accessibilityIdentifier("historyTab")
                .tabItem {
                    Label("History", systemImage: "list.clipboard.fill")
                    .accessibilityIdentifier("historyTab")
                }
                .tag(AppTab.history)

            LeaderboardView()
                .accessibilityIdentifier("leaderboardTab")
                .tabItem {
                    Label("Leaderboard", systemImage: "trophy.fill")
                    .accessibilityIdentifier("leaderboardTab")
                }
                .tag(AppTab.leaderboard)
        }
        .tabViewStyle(.grouped)
        .sheet(isPresented: $gameViewModel.isHardcoreMode) {
            HardcoreGameView(viewModel: gameViewModel)
                .interactiveDismissDisabled(true)
        }
        .tint(.orange)
        .onAppear {
            guard !didSetupGameContext else {
                touchBarViewModel.setPlayTabVisible(selectedTab == .play)
                return
            }

            gameViewModel.setupGame(context: modelContext)
            didSetupGameContext = true
            touchBarViewModel.setPlayTabVisible(selectedTab == .play)
        }
        .onChange(of: selectedTab) { _, newValue in
            touchBarViewModel.setPlayTabVisible(newValue == .play)
            if newValue == .play {
                DispatchQueue.main.async {
                    touchBarViewModel.refresh()
                }
            }
        }
        .onChange(of: gameViewModel.waitingForGuess) { _, _ in
            touchBarViewModel.refresh()
        }
    }
}
