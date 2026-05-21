//
//  HardcoreGameViewModel.swift
//  CardGameByMahu
//
//  Created by Gergo Mahunka on 2026. 03. 23..
//
//  Purpose: Implements the "hardcore" gameplay mode with a fixed
//  52-card deck, timing, and optimal-guess tracking. This engine is
//  intentionally separated from the normal game logic so the UI can
//  switch modes without duplicating deck/state handling.

import Foundation
import SwiftData
import Observation

/// Engine controlling hardcore-mode timing, guess tracking, and result
/// persistence. Does not manage UI state — it provides metrics consumed
/// by `CardGameViewModel` for display and persistence.
@Observable
@MainActor
final class HardCoreGameViewModel {
    
    private let deckSettings: DeckSettings
    private var modelContext: ModelContext?
    
    // MARK: - Properties
    var isHardcoreMode: Bool = false
    var elapsedTime: Double = 0
    var optimalGuessCount: Int = 0
    var guessCount: Int = 0
    
    private var timerTask: Task<Void, Never>?
    private var startDate: Date?
    
    init(deckSettings: DeckSettings) {
        self.deckSettings = deckSettings
    }
    
    /// Attach the SwiftData `ModelContext` used for persisting results.
    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
    }
    
    // MARK: - Public Methods
    
    /// Start hardcore mode by initializing a standard 52-card deck and
    /// resetting timers and counters. This will zero any attached
    /// `playerScoreRecord` so the hardcore session begins fresh.
    func start(with context: ModelContext, playerScoreRecord: GameScore?) {
        self.modelContext = context
        stopTimer()
        
        isHardcoreMode = true
        elapsedTime = 0
        optimalGuessCount = 0
        guessCount = 0
        
        // Hardcore deck is always exactly 52 cards: 4x each value from 2...14.
        try? context.delete(model: PlayingCard.self)
        for value in DeckSettings.minCardValue...DeckSettings.maxCardValue {
            for _ in 0..<4 {
                context.insert(PlayingCard(value: value))
            }
        }
        
        playerScoreRecord?.playerScore = 0
        playerScoreRecord?.computerScore = 0
        
        try? context.save()
        
        startDate = Date()
        guard let start = startDate else { return }

        timerTask = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 100_000_000)
                guard let self else { return }
                self.elapsedTime = Date().timeIntervalSince(start)
            }
        }
    }
    
    /// Record a single guess and whether it matched the optimal choice.
    /// Used to compute accuracy at session end.
    func recordGuess(isOptimal: Bool) {
        guessCount += 1
        if isOptimal {
            optimalGuessCount += 1
        }
    }
    
    /// Complete the hardcore session, persist a `HardcoreResult`, and
    /// return the computed result for immediate use (e.g., UI summary).
    func finish(playerScore: Int) -> HardcoreResult {
        stopTimer()
        isHardcoreMode = false
        
        let accuracy = guessCount > 0
            ? Double(optimalGuessCount) / Double(guessCount)
            : 0
        
        let result = HardcoreResult(
            timeTaken: elapsedTime,
            accuracy: accuracy,
            scoreReached: playerScore
        )
        
        if let context = modelContext {
            context.insert(result)
            try? context.save()
        }
        
        return result
    }
    
    /// Abort hardcore mode mid-session and reset internal counters.
    func quit() {
        stopTimer()
        isHardcoreMode = false
        elapsedTime = 0
        optimalGuessCount = 0
        guessCount = 0
    }
    
    func stopTimerWhenRunExhausted() {
        guard isHardcoreMode else { return }
        stopTimer()
    }
    
    /// Percentage (0-100) of guesses that were optimal during the
    /// current hardcore session.
    var accuracyPercent: Double {
        guard guessCount > 0 else { return 0 }
        return (Double(optimalGuessCount) / Double(guessCount)) * 100
    }
    
    // MARK: - Private Methods
    
    private func stopTimer() {
        timerTask?.cancel()
        timerTask = nil
        startDate = nil
    }
}
