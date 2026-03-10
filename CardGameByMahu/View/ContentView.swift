//
//  ContentView.swift
//  CardGameByMahu
//
//  Created by Gergo Mahunka on 2026. 03. 01..
//

import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        TabView {
            GameView()
                .tabItem {
                    Label("Play", systemImage: "play.circle.fill")
                }
            
            SetupView()
                .tabItem {
                    Label("Setup", systemImage: "slider.horizontal.3")
                }
            
            HistoryView()
                .tabItem {
                    Label("History", systemImage: "list.clipboard.fill")
                }
        }
        // Optional: Change the accent color of the selected tab to match your game's theme
        .tint(.orange)
    }
}
