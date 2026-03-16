//
//  CardGameByMahuApp.swift
//  CardGameByMahu
//
//  Created by Gergo Mahunka on 2026. 03. 01..
//

import SwiftUI
import SwiftData

@main
struct CardGameByMahuApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(width: 400)
                .frame(maxHeight: 900)
                .frame(minHeight: 700)
        }
        .windowResizability(.contentSize)
        .modelContainer(for: [PlayingCard.self, GameScore.self, RoundHistoryItem.self])
    }
}
