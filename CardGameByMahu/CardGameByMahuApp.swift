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

@MainActor
final class AppNavigationModel: ObservableObject {
    @Published var selectedTab: AppTab = .setup

    nonisolated init() {}
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var observers: [NSObjectProtocol] = []

    deinit {
        removeObservers()
    }

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

        Task { @MainActor [weak self] in
            await Task.yield()
            self?.attachTouchBar(to: NSApp.keyWindow ?? NSApp.mainWindow)
        }
    }

    func applicationWillTerminate(_ notification: Notification) {
        removeObservers()
    }

    private func removeObservers() {
        guard !observers.isEmpty else { return }
        let center = NotificationCenter.default
        observers.forEach { center.removeObserver($0) }
        observers.removeAll()
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

            do {
                return try ModelContainer(for: schema, configurations: [config])
            } catch {
                print("⚠️ Persistent store recovery failed: \(error). Falling back to in-memory store.")
                let fallbackConfig = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)

                do {
                    return try ModelContainer(for: schema, configurations: [fallbackConfig])
                } catch {
                    fatalError("Unable to initialize ModelContainer for persistent or in-memory configuration: \(error)")
                }
            }
        }
    }()
    
    var body: some Scene {
        WindowGroup {
            ContentView(navigation: appNavigation)
                .frame(minWidth: 350, idealWidth: 900, maxWidth: .infinity, minHeight: 500, maxHeight: .infinity)
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
