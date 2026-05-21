//
//  DeckOfCards.swift
//  CardGameByMahu
//
//  Created by Gergo Mahunka on 2026. 03. 07..
//
//  Purpose: Defines the lightweight persistent `PlayingCard` model
//  used by the game's deck. Each instance represents a single card
//  value; deck operations insert/delete these models in the
//  `ModelContext` store.

import Foundation
import SwiftData

@Model
final class PlayingCard {
    /// Numeric value for the playing card. Values range between
    /// `DeckSettings.minCardValue` and `DeckSettings.maxCardValue`.
    var value: Int

    init(value: Int) {
        self.value = value
    }
}
