//
//  VoiceCommandTests.swift
//  CardGameByMahuUnitTests
//
//  Created by Gergo Mahunka on 2026. 04. 26..
//

import Foundation
import Testing
@testable import CardGameByMahu

struct VoiceCommandParserTests {

    @Test
    mutating func parser_detectsBasicCommands() {
        var sut = VoiceCommandParser(cooldown: 0)

        #expect(sut.nextCommand(from: "deal") == .deal)
        #expect(sut.nextCommand(from: "lower") == .lower)
        #expect(sut.nextCommand(from: "equal") == .equal)
        #expect(sut.nextCommand(from: "higher") == .higher)
    }

    @Test
    mutating func parser_usesLatestMatchFromSentence() {
        var sut = VoiceCommandParser(cooldown: 0)

        let command = sut.nextCommand(from: "deal then maybe higher")

        #expect(command == .higher)
    }

    @Test
    mutating func parser_ignoresUnknownWords() {
        var sut = VoiceCommandParser(cooldown: 0)

        let command = sut.nextCommand(from: "shuffle now")

        #expect(command == nil)
    }

    @Test
    mutating func parser_debouncesDuplicateCommandWithinCooldown() {
        var sut = VoiceCommandParser(cooldown: 0.7)
        let now = Date(timeIntervalSinceReferenceDate: 100)

        let first = sut.nextCommand(from: "deal", now: now)
        let second = sut.nextCommand(from: "deal", now: now.addingTimeInterval(0.3))
        let third = sut.nextCommand(from: "deal", now: now.addingTimeInterval(0.9))

        #expect(first == .deal)
        #expect(second == nil)
        #expect(third == .deal)
    }
}
