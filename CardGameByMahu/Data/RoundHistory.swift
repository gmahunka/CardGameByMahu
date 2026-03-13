//
//  RoundHistory.swift
//  CardGameByMahu
//
//  Created by Gergo Mahunka on 2026. 03. 13..
//

import Foundation

struct RoundHistoryItem: Identifiable {
    let id = UUID()
    let computerCard: String
    let playerCard: String
    let playerChoice: String
    let correctAnswer: String
    let wasCorrect: Bool
    let higherChance: Double
    let equalChance: Double
    let lowerChance: Double
}
