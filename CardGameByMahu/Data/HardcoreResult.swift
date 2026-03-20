//
//  HardcoreResult.swift
//  CardGameByMahu
//
//  Created by Gergo Mahunka on 2026. 03. 20..
//

import Foundation
import SwiftData

@Model
final class HardcoreResult {
    @Attribute(.unique) var id: UUID
    var timeTaken: Double
    var accuracy: Double
    var date: Date

    init(
        id: UUID = UUID(),
        timeTaken: Double,
        accuracy: Double,
        date: Date = .now
    ) {
        self.id = id
        self.timeTaken = timeTaken
        self.accuracy = accuracy
        self.date = date
    }
}
