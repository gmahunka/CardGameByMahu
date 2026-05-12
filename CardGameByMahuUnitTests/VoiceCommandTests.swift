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

    @Test
    mutating func parser_handlesMixedCaseAndPunctuation() {
        var sut = VoiceCommandParser(cooldown: 0)

        let command = sut.nextCommand(from: "DeAl, please!")

        #expect(command == .deal)
    }

    @Test
    mutating func parser_ignoresPartialWordMatches() {
        var sut = VoiceCommandParser(cooldown: 0)

        let command = sut.nextCommand(from: "dealer, lowering, equality, highered")

        #expect(command == nil)
    }

    @Test
    mutating func parser_allowsCommandAtCooldownBoundary() {
        var sut = VoiceCommandParser(cooldown: 0.7)
        let now = Date(timeIntervalSinceReferenceDate: 100)

        let first = sut.nextCommand(from: "deal", now: now)
        let second = sut.nextCommand(from: "deal", now: now.addingTimeInterval(0.7))

        #expect(first == .deal)
        #expect(second == .deal)
    }
}

@MainActor
struct VoiceCommandServiceTests {

    private func waitUntil(
        attempts: Int = 80,
        intervalNanoseconds: UInt64 = 10_000_000,
        _ condition: @MainActor () -> Bool
    ) async -> Bool {
        for _ in 0..<attempts {
            if condition() { return true }
            try? await Task.sleep(nanoseconds: intervalNanoseconds)
        }

        return condition()
    }

    @Test
    func service_enableInUITestingSetsExpectedState() {
        let sut = VoiceCommandService(isUITesting: true)
        var receivedCommand: VoiceCommand?

        sut.enable { receivedCommand = $0 }

        #expect(sut.isVoiceModeEnabled)
        #expect(sut.isListening)
        #expect(sut.statusMessage == "Voice commands enabled.")
        #expect(receivedCommand == nil)
    }

    @Test
    func service_disableAfterUITestingEnableClearsState() {
        let sut = VoiceCommandService(isUITesting: true)
        sut.enable { _ in }

        sut.disable()

        #expect(!sut.isVoiceModeEnabled)
        #expect(!sut.isListening)
        #expect(sut.statusMessage == "Voice commands disabled.")
    }

    @Test
    func service_toggleInUITestingSwitchesEnabledState() {
        let sut = VoiceCommandService(isUITesting: true)
        var commands: [VoiceCommand] = []

        sut.toggle { commands.append($0) }
        #expect(sut.isVoiceModeEnabled)
        #expect(sut.isListening)

        sut.toggle { commands.append($0) }
        #expect(!sut.isVoiceModeEnabled)
        #expect(!sut.isListening)
        #expect(commands.isEmpty)
    }

    @Test
    func service_enableWithUnsupportedLocale_reportsUnavailableAndStaysDisabled() async {
        let sut = VoiceCommandService(locale: Locale(identifier: "zz-ZZ"), isUITesting: false)

        sut.enable { _ in }

        let completed = await waitUntil {
            sut.statusMessage != nil
        }

        #expect(completed)
        #expect(sut.statusMessage == "Speech recognition is unavailable on this device.")
        #expect(!sut.isVoiceModeEnabled)
        #expect(!sut.isListening)
    }
}
