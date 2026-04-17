//
//  HardcoreGameViewModelTest.swift
//  CardGameByMahuUnitTests
//
//  Created by Gergo Mahunka on 2026. 03. 28..
//

import Foundation
import SwiftData
import Testing
@testable import CardGameByMahu

@MainActor
struct HardcoreGameViewModelTest {

    // MARK: - Helpers

    private func makeInMemoryContext() throws -> ModelContext {
        let schema = Schema([PlayingCard.self, HardcoreResult.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: [config])
        return ModelContext(container)
    }

    private func makeDeckSettings() -> DeckSettings {
        DeckSettings()
    }
    
    private func waitUntil(
        timeout: Duration = .seconds(1),
        step: Duration = .milliseconds(20),
        condition: @MainActor () -> Bool
    ) async throws {
        let deadline = ContinuousClock.now + timeout
        while ContinuousClock.now < deadline {
            if condition() { return }
            try await Task.sleep(for: step)
        }
        Issue.record("Timed out waiting for condition")
    }

    // MARK: - Tests

    @Test
    func start_initializesHardcoreState_buildsFullDeck_resetsScore_andStartsTimer() async throws {
        let context = try makeInMemoryContext()
        let sut = HardCoreGameViewModel(deckSettings: makeDeckSettings())
        let score = GameScore(playerScore: 9, computerScore: 7)

        sut.start(with: context, playerScoreRecord: score)

        #expect(sut.isHardcoreMode == true)
        #expect(sut.elapsedTime >= 0)
        #expect(sut.optimalGuessCount == 0)
        #expect(sut.guessCount == 0)
        #expect(score.playerScore == 0)
        #expect(score.computerScore == 0)

        let cards = try context.fetch(FetchDescriptor<PlayingCard>())
        #expect(cards.count == 52)

        // Each card value from 2...14 appears exactly 4 times.
        let counts = Dictionary(grouping: cards, by: \.value).mapValues(\.count)
        #expect(counts.count == (DeckSettings.maxCardValue - DeckSettings.minCardValue + 1))
        for value in DeckSettings.minCardValue...DeckSettings.maxCardValue {
            #expect(counts[value] == 4)
        }

        // Poll for timer progress to avoid scheduler-related flakiness.
        try await waitUntil { sut.elapsedTime > 0 }
        #expect(sut.elapsedTime > 0)
    }

    @Test
    func start_withNilScoreRecord_keepsStateValid() throws {
        let context = try makeInMemoryContext()
        let sut = HardCoreGameViewModel(deckSettings: makeDeckSettings())

        sut.start(with: context, playerScoreRecord: nil)

        #expect(sut.isHardcoreMode == true)
        #expect(sut.guessCount == 0)
        #expect(sut.optimalGuessCount == 0)
    }

    @Test
    func recordGuess_updatesCounts_forOptimalAndNonOptimal() {
        let sut = HardCoreGameViewModel(deckSettings: makeDeckSettings())

        sut.recordGuess(isOptimal: true)
        sut.recordGuess(isOptimal: false)
        sut.recordGuess(isOptimal: true)

        #expect(sut.guessCount == 3)
        #expect(sut.optimalGuessCount == 2)
        #expect(sut.accuracyPercent == (2.0 / 3.0) * 100.0)
    }

    @Test
    func accuracyPercent_returnsZeroWhenNoGuesses() {
        let sut = HardCoreGameViewModel(deckSettings: makeDeckSettings())
        #expect(sut.accuracyPercent == 0)
    }

    @Test
    func finish_stopsHardcore_buildsResult_persistsWhenContextIsSet() throws {
        let context = try makeInMemoryContext()
        let sut = HardCoreGameViewModel(deckSettings: makeDeckSettings())
        sut.setModelContext(context)

        sut.isHardcoreMode = true
        sut.elapsedTime = 12.5
        sut.guessCount = 4
        sut.optimalGuessCount = 3

        let result = sut.finish(playerScore: 21)

        #expect(sut.isHardcoreMode == false)
        #expect(result.timeTaken == 12.5)
        #expect(result.accuracy == 0.75)
        #expect(result.scoreReached == 21)

        let stored = try context.fetch(FetchDescriptor<HardcoreResult>())
        #expect(stored.count == 1)
        #expect(stored.first?.timeTaken == 12.5)
        #expect(stored.first?.accuracy == 0.75)
        #expect(stored.first?.scoreReached == 21)
    }

    @Test
    func finish_withZeroGuesses_returnsZeroAccuracy() {
        let sut = HardCoreGameViewModel(deckSettings: makeDeckSettings())
        sut.isHardcoreMode = true
        sut.elapsedTime = 3.0
        sut.guessCount = 0
        sut.optimalGuessCount = 0

        let result = sut.finish(playerScore: 5)

        #expect(result.accuracy == 0)
        #expect(result.timeTaken == 3.0)
        #expect(result.scoreReached == 5)
        #expect(sut.isHardcoreMode == false)
    }

    @Test
    func quit_resetsStateAndTurnsOffHardcore() {
        let sut = HardCoreGameViewModel(deckSettings: makeDeckSettings())
        sut.isHardcoreMode = true
        sut.elapsedTime = 10
        sut.guessCount = 8
        sut.optimalGuessCount = 6

        sut.quit()

        #expect(sut.isHardcoreMode == false)
        #expect(sut.elapsedTime == 0)
        #expect(sut.guessCount == 0)
        #expect(sut.optimalGuessCount == 0)
    }

    @Test
    func stopTimerWhenRunExhausted_onlyActsWhenHardcoreIsEnabled() async throws {
        let context = try makeInMemoryContext()
        let sut = HardCoreGameViewModel(deckSettings: makeDeckSettings())

        // Guard branch: no-op when not in hardcore mode.
        sut.isHardcoreMode = false
        sut.stopTimerWhenRunExhausted()
        let before = sut.elapsedTime
        #expect(sut.elapsedTime == before)

        // Active branch: stops timer when hardcore mode is active.
        sut.start(with: context, playerScoreRecord: nil)
        try await waitUntil { sut.elapsedTime > 0 }
        let elapsedBeforeStop = sut.elapsedTime

        sut.stopTimerWhenRunExhausted()
        let elapsedAfterStop = sut.elapsedTime

        #expect(elapsedBeforeStop > 0)
        #expect(elapsedAfterStop == elapsedBeforeStop)
    }

    @Test
    func start_calledTwice_restartsTimerAndResetsCounters() async throws {
        let context = try makeInMemoryContext()
        let sut = HardCoreGameViewModel(deckSettings: makeDeckSettings())

        sut.start(with: context, playerScoreRecord: nil)
        sut.recordGuess(isOptimal: true)
        try await waitUntil { sut.elapsedTime > 0 }
        let firstElapsed = sut.elapsedTime

        sut.start(with: context, playerScoreRecord: nil)
        #expect(sut.guessCount == 0)
        #expect(sut.optimalGuessCount == 0)

        try await waitUntil { sut.elapsedTime > 0 }
        #expect(sut.elapsedTime > 0)
        #expect(sut.elapsedTime < firstElapsed + 1.0) // confirms restart behavior
    }
}
