//
//  VoiceCommandService.swift
//  CardGameByMahu
//
//  Created by Gergo Mahunka on 2026. 04. 27..
//
//  Purpose: Provides an encapsulated service for enabling voice
//  commands using `Speech` and `AVFoundation`. Handles authorization
//  flows for speech recognition and microphone access, starts/stops
//  recognition sessions, and debounces parsed commands before
//  dispatching them to the consumer via a callback.

import Foundation
import Observation
import AVFoundation
import Speech

enum VoiceCommand: String, CaseIterable {
    case deal
    case lower
    case equal
    case higher
}

struct VoiceCommandParser {
    private let cooldown: TimeInterval
    private var lastDispatch: (command: VoiceCommand, timestamp: Date)?

    init(cooldown: TimeInterval = 0.7) {
        self.cooldown = cooldown
    }

    mutating func nextCommand(from transcript: String, now: Date = .now) -> VoiceCommand? {
        guard let candidate = latestCommand(in: transcript) else { return nil }

        if let lastDispatch,
           lastDispatch.command == candidate,
           now.timeIntervalSince(lastDispatch.timestamp) < cooldown {
            return nil
        }

        self.lastDispatch = (candidate, now)
        return candidate
    }

    private func latestCommand(in transcript: String) -> VoiceCommand? {
        let lowered = transcript.lowercased()
        let nsRange = NSRange(lowered.startIndex..<lowered.endIndex, in: lowered)
        guard let regex = try? NSRegularExpression(pattern: #"\b(deal|lower|equal|higher)\b"#,
                                                   options: [.caseInsensitive]) else {
            return nil
        }

        guard let lastMatch = regex.matches(in: lowered, options: [], range: nsRange).last,
              let commandRange = Range(lastMatch.range(at: 1), in: lowered) else {
            return nil
        }

        return VoiceCommand(rawValue: String(lowered[commandRange]))
    }
}

/// Service that manages speech recognition lifecycle and translates
/// transcripts into `VoiceCommand` values. Consumers should call
/// `toggle(onCommand:)` to enable/disable and receive command events.
///
/// - Entitlements: The app must request Microphone (and optionally
///   Speech Recognition) permission in the system settings; see
///   `CardGameByMahu.entitlements` for required entries.
@MainActor
@Observable
final class VoiceCommandService {
    var isVoiceModeEnabled: Bool = false
    var isListening: Bool = false
    var statusMessage: String?

    private let speechRecognizer: SFSpeechRecognizer?
    private let audioEngine = AVAudioEngine()
    private let isUITesting: Bool

    private var request: SFSpeechAudioBufferRecognitionRequest?
    private var task: SFSpeechRecognitionTask?
    private var authorizationTask: Task<Void, Never>?
    private var parser = VoiceCommandParser()
    private var shouldRemainEnabled: Bool = false
    private var onCommand: ((VoiceCommand) -> Void)?

    init(locale: Locale = Locale(identifier: "en-US"), isUITesting: Bool = ProcessInfo.processInfo.arguments.contains("-uitesting")) {
        self.speechRecognizer = SFSpeechRecognizer(locale: locale)
        self.isUITesting = isUITesting
    }

    func toggle(onCommand: @escaping (VoiceCommand) -> Void) {
        if isVoiceModeEnabled {
            disable()
        } else {
            enable(onCommand: onCommand)
        }
    }

    func enable(onCommand: @escaping (VoiceCommand) -> Void) {
        self.onCommand = onCommand
        shouldRemainEnabled = true
        statusMessage = nil

        if isUITesting {
            isVoiceModeEnabled = true
            isListening = true
            statusMessage = "Voice commands enabled."
            return
        }

        authorizationTask?.cancel()
        authorizationTask = Task { [weak self] in
            await self?.startListeningIfAuthorized()
        }
    }

    func disable() {
        shouldRemainEnabled = false
        isVoiceModeEnabled = false
        isListening = false
        authorizationTask?.cancel()
        authorizationTask = nil
        stopRecognitionSession()
        onCommand = nil
        parser = VoiceCommandParser()
        statusMessage = "Voice commands disabled."
    }

    private func startListeningIfAuthorized() async {
        guard !Task.isCancelled else { return }

        guard let speechRecognizer else {
            statusMessage = "Speech recognition is unavailable on this device."
            shouldRemainEnabled = false
            return
        }

        guard speechRecognizer.isAvailable else {
            statusMessage = "Speech recognition is currently unavailable."
            shouldRemainEnabled = false
            return
        }

        guard !Task.isCancelled else { return }

        let speechStatus = await requestSpeechAuthorization()
        guard !Task.isCancelled else { return }
        guard speechStatus == .authorized else {
            shouldRemainEnabled = false
            isVoiceModeEnabled = false
            isListening = false
            statusMessage = "Speech permission denied. Enable it in System Settings > Privacy & Security > Speech Recognition."
            return
        }

        guard !Task.isCancelled else { return }

        let microphoneAllowed = await requestMicrophoneAuthorization()
        guard !Task.isCancelled else { return }
        guard microphoneAllowed else {
            shouldRemainEnabled = false
            isVoiceModeEnabled = false
            isListening = false
            statusMessage = "Microphone permission denied. Enable it in System Settings > Privacy & Security > Microphone."
            return
        }

        do {
            try startRecognitionSession(with: speechRecognizer)
            isVoiceModeEnabled = true
            isListening = true
            statusMessage = "Voice commands enabled."
        } catch {
            shouldRemainEnabled = false
            isVoiceModeEnabled = false
            isListening = false
            statusMessage = "Unable to start voice commands right now."
        }

        authorizationTask = nil
    }

    private func startRecognitionSession(with recognizer: SFSpeechRecognizer) throws {
        stopRecognitionSession()
        parser = VoiceCommandParser()

        let request = SFSpeechAudioBufferRecognitionRequest()
        request.shouldReportPartialResults = true
        self.request = request

        let inputNode = audioEngine.inputNode
        let format = inputNode.outputFormat(forBus: 0)
        inputNode.removeTap(onBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: format) { buffer, _ in
            request.append(buffer)
        }

        audioEngine.prepare()
        try audioEngine.start()

        task = recognizer.recognitionTask(with: request) { [weak self] result, error in
            Task { @MainActor in
                self?.handleRecognition(result: result, error: error)
            }
        }
    }

    private func stopRecognitionSession() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        request?.endAudio()
        request = nil
        task?.cancel()
        task = nil
    }

    private func handleRecognition(result: SFSpeechRecognitionResult?, error: Error?) {
        // Dispatch the next detected command, if any. The parser enforces
        // a small cooldown to avoid repeated events from partial results.
        if let transcript = result?.bestTranscription.formattedString,
           let command = parser.nextCommand(from: transcript) {
            onCommand?(command)
        }

        if error != nil {
            isListening = false
            stopRecognitionSession()

            guard shouldRemainEnabled, !isUITesting else { return }
            Task { [weak self] in
                await self?.startListeningIfAuthorized()
            }
        }
    }

    private func requestSpeechAuthorization() async -> SFSpeechRecognizerAuthorizationStatus {
        await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                continuation.resume(returning: status)
            }
        }
    }

    private func requestMicrophoneAuthorization() async -> Bool {
        await withCheckedContinuation { continuation in
            AVCaptureDevice.requestAccess(for: .audio) { granted in
                continuation.resume(returning: granted)
            }
        }
    }
}
