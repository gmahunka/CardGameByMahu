//
//  TouchBarViewModelTest.swift
//  CardGameByMahuUnitTests
//
//  Created by Gergo Mahunka on 2026. 04. 28..
//

import Foundation
import Testing
@testable import CardGameByMahu

@MainActor
struct TouchBarViewModelTests {
    
    // Simple mock controller to capture actions passed from the view model
    private final class MockController: GameTouchBarControlling {
        var lastDeal: (() -> Void)?
        var lastLower: (() -> Void)?
        var lastEqual: (() -> Void)?
        var lastHigher: (() -> Void)?

        func update(isVisible: Bool, mode: GameTouchBarController.Mode, dealAction: (() -> Void)?, lowerAction: (() -> Void)?, equalAction: (() -> Void)?, higherAction: (() -> Void)?) {
            self.lastDeal = dealAction
            self.lastLower = lowerAction
            self.lastEqual = equalAction
            self.lastHigher = higherAction
        }
    }

    
    @Test
    func touchBarViewModel_startsInvisible() {
        let gameViewModel = CardGameViewModel(deckSettings: DeckSettings())
        let mock = MockController()
        let sut = TouchBarViewModel(gameViewModel: gameViewModel, isPlayTabVisible: false, controller: mock)
        
        #expect(sut.isPlayTabVisible == false)
    }
    
    @Test
    func touchBarViewModel_becomesVisibleWhenTabShown() {
        let gameViewModel = CardGameViewModel(deckSettings: DeckSettings())
        let mock = MockController()
        let sut = TouchBarViewModel(gameViewModel: gameViewModel, isPlayTabVisible: false, controller: mock)
        
        sut.setPlayTabVisible(true)
        
        #expect(sut.isPlayTabVisible == true)
    }
    
    @Test
    func touchBarViewModel_executesDealHandlerWhenSet() {
        let gameViewModel = CardGameViewModel(deckSettings: DeckSettings())
        let mock = MockController()
        let sut = TouchBarViewModel(gameViewModel: gameViewModel, isPlayTabVisible: true, controller: mock)
        
        var dealHandlerCalled = false
        sut.setActionHandlers(
            deal: { dealHandlerCalled = true },
            guess: nil
        )
        
        // Manually trigger refresh to set controller actions
        sut.refresh()

        // Simulate pressing the touch bar deal button
        mock.lastDeal?()

        #expect(dealHandlerCalled == true)
    }
    
    @Test
    func touchBarViewModel_executesGuessHandlerWhenWaitingForGuess() {
        let gameViewModel = CardGameViewModel(deckSettings: DeckSettings())
        let mock = MockController()
        let sut = TouchBarViewModel(gameViewModel: gameViewModel, isPlayTabVisible: true, controller: mock)
        
        var guessHandlerCalled = false
        var passedGuess: Guess?
        
        sut.setActionHandlers(
            deal: nil,
            guess: { guess in
                guessHandlerCalled = true
                passedGuess = guess
            }
        )
        
        // Set up game state to be waiting for guess
        gameViewModel.waitingForGuess = true
        sut.refresh()

        // Simulate pressing the lower guess button on the touch bar
        mock.lastLower?()

        #expect(guessHandlerCalled == true)
        #expect(passedGuess == .lower)  // The first guess option should trigger
    }
    
    @Test
    func touchBarViewModel_hidesWhenPlayTabNotVisible() {
        let gameViewModel = CardGameViewModel(deckSettings: DeckSettings())
        let mock = MockController()
        let sut = TouchBarViewModel(gameViewModel: gameViewModel, isPlayTabVisible: true, controller: mock)
        
        sut.setPlayTabVisible(false)
        
        #expect(sut.isPlayTabVisible == false)
    }
}
