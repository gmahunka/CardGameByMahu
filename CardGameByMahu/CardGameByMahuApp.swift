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
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            // The on-disk store is incompatible with the current schema (e.g. a new
            // entity was added). Delete the store file and recreate it from scratch.
            print("⚠️ ModelContainer creation failed: \(error). Deleting store and retrying.")
            let storeURL = config.url
            try? FileManager.default.removeItem(at: storeURL)
            // Also remove the associated -shm and -wal files
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
