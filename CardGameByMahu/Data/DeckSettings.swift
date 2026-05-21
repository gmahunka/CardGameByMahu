//
//  DeckSettings.swift
//  CardGameByMahu
//
//  Created by Gergo Mahunka on 2026. 03. 13..
//
//  Purpose: Encapsulates configuration for constructing decks. Provides
//  sensible defaults for a regular deck and enforces value/count
//  invariants (card values from `minCardValue` to `maxCardValue`, and
//  counts clamped to 0...`maxCount`).
import Foundation
import Observation

/// Configuration object describing how many copies of each card value
/// should exist when building a deck. Use `resetToRegularDeck()` to
/// restore a standard 4-per-value deck.
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
