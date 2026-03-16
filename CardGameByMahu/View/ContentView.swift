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
                .tabItem {
                    Label("Play", systemImage: "play.circle.fill")
                }
            
            HistoryView()
                .tabItem {
                    Label("History", systemImage: "list.clipboard.fill")
                }
        }
        .tint(.orange)
    }
}
