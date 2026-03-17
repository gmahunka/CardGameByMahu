//
//  ScoreCount.swift
//  CardGameByMahu
//
//  Created by Gergo Mahunka on 2026. 03. 07..
//

import Foundation
import SwiftData

@Model
final class GameScore {
    var playerScore: Int
    var computerScore: Int
    
    init(playerScore: Int = 0, computerScore: Int = 0) {
        self.playerScore = playerScore
        self.computerScore = computerScore
    }
}
