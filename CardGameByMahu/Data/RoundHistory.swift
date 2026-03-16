//
//  RoundHistory.swift
//  CardGameByMahu
//
//  Created by Gergo Mahunka on 2026. 03. 13..
//

import Foundation
import SwiftData

@Model
final class RoundHistoryItem {
    @Attribute(.unique) var id: UUID
    var computerCard: String
    var playerCard: String
    var playerChoice: String
    var correctAnswer: String
    var wasCorrect: Bool
    var higherChance: Double
    var equalChance: Double
    var lowerChance: Double
    var createdAt: Date

    init(
        id: UUID = UUID(),
        computerCard: String,
        playerCard: String,
        playerChoice: String,
        correctAnswer: String,
        wasCorrect: Bool,
        higherChance: Double,
        equalChance: Double,
        lowerChance: Double,
        createdAt: Date = .now
    ) {
        self.id = id
        self.computerCard = computerCard
        self.playerCard = playerCard
        self.playerChoice = playerChoice
        self.correctAnswer = correctAnswer
        self.wasCorrect = wasCorrect
        self.higherChance = higherChance
        self.equalChance = equalChance
        self.lowerChance = lowerChance
        self.createdAt = createdAt
    }
}
