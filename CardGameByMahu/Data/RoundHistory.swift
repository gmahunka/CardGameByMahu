//
//  RoundHistory.swift
//  CardGameByMahu
//
//  Created by Gergo Mahunka on 2026. 03. 13..
//

import Foundation
import SwiftData

enum GuessOption: String, Codable {
    case higher = "higher"
    case equal = "equal"
    case lower = "lower"
    
    var displayText: String {
        switch self {
        case .higher: return "Higher"
        case .equal: return "Equal"
        case .lower: return "Lower"
        }
    }
}

@Model
final class RoundHistoryItem {
    @Attribute(.unique) var id: UUID
    var computerCard: String
    var playerCard: String
    var playerChoiceRaw: String
    var correctAnswerRaw: String
    var wasCorrect: Bool
    var higherChance: Double
    var equalChance: Double
    var lowerChance: Double
    var createdAt: Date

    var playerChoiceOption: GuessOption? {
        get { GuessOption(rawValue: playerChoiceRaw) }
        set { playerChoiceRaw = newValue?.rawValue ?? "" }
    }

    var correctAnswerOption: GuessOption? {
        get { GuessOption(rawValue: correctAnswerRaw) }
        set { correctAnswerRaw = newValue?.rawValue ?? "" }
    }

    init(
        id: UUID = UUID(),
        computerCard: String,
        playerCard: String,
        playerChoiceOption: GuessOption,
        correctAnswerOption: GuessOption,
        wasCorrect: Bool,
        higherChance: Double,
        equalChance: Double,
        lowerChance: Double,
        createdAt: Date = .now
    ) {
        self.id = id
        self.computerCard = computerCard
        self.playerCard = playerCard
        self.playerChoiceRaw = playerChoiceOption.rawValue
        self.correctAnswerRaw = correctAnswerOption.rawValue
        self.wasCorrect = wasCorrect
        self.higherChance = higherChance
        self.equalChance = equalChance
        self.lowerChance = lowerChance
        self.createdAt = createdAt
    }
}
