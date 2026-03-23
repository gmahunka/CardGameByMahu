//
//  HardcoreGameViewModel.swift
//  CardGameByMahu
//
//  Created by Gergo Mahunka on 2026. 03. 23..
//

import Foundation
import SwiftData
import Observation

@Observable
@MainActor
final class HardcoreGameEngine {
    
    private let deckSettings: DeckSettings
    private var modelContext: ModelContext?
    
    // MARK: - Properties
    var isHardcoreMode: Bool = false
    var elapsedTime: Double = 0
    var optimalGuessCount: Int = 0
    var guessCount: Int = 0
    
    private var timer: Timer?
    private var startDate: Date?
    
    init(deckSettings: DeckSettings) {
        self.deckSettings = deckSettings
    }
    
    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
    }
    
    // MARK: - Public Methods
    
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
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                guard let self, let start = self.startDate else { return }
                self.elapsedTime = Date().timeIntervalSince(start)
            }
        }
        if let timer {
            RunLoop.main.add(timer, forMode: .common)
        }
    }
    
    func recordGuess(isOptimal: Bool) {
        guessCount += 1
        if isOptimal {
            optimalGuessCount += 1
        }
    }
    
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
    
    func quit() {
        stopTimer()
        isHardcoreMode = false
        elapsedTime = 0
        optimalGuessCount = 0
        guessCount = 0
    }
    
    var accuracyPercent: Double {
        guard guessCount > 0 else { return 0 }
        return (Double(optimalGuessCount) / Double(guessCount)) * 100
    }
    
    // MARK: - Private Methods
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
        startDate = nil
    }
}
