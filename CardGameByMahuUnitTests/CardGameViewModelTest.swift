//
//  CardGameViewModelTest.swift
//  CardGameByMahuUnitTests
//
//  Created by Gergo Mahunka on 2026. 03. 28..
//

import Foundation
import SwiftData
import Testing
@testable import CardGameByMahu

@MainActor
struct CardGameViewModelTest {
    
    private func makeInMemoryContext() throws -> ModelContext {
        let schema = Schema([
            PlayingCard.self,
            HardcoreResult.self,
            RoundHistoryItem.self,
            GameScore.self
        ])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: [config])
        return ModelContext(container)
    }
    
    private func makeDeckSettings() -> DeckSettings { DeckSettings() }
    
    private func makeSUT(deckSettings: DeckSettings? = nil) -> CardGameViewModel {
        CardGameViewModel(deckSettings: deckSettings ?? makeDeckSettings())
    }
    
    private func cardCount(_ context: ModelContext) throws -> Int {
        try context.fetchCount(FetchDescriptor<PlayingCard>())
    }
    
    private func scores(_ context: ModelContext) throws -> [GameScore] {
        try context.fetch(FetchDescriptor<GameScore>())
    }
    
    private func rounds(_ context: ModelContext) throws -> [RoundHistoryItem] {
        try context.fetch(FetchDescriptor<RoundHistoryItem>())
    }
    
    @Test
    func setupGame_emptyDeck_bootstrapsDeckAndScore() throws {
        let context = try makeInMemoryContext()
        let sut = makeSUT()
        
        sut.setupGame(context: context)
        
        #expect(sut.remainingCards == 52)
        #expect(try cardCount(context) == 52)
        let s = try scores(context)
        #expect(s.count == 1)
        #expect(s.first?.playerScore == 0)
        #expect(s.first?.computerScore == 0)
    }
    
    @Test
    func setupGame_existingDeck_justUpdatesCount() throws {
        let context = try makeInMemoryContext()
        context.insert(PlayingCard(value: 2))
        context.insert(PlayingCard(value: 3))
        try context.save()
        
        let sut = makeSUT()
        sut.setupGame(context: context)
        
        #expect(sut.remainingCards == 2)
        #expect(try cardCount(context) == 2)
    }
    
    @Test
    func loadScores_withoutContext_noOp() {
        let sut = makeSUT()
        sut.playerScore = 4
        sut.computerScore = 6
        sut.loadScores()
        #expect(sut.playerScore == 4)
        #expect(sut.computerScore == 6)
    }
    
    @Test
    func loadScores_existingRecord_loadsValues() throws {
        let context = try makeInMemoryContext()
        context.insert(GameScore(playerScore: 9, computerScore: 1))
        try context.save()
        
        let sut = makeSUT()
        sut.modelContext = context
        sut.loadScores()
        
        #expect(sut.playerScore == 9)
        #expect(sut.computerScore == 1)
    }
    
    @Test
    func updateCardCount_withoutContext_noOp() {
        let sut = makeSUT()
        sut.remainingCards = 123
        sut.updateCardCount()
        #expect(sut.remainingCards == 123)
    }
    
    @Test
    func resetDeck_resetsStateAndClearsRoundHistory() throws {
        let context = try makeInMemoryContext()
        let sut = makeSUT()
        sut.setupGame(context: context)
        
        sut.playerScore = 7
        sut.computerScore = 3
        sut.playerCard = "card4"
        sut.computerCard = "card10"
        sut.waitingForGuess = true
        
        context.insert(
            RoundHistoryItem(
                computerCard: "card2",
                playerCard: "card3",
                playerChoiceOption: .higher,
                correctAnswerOption: .higher,
                wasCorrect: true,
                higherChance: 0.4,
                equalChance: 0.2,
                lowerChance: 0.4,
                isHardcoreMode: false
            )
        )
        try context.save()
        
        sut.resetDeck()
        
        #expect(sut.playerScore == 0)
        #expect(sut.computerScore == 0)
        #expect(sut.playerCard == "back")
        #expect(sut.computerCard == "back")
        #expect(sut.waitingForGuess == false)
        #expect(sut.remainingCards == 52)
        #expect(try rounds(context).isEmpty)
    }
    
    @Test
    func startRound_drawsComputerCard_andWaitsForGuess() throws {
        let context = try makeInMemoryContext()
        let sut = makeSUT()
        sut.setupGame(context: context)
        
        sut.startRound()
        
        #expect(sut.waitingForGuess == true)
        #expect(sut.playerCard == "back")
        #expect(sut.computerCard.starts(with: "card"))
        #expect(sut.remainingCards == 51)
    }
    
    @Test
    func startRound_emptyDeck_recursesAfterReset_withCustomDeckSize() throws {
        let context = try makeInMemoryContext()
        let settings = DeckSettings()
        for value in DeckSettings.minCardValue...DeckSettings.maxCardValue {
            settings.setCount(0, for: value)
        }
        settings.setCount(1, for: 7)
        settings.setCount(2, for: 8)
        
        let sut = makeSUT(deckSettings: settings)
        sut.modelContext = context
        sut.loadScores()
        
        #expect(try cardCount(context) == 0)
        
        sut.startRound()
        
        #expect(sut.waitingForGuess == true)
        #expect(sut.computerCard.starts(with: "card"))
        #expect(sut.playerCard == "back")
        #expect(sut.remainingCards == 2)
    }
    
    @Test
    func makeGuess_whenNotWaiting_noOp() throws {
        let context = try makeInMemoryContext()
        let sut = makeSUT()
        sut.setupGame(context: context)
        
        let beforeP = sut.playerScore
        let beforeC = sut.computerScore
        sut.makeGuess(.equal)
        
        #expect(sut.playerScore == beforeP)
        #expect(sut.computerScore == beforeC)
        #expect(try rounds(context).isEmpty)
    }
    
    @Test
    func makeGuess_secondDrawFails_leavesWaitingTrue_andNoRoundSaved() throws {
        let context = try makeInMemoryContext()
        context.insert(PlayingCard(value: 10))
        try context.save()
        
        let sut = makeSUT()
        sut.modelContext = context
        sut.loadScores()
        sut.updateCardCount()
        
        sut.startRound()
        #expect(sut.waitingForGuess == true)
        #expect(sut.remainingCards == 0)
        
        sut.makeGuess(.lower)
        
        #expect(sut.waitingForGuess == true)
        #expect(try rounds(context).isEmpty)
    }
    
    @Test
    func makeGuess_persistsRound_updatesOneSideScore_andEndsTurn() throws {
        let context = try makeInMemoryContext()
        let sut = makeSUT()
        sut.setupGame(context: context)
        
        sut.startRound()
        let beforeP = sut.playerScore
        let beforeC = sut.computerScore
        
        sut.makeGuess(.higher)
        
        #expect(sut.waitingForGuess == false)
        #expect(sut.playerCard.starts(with: "card"))
        let rs = try rounds(context)
        #expect(rs.count == 1)
        
        let dP = sut.playerScore - beforeP
        let dC = sut.computerScore - beforeC
        #expect((dP == 1 && dC == 0) || (dP == 0 && dC == 1))
    }
    
    @Test
    func makeGuess_persistsChanceTuple_thatSumsToOne() throws {
        let context = try makeInMemoryContext()
        let sut = makeSUT()
        sut.setupGame(context: context)
        
        sut.startRound()
        sut.makeGuess(.equal)
        
        let r = try #require(try rounds(context).first)
        #expect(r.higherChance >= 0 && r.higherChance <= 1)
        #expect(r.equalChance >= 0 && r.equalChance <= 1)
        #expect(r.lowerChance >= 0 && r.lowerChance <= 1)
        #expect(abs((r.higherChance + r.equalChance + r.lowerChance) - 1.0) < 0.000001)
    }
    
    @Test
    func hardcoreComputedProperties_exposed() {
        let sut = makeSUT()
        #expect(sut.hardcoreElapsedTime == 0)
        #expect(sut.hardcoreGuessCount == 0)
        #expect(sut.hardcoreOptimalGuessCount == 0)
        #expect(sut.hardcoreAccuracyPercent == 0)
    }
    
    @Test
    func isHardcoreMode_setFalseWhenAlreadyFalse_noOp() {
        let sut = makeSUT()
        sut.isHardcoreMode = false
        #expect(sut.isHardcoreMode == false)
    }
    
    @Test
    func startHardcoreMode_withoutContext_noOp() {
        let sut = makeSUT()
        sut.startHardcoreMode()
        #expect(sut.isHardcoreMode == false)
    }
    
    @Test
    func startHardcoreMode_entersHardcore_andResetsUi() throws {
        let context = try makeInMemoryContext()
        let sut = makeSUT()
        sut.setupGame(context: context)
        
        sut.playerCard = "card4"
        sut.computerCard = "card8"
        sut.waitingForGuess = true
        
        sut.startHardcoreMode()
        
        #expect(sut.isHardcoreMode == true)
        #expect(sut.playerCard == "back")
        #expect(sut.computerCard == "back")
        #expect(sut.waitingForGuess == false)
        #expect(sut.remainingCards == 52)
    }
    
    @Test
    func isHardcoreMode_setTrueWhenAlreadyTrue_noopBranchCovered() throws {
        let context = try makeInMemoryContext()
        let sut = makeSUT()
        sut.setupGame(context: context)
        
        sut.isHardcoreMode = true
        #expect(sut.isHardcoreMode == true)
        let firstRemaining = sut.remainingCards
        
        sut.isHardcoreMode = true
        #expect(sut.isHardcoreMode == true)
        #expect(sut.remainingCards == firstRemaining)
    }
    
    @Test
    func startHardcoreMode_calledTwice_snapshotNotOverwritten_restoresOriginalNormalState() throws {
        let context = try makeInMemoryContext()
        let sut = makeSUT()
        sut.setupGame(context: context)
        
        sut.startRound()
        sut.makeGuess(.higher)
        
        let normalRemaining = sut.remainingCards
        let normalP = sut.playerScore
        let normalC = sut.computerScore
        let normalPlayerCard = sut.playerCard
        let normalComputerCard = sut.computerCard
        let normalWaiting = sut.waitingForGuess
        
        sut.startHardcoreMode()
        #expect(sut.isHardcoreMode == true)
        
        sut.playerScore = 99
        sut.computerScore = 77
        sut.playerCard = "card14"
        sut.computerCard = "card2"
        sut.waitingForGuess = true
        
        sut.startHardcoreMode()
        
        sut.quitHardcoreMode()
        #expect(sut.isHardcoreMode == false)
        
        #expect(sut.remainingCards == normalRemaining)
        #expect(sut.playerScore == normalP)
        #expect(sut.computerScore == normalC)
        #expect(sut.playerCard == normalPlayerCard)
        #expect(sut.computerCard == normalComputerCard)
        #expect(sut.waitingForGuess == normalWaiting)
    }
    
    @Test
    func quitHardcoreMode_withoutSnapshot_fallbackUiReset() {
        let sut = makeSUT()
        sut.playerCard = "card9"
        sut.computerCard = "card10"
        sut.waitingForGuess = true
        
        sut.quitHardcoreMode()
        
        #expect(sut.playerCard == "back")
        #expect(sut.computerCard == "back")
        #expect(sut.waitingForGuess == false)
    }
    
    @Test
    func finishHardcoreMode_savesResult_andExitsHardcore() throws {
        let context = try makeInMemoryContext()
        let sut = makeSUT()
        sut.setupGame(context: context)
        
        sut.startHardcoreMode()
        sut.playerScore = 5
        sut.finishHardcoreMode()
        
        #expect(sut.isHardcoreMode == false)
        let results = try context.fetch(FetchDescriptor<HardcoreResult>())
        #expect(results.count == 1)
        #expect(results.first?.scoreReached == 5)
    }
    
    @Test
    func hardcoreGuess_updatesHardcoreCounters() throws {
        let context = try makeInMemoryContext()
        let sut = makeSUT()
        sut.setupGame(context: context)
        sut.startHardcoreMode()
        
        sut.startRound()
        sut.makeGuess(.equal)
        
        #expect(sut.hardcoreGuessCount >= 1)
        #expect(sut.hardcoreOptimalGuessCount >= 0)
        #expect(sut.hardcoreAccuracyPercent >= 0)
        #expect(sut.hardcoreAccuracyPercent <= 100)
    }
    
    @Test
    func makeGuess_whenCardsMatch_recordsEqualCorrectAnswer() throws {
        let context = try makeInMemoryContext()
        
        // Deterministic deck: first draw (computer) and second draw (player) are both 7.
        context.insert(PlayingCard(value: 7))
        context.insert(PlayingCard(value: 7))
        context.insert(GameScore(playerScore: 0, computerScore: 0))
        try context.save()
        
        let sut = makeSUT()
        sut.modelContext = context
        sut.loadScores()
        sut.updateCardCount()
        
        sut.startRound()
        #expect(sut.waitingForGuess == true)
        #expect(sut.remainingCards == 1)
        
        sut.makeGuess(.equal)
        
        let round = try #require(try rounds(context).first)
        #expect(round.correctAnswerOption == .equal)
        #expect(round.playerChoiceOption == .equal)
        #expect(round.wasCorrect == true)
        #expect(sut.waitingForGuess == false)
    }

    @Test
    func isHardcoreMode_setFalseWhenTrue_routesThroughSetterAndQuitsHardcore() throws {
        let context = try makeInMemoryContext()
        let sut = makeSUT()
        sut.setupGame(context: context)

        // Enter hardcore so the setter's else-if condition can become true.
        sut.startHardcoreMode()
        #expect(sut.isHardcoreMode == true)

        // Mutate visible state to verify quit/restore path executes.
        sut.playerCard = "card9"
        sut.computerCard = "card10"
        sut.waitingForGuess = true

        // Branch under test:
        // else if !newValue && hardCoreGameViewModel.isHardcoreMode { quitHardcoreMode() }
        sut.isHardcoreMode = false

        #expect(sut.isHardcoreMode == false)
        #expect(sut.playerCard == "back")
        #expect(sut.computerCard == "back")
        #expect(sut.waitingForGuess == false)
    }
}


