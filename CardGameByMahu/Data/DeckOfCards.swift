//
//  DeckOfCards.swift
//  CardGameByMahu
//
//  Created by Gergo Mahunka on 2026. 03. 07..
//

import Foundation
import SwiftData

@Model
final class PlayingCard {
    var value: Int
    
    init(value: Int) {
        self.value = value
    }
}
