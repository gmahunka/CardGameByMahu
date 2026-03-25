//
//  SetupViewModelTest.swift
//  CardGameByMahuUnitTests
//
//  Created by Gergo Mahunka on 2026. 03. 25..
//

import Testing
@testable import CardGameByMahu

@MainActor
struct SetupViewModelTest {

    @Test("cardConfigs returns all values in configured range")
    func cardConfigsReturnsFullRange() {
        let settings = DeckSettings()
        let sut = SetupViewModel(deckSettings: settings)

        let configs = sut.cardConfigs

        #expect(configs.count == DeckSettings.maxCardValue - DeckSettings.minCardValue + 1)
        #expect(configs.first?.id == DeckSettings.minCardValue)
        #expect(configs.last?.id == DeckSettings.maxCardValue)
    }

    @Test("cardConfigs reflects counts from DeckSettings")
    func cardConfigsReflectSettingsCounts() {
        let settings = DeckSettings()
        settings.setCount(7, for: DeckSettings.minCardValue)
        settings.setCount(2, for: DeckSettings.maxCardValue)
        let sut = SetupViewModel(deckSettings: settings)

        let configs = sut.cardConfigs
        let minConfig = configs.first { $0.id == DeckSettings.minCardValue }
        let maxConfig = configs.first { $0.id == DeckSettings.maxCardValue }

        #expect(minConfig?.count == 7)
        #expect(maxConfig?.count == 2)
    }

    @Test("increaseCount increments the selected card value")
    func increaseCountIncrementsValue() {
        let settings = DeckSettings()
        let sut = SetupViewModel(deckSettings: settings)
        let value = DeckSettings.minCardValue
        let original = settings.count(for: value)

        sut.increaseCount(for: value)

        #expect(settings.count(for: value) == original + 1)
    }

    @Test("decreaseCount decrements the selected card value")
    func decreaseCountDecrementsValue() {
        let settings = DeckSettings()
        let sut = SetupViewModel(deckSettings: settings)
        let value = DeckSettings.minCardValue

        // Ensure we start above any potential lower bound logic.
        settings.setCount(3, for: value)

        sut.decreaseCount(for: value)

        #expect(settings.count(for: value) == 2)
    }

    @Test("updateCount sets exact value")
    func updateCountSetsExactValue() {
        let settings = DeckSettings()
        let sut = SetupViewModel(deckSettings: settings)
        let value = DeckSettings.minCardValue + 1

        sut.updateCount(value, count: 9)

        #expect(settings.count(for: value) == 9)
    }

    @Test("resetToRegularDeck restores defaults")
    func resetToRegularDeckRestoresDefaults() {
        let settings = DeckSettings()
        let sut = SetupViewModel(deckSettings: settings)

        let valueA = DeckSettings.minCardValue
        let valueB = DeckSettings.maxCardValue
        settings.setCount(9, for: valueA)
        settings.setCount(0, for: valueB)

        sut.resetToRegularDeck()

        #expect(settings.count(for: valueA) == 4)
        #expect(settings.count(for: valueB) == 4)
    }
}
