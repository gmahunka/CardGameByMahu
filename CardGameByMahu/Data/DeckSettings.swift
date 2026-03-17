//
//  DeckSettings.swift
//  CardGameByMahu
//
//  Created by Gergo Mahunka on 2026. 03. 13..
//
import Foundation
import Observation

@Observable
@MainActor
final class DeckSettings {
    static let minCardValue = 2
    static let maxCardValue = 14
    static let regularCount = 4
    static let maxCount = 12

    var cardCounts: [Int: Int]

    init() {
        var defaults: [Int: Int] = [:]
        for value in Self.minCardValue...Self.maxCardValue {
            defaults[value] = Self.regularCount
        }
        self.cardCounts = defaults
    }

    func count(for value: Int) -> Int {
        cardCounts[value] ?? 0
    }

    func setCount(_ count: Int, for value: Int) {
        guard (Self.minCardValue...Self.maxCardValue).contains(value) else { return }
        cardCounts[value] = max(0, min(Self.maxCount, count))
    }

    func resetToRegularDeck() {
        for value in Self.minCardValue...Self.maxCardValue {
            cardCounts[value] = Self.regularCount
        }
    }
}
