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
            
            SetupView()
                .tabItem {
                    Label("Setup", systemImage: "slider.horizontal.3")
                }
            
            GameView()
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
