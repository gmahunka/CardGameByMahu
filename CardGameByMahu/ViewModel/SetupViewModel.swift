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

    var cardConfigs: [CardConfiguration]

    init(deckSettings: DeckSettings) {
        self.deckSettings = deckSettings
        self.cardConfigs = (DeckSettings.minCardValue...DeckSettings.maxCardValue).map { value in
            CardConfiguration(id: value, count: deckSettings.count(for: value))
        }
    }

    func decreaseCount(for value: Int) {
        updateCount(value, count: count(for: value) - 1)
    }

    func increaseCount(for value: Int) {
        updateCount(value, count: count(for: value) + 1)
    }

    func updateCount(_ value: Int, count: Int) {
        deckSettings.setCount(count, for: value)
        if let index = cardConfigs.firstIndex(where: { $0.id == value }) {
            cardConfigs[index].count = deckSettings.count(for: value)
        }
    }

    func resetToRegularDeck() {
        deckSettings.resetToRegularDeck()
        syncFromDeckSettings()
    }

    private func count(for value: Int) -> Int {
        cardConfigs.first(where: { $0.id == value })?.count ?? deckSettings.count(for: value)
    }

    private func syncFromDeckSettings() {
        for index in cardConfigs.indices {
            let value = cardConfigs[index].id
            cardConfigs[index].count = deckSettings.count(for: value)
        }
    }
}
