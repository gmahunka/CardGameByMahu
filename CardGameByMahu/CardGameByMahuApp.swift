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
    // TODO: Handle migration instead of deleting the store on schema incompatibility
    let container: ModelContainer = {
        let schema = Schema([
            PlayingCard.self,
            GameScore.self,
            RoundHistoryItem.self,
            HardcoreResult.self
        ])
        
        let isUITesting = ProcessInfo.processInfo.arguments.contains("-uitesting")
        let config = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: isUITesting
        )
        
        do {
            let container = try ModelContainer(for: schema, configurations: [config])
            return container
        } catch {
            
            // TODO: Handle migration instead of deleting the store on schema incompatibility
            print("⚠️ ModelContainer creation failed: \(error). Deleting store and retrying.")
            let storeURL = config.url
            try? FileManager.default.removeItem(at: storeURL)
            try? FileManager.default.removeItem(at: storeURL.deletingPathExtension().appendingPathExtension("store-shm"))
            try? FileManager.default.removeItem(at: storeURL.deletingPathExtension().appendingPathExtension("store-wal"))
            return try! ModelContainer(for: schema, configurations: [config])
        }
    }()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(width: 400)
                .frame(maxHeight: 900)
                .frame(minHeight: 700)
        }
        .windowResizability(.contentSize)
        .modelContainer(container)
    }
}
