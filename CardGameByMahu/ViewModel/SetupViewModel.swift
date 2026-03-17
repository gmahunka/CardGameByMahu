//
//  SetupViewModel.swift
//  CardGameByMahu
//
//  Created by Gergo Mahunka on 2026. 03. 13..
//
import Foundation
import Observation

struct CardConfiguration: Identifiable {
    let id: Int
    var count: Int
}

@Observable
@MainActor
final class SetupViewModel {
    private let deckSettings: DeckSettings

    init(deckSettings: DeckSettings) {
        self.deckSettings = deckSettings
    }

    var cardConfigs: [CardConfiguration] {
        (DeckSettings.minCardValue...DeckSettings.maxCardValue).map { value in
            CardConfiguration(id: value, count: deckSettings.count(for: value))
        }
    }

    func decreaseCount(for value: Int) {
        let updated = deckSettings.count(for: value) - 1
        deckSettings.setCount(updated, for: value)
    }

    func increaseCount(for value: Int) {
        let updated = deckSettings.count(for: value) + 1
        deckSettings.setCount(updated, for: value)
    }

    func updateCount(_ value: Int, count: Int) {
        deckSettings.setCount(count, for: value)
    }

    func resetToRegularDeck() {
        deckSettings.resetToRegularDeck()
    }
}
