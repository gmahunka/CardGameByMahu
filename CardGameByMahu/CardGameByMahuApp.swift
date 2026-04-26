//
//  CardGameByMahuApp.swift
//  CardGameByMahu
//
//  Created by Gergo Mahunka on 2026. 03. 01..
//

import SwiftUI
import SwiftData
import AppKit
import Combine

enum AppTab: Hashable {
    case setup
    case play
    case history
    case leaderboard
}

final class AppNavigationModel: ObservableObject {
    @Published var selectedTab: AppTab = .setup
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var observers: [NSObjectProtocol] = []

    func applicationDidFinishLaunching(_ notification: Notification) {
        let center = NotificationCenter.default

        observers.append(center.addObserver(
            forName: NSWindow.didBecomeKeyNotification,
            object: nil,
            queue: .main
        ) { [weak self] note in
            self?.attachTouchBar(to: note.object as? NSWindow)
        })

        observers.append(center.addObserver(
            forName: NSWindow.didBecomeMainNotification,
            object: nil,
            queue: .main
        ) { [weak self] note in
            self?.attachTouchBar(to: note.object as? NSWindow)
        })

        DispatchQueue.main.async { [weak self] in
            self?.attachTouchBar(to: NSApp.keyWindow ?? NSApp.mainWindow)
        }
    }

    private func attachTouchBar(to window: NSWindow?) {
        GameTouchBarController.shared.attach(to: window)
    }
}

@main
struct CardGameByMahuApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var appNavigation = AppNavigationModel()

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
            ContentView(navigation: appNavigation)
                .frame(width: 400)
                .frame(maxHeight: 900)
                .frame(minHeight: 700)
        }
        .windowResizability(.contentSize)
        .modelContainer(container)
        .commands {
            CommandMenu("Tabs") {
                Button("Setup") {
                    appNavigation.selectedTab = .setup
                }
                .keyboardShortcut("1", modifiers: [.command])

                Button("Play") {
                    appNavigation.selectedTab = .play
                }
                .keyboardShortcut("2", modifiers: [.command])

                Button("History") {
                    appNavigation.selectedTab = .history
                }
                .keyboardShortcut("3", modifiers: [.command])

                Button("Leaderboard") {
                    appNavigation.selectedTab = .leaderboard
                }
                .keyboardShortcut("4", modifiers: [.command])
            }
        }
    }
}
