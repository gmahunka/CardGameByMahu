//
//  GameView.swift
//  CardGameByMahu
//
//  Created by Gergo Mahunka on 2026. 03. 09..
//

import SwiftUI
import SwiftData

struct GameView: View {
    
    @Environment(\.modelContext) private var context
    @Bindable var viewModel: CardGameViewModel
    var touchBarViewModel: TouchBarViewModel? = nil
    @State private var showingRules = false
    @State private var showHardcoreOutOfCardsAlert = false
    @State private var voiceService = VoiceCommandService()
    @State private var voiceFeedbackMessage: String?
    @State private var showEnableVoiceConfirmation = false
    @State private var roundTask: Task<Void, Never>?
    @State private var guessTask: Task<Void, Never>?
    @State private var voiceMessageTask: Task<Void, Never>?

    @State private var isFirstPassed = false
    let phaseDuration = 0.3

    @State private var playerRotation: Double = 0
    @State private var computerRotation: Double = 0
    
    @State private var playerScaleEffect: CGFloat = 1.0
    @State private var computerScaleEffect: CGFloat = 1.0

    private func sleep(seconds: Double) async {
        let nanoseconds = UInt64((seconds * 1_000_000_000).rounded())
        try? await Task.sleep(nanoseconds: nanoseconds)
    }
    
    private func triggerScoreAnimation(scale: Binding<CGFloat>) {
        withAnimation(.easeInOut(duration: 0.6)) {
            scale.wrappedValue = 1.3
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.easeInOut(duration: 0.3)) {
                scale.wrappedValue = 1.0
            }
        }
    }

    private func cardStack(imageName: String, rotation: Double, accent: Color, maxWidth: CGFloat = 200, layoutScale: CGFloat = 1.0) -> some View {
        ZStack {
            Image("back")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: maxWidth, maxHeight: maxWidth * 100 / 70)
                .opacity(rotation < 90 ? 1 : 0)
                .rotation3DEffect(.degrees(rotation), axis: (x: 0, y: 1, z: 0), perspective: 0.7)
                .shadow(color: accent.opacity(0.4), radius: 16)

            Image(imageName)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: maxWidth, maxHeight: maxWidth * 100 / 70)
                .opacity(rotation >= 90 ? 1 : 0)
                .rotation3DEffect(.degrees(rotation + 180), axis: (x: 0, y: 1, z: 0), perspective: 0.7)
                .shadow(color: accent.opacity(0.45), radius: 18)
        }
        .padding(10 * layoutScale)
        .background(
            RoundedRectangle(cornerRadius: 20 * layoutScale, style: .continuous)
                .fill(Color.white.opacity(0.04))
                .overlay(
                    RoundedRectangle(cornerRadius: 20 * layoutScale, style: .continuous)
                        .stroke(accent.opacity(0.55), lineWidth: 1.2 * layoutScale)
                )
                .shadow(color: accent.opacity(0.18), radius: 18 * layoutScale)
        )
    }

    private func startNewRound() {
        roundTask?.cancel()
        roundTask = Task { @MainActor in
            // If computer is currently showing its back (180°), normalize to 0 first.
            if computerRotation >= 179 {
                withAnimation(.easeInOut(duration: phaseDuration)) {
                    computerRotation = 0
                }
                await sleep(seconds: phaseDuration)
                guard !Task.isCancelled else { return }
            }

            await proceedDeal(with: phaseDuration)
        }
    }

    private func proceedDeal(with phaseDuration: Double) async {
        // Flip computer to 90° (hide front)
        withAnimation(.easeInOut(duration: phaseDuration)) {
            computerRotation = 90
            if isFirstPassed {
                // Ensure player's card is reset to front for new round
                playerRotation = 0
            }
            isFirstPassed = true
        }

        // Midpoint: deal and complete flip to reveal.
        await sleep(seconds: phaseDuration)
        guard !Task.isCancelled else { return }

        viewModel.startRound()
        withAnimation(.easeInOut(duration: phaseDuration)) {
            computerRotation = 180
        }
    }

    private func handleGuess(_ guess: Guess) {
        guessTask?.cancel()
        guessTask = Task { @MainActor in
            // Animate to 90° (hide front), then swap content, then complete to 180°.
            withAnimation(.easeInOut(duration: phaseDuration)) {
                playerRotation = 90
            }

            await sleep(seconds: phaseDuration)
            guard !Task.isCancelled else { return }

            viewModel.makeGuess(guess)
            withAnimation(.easeInOut(duration: phaseDuration)) {
                playerRotation = 180
            }
        }
    }

    private func handleVoiceCommand(_ command: VoiceCommand) {
        switch command {
        case .deal:
            guard !viewModel.waitingForGuess else {
                showVoiceMessage("Say lower, equal, or higher.")
                return
            }

            if viewModel.remainingCards < 2 {
                if viewModel.isHardcoreMode {
                    showHardcoreOutOfCardsAlert = true
                } else {
                    viewModel.showReshuffleAlert = true
                }
                return
            }

            startNewRound()

        case .lower:
            guard viewModel.waitingForGuess else {
                showVoiceMessage("Say deal to start a round.")
                return
            }
            handleGuess(.lower)

        case .equal:
            guard viewModel.waitingForGuess else {
                showVoiceMessage("Say deal to start a round.")
                return
            }
            handleGuess(.equal)

        case .higher:
            guard viewModel.waitingForGuess else {
                showVoiceMessage("Say deal to start a round.")
                return
            }
            handleGuess(.higher)
        }
    }

    private func showVoiceMessage(_ message: String?) {
        guard let message else { return }
        withAnimation(.easeInOut(duration: 0.2)) {
            voiceFeedbackMessage = message
        }

        voiceMessageTask?.cancel()
        voiceMessageTask = Task { @MainActor in
            await sleep(seconds: 2.0)
            guard !Task.isCancelled else { return }
            guard voiceFeedbackMessage == message else { return }

            withAnimation(.easeInOut(duration: 0.2)) {
                voiceFeedbackMessage = nil
            }
        }
    }

    private func voiceButtonPressed() {
        if voiceService.isVoiceModeEnabled {
            voiceService.disable()
            showVoiceMessage(voiceService.statusMessage)
        } else {
            showEnableVoiceConfirmation = true
        }
    }

    private func enableVoiceConfirmed() {
        voiceService.enable { command in
            handleVoiceCommand(command)
        }
        showVoiceMessage(voiceService.statusMessage)
    }
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            LinearGradient(
                colors: [Color.black.opacity(0.02),
                         Color.black.opacity(0.18)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            GeometryReader { safeAreaGeometry in
                let base = min(safeAreaGeometry.size.width, safeAreaGeometry.size.height)
                let layoutScale = max(0.65, min(1.6, base / 700))
                let sectionGap = max(4, safeAreaGeometry.size.height * 0.012 * layoutScale)
                let headerControlHeight = max(58, 70 * layoutScale)

                ZStack(alignment: .top) {
                    // Logo as background
                    VStack {
                        Spacer()
                            .frame(height: max(28 * layoutScale, safeAreaGeometry.size.height * 0.12 * layoutScale))
                        
                        Image("emeles")
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: safeAreaGeometry.size.height * 0.25 * layoutScale)
                            .opacity(0.5)
                            .shadow(color: CyberpunkTheme.cyan.opacity(0.08), radius: 16 * layoutScale)
                        
                        Spacer()
                    }
                    .ignoresSafeArea(edges: .bottom)
                    
                    // Content on top
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 0) {
                    // Unified Header Bar
                    HStack(alignment: .center, spacing: 0) {
                        // Unified Header Bar
                        if viewModel.isHardcoreMode {
                            Button {
                                viewModel.quitHardcoreMode()
                            } label: {
                                VStack(spacing: 2) {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.system(size: 16, weight: .semibold))
                                    Text("Quit")
                                        .font(.caption2.weight(.semibold))
                                }
                                .frame(maxHeight: .infinity)
                            }
                            .buttonStyle(CompactNeonButtonStyle(accent: CyberpunkTheme.magenta))
                            .accessibilityIdentifier("quitHardcoreButton")
                            .frame(maxWidth: .infinity, minHeight: headerControlHeight, maxHeight: headerControlHeight, alignment: .leading)
                            
                            // Voice Toggle Button (still available during Hardcore)
                            Button {
                                voiceButtonPressed()
                            } label: {
                                VStack(spacing: 2) {
                                    Image(systemName: voiceService.isVoiceModeEnabled ? "mic.fill" : "mic")
                                        .font(.system(size: 16, weight: .semibold))
                                    Text("Voice")
                                        .font(.caption2.weight(.semibold))
                                }
                                .frame(maxHeight: .infinity)
                                .foregroundStyle(voiceService.isVoiceModeEnabled ? CyberpunkTheme.cyan : CyberpunkTheme.cyan.opacity(0.4))
                            }
                            .buttonStyle(CompactNeonButtonStyle(accent: CyberpunkTheme.cyan, isPulsing: voiceService.isVoiceModeEnabled))
                            .accessibilityIdentifier("voiceCommandToggle")
                            .accessibilityLabel(voiceService.isVoiceModeEnabled ? "Disable Voice Commands" : "Enable Voice Commands")
                            .frame(maxWidth: .infinity, minHeight: headerControlHeight, maxHeight: headerControlHeight, alignment: .center)
                            
                            VStack(alignment: .trailing, spacing: 1) {
                                Text("Hardcore Mode")
                                    .font(.system(size: 12 * layoutScale, weight: .bold, design: .rounded))
                                    .foregroundStyle(CyberpunkTheme.magenta)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.75)
                                Text(String(format: "Time: %.1fs", viewModel.hardcoreElapsedTime))
                                    .font(.system(size: 16 * layoutScale, weight: .bold, design: .rounded))
                                    .monospacedDigit()
                                    .foregroundStyle(CyberpunkTheme.textPrimary)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.75)
                                Text(String(format: "Optimal guesses: %.1f%%", viewModel.hardcoreAccuracyPercent))
                                    .font(.system(size: 15 * layoutScale, weight: .semibold, design: .rounded))
                                    .foregroundStyle(CyberpunkTheme.textSecondary)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.7)
                            }
                            .fixedSize(horizontal: false, vertical: true)
                            .frame(maxWidth: 170, minHeight: headerControlHeight, maxHeight: headerControlHeight, alignment: .trailing)
                            .cyberPanel(accent: CyberpunkTheme.magenta, fillOpacity: 0.08, contentPadding: 8)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                        } else {
                            // Normal header controls
                            // Hardcore Mode Button
                            Button {
                                viewModel.isHardcoreMode = true
                            } label: {
                                VStack(spacing: 2) {
                                    Image(systemName: "flame.fill")
                                        .font(.system(size: 16, weight: .semibold))
                                    Text("Hardcore")
                                        .font(.caption2.weight(.semibold))
                                }
                                .frame(maxHeight: .infinity)
                            }
                            .buttonStyle(CompactNeonButtonStyle(accent: CyberpunkTheme.magenta))
                            .accessibilityIdentifier("hardcoreModeButton")
                            .accessibilityLabel(viewModel.isHardcoreMode ? "Disable Hardcore Mode" : "Enable Hardcore Mode")
                            .frame(maxWidth: .infinity, minHeight: headerControlHeight, maxHeight: headerControlHeight, alignment: .leading)
                            
                            // Voice Toggle Button
                            Button {
                                voiceButtonPressed()
                            } label: {
                                VStack(spacing: 2) {
                                    Image(systemName: voiceService.isVoiceModeEnabled ? "mic.fill" : "mic")
                                        .font(.system(size: 16, weight: .semibold))
                                    Text("Voice")
                                        .font(.caption2.weight(.semibold))
                                }
                                .frame(maxHeight: .infinity)
                                .foregroundStyle(voiceService.isVoiceModeEnabled ? CyberpunkTheme.cyan : CyberpunkTheme.cyan.opacity(0.4))
                            }
                            .buttonStyle(CompactNeonButtonStyle(accent: CyberpunkTheme.cyan, isPulsing: voiceService.isVoiceModeEnabled))
                            .accessibilityIdentifier("voiceCommandToggle")
                            .accessibilityLabel(voiceService.isVoiceModeEnabled ? "Disable Voice Commands" : "Enable Voice Commands")
                            .frame(maxWidth: .infinity, minHeight: headerControlHeight, maxHeight: headerControlHeight, alignment: .center)
                            
                            // Info Button
                            Button {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    showingRules = true
                                }
                            } label: {
                                Image(systemName: "info.circle.fill")
                                    .font(.system(size: 18, weight: .semibold))
                                    .frame(maxHeight: .infinity)
                            }
                            .buttonStyle(CompactNeonButtonStyle(accent: CyberpunkTheme.cyan, isIconOnly: true))
                            .accessibilityIdentifier("showRulesButton")
                            .frame(maxWidth: .infinity, minHeight: headerControlHeight, maxHeight: headerControlHeight, alignment: .trailing)
                        }
                    }
                    .frame(height: max(68, 82 * layoutScale))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Color.white.opacity(0.04))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .stroke(
                                        LinearGradient(
                                            gradient: Gradient(colors: [
                                                CyberpunkTheme.cyan.opacity(0.4),
                                                CyberpunkTheme.magenta.opacity(0.3)
                                            ]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 1.2
                                    )
                            )
                            .shadow(color: CyberpunkTheme.cyan.opacity(0.15), radius: 12, x: 0, y: 4)
                    )
                    .padding(.horizontal, 16)
                            .padding(.vertical, sectionGap * 0.5)

                            Spacer(minLength: sectionGap)
                    
                    HStack(spacing: 12 * layoutScale) {
                        VStack(alignment: .leading) {
                            Text("Cards Remaining")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(CyberpunkTheme.textSecondary)
                            Text("\(viewModel.remainingCards)")
                                .font(.system(size: safeAreaGeometry.size.height * 0.06 * layoutScale, weight: .bold, design: .rounded))
                                .monospacedDigit()
                                .foregroundStyle(CyberpunkTheme.cyan)
                        }
                        .cyberPanel(accent: CyberpunkTheme.cyan, fillOpacity: 0.06, scale: layoutScale)

                        if !viewModel.isHardcoreMode {
                            Spacer()
                            Button {
                                viewModel.resetDeck()
                            } label: {
                                Label("Reshuffle", systemImage: "arrow.triangle.2.circlepath")
                            }
                            .buttonStyle(NeonButtonStyle(accent: CyberpunkTheme.magenta, fillOpacity: 0.10, cornerRadius: 12, fillsWidth: false))
                        }
                    }
                    .padding(.horizontal, 16 * layoutScale)
                    Spacer(minLength: sectionGap)
                    
                    GeometryReader { geometry in
                        let availableWidth = geometry.size.width
                        let cardWidth = max(min(availableWidth * 0.36, safeAreaGeometry.size.height * 0.28), 100)
                        
                        HStack(spacing: 12 * layoutScale) {
                            Spacer()
                            cardStack(imageName: viewModel.playerCard, rotation: playerRotation, accent: CyberpunkTheme.cyan, maxWidth: cardWidth, layoutScale: layoutScale)
                            
                            Spacer()

                            cardStack(imageName: viewModel.computerCard, rotation: computerRotation, accent: CyberpunkTheme.magenta, maxWidth: cardWidth, layoutScale: layoutScale)
                            
                            Spacer()
                        }
                        .padding(.horizontal, 8 * layoutScale)
                        .padding(.vertical, 4 * layoutScale)
                    }
                    .frame(height: safeAreaGeometry.size.height * 0.28)

                    Spacer(minLength: sectionGap)
                    
                    if viewModel.waitingForGuess {
                        HStack(spacing: 8 * layoutScale) {
                            Button {
                                handleGuess(.lower)
                            } label: {
                                Text("LOWER")
                            }
                            .buttonStyle(NeonButtonStyle(accent: CyberpunkTheme.cyan, fillOpacity: 0.12, cornerRadius: 12, fillsWidth: true, scale: layoutScale))
                            .keyboardShortcut(.leftArrow, modifiers: [])
                            .accessibilityIdentifier("lowerButton")
                            
                            Button {
                                handleGuess(.equal)
                            } label: {
                                Text("EQUAL")
                            }
                            .buttonStyle(NeonButtonStyle(accent: CyberpunkTheme.magenta, fillOpacity: 0.11, cornerRadius: 12, fillsWidth: true, scale: layoutScale))
                            .keyboardShortcut(.downArrow, modifiers: [])
                            .accessibilityIdentifier("equalButton")
                            
                            Button {
                                handleGuess(.higher)
                            } label: {
                                Text("HIGHER")
                            }
                            .buttonStyle(NeonButtonStyle(accent: CyberpunkTheme.cyan, fillOpacity: 0.12, cornerRadius: 12, fillsWidth: true, scale: layoutScale))
                            .keyboardShortcut(.rightArrow, modifiers: [])
                            .accessibilityIdentifier("higherButton")
                        }
                        .padding(.horizontal, 16 * layoutScale)
                        .padding(.vertical, sectionGap)
                    } else {
                        Button {
                            if viewModel.remainingCards < 2 {
                                if viewModel.isHardcoreMode {
                                    // In hardcore, don't auto-finish; require explicit quit via alert.
                                    showHardcoreOutOfCardsAlert = true
                                } else {
                                    viewModel.showReshuffleAlert = true
                                }
                            } else {
                                startNewRound()
                            }
                        } label: {
                            Label("DEAL", systemImage: "bolt.fill")
                        }
                        .buttonStyle(NeonButtonStyle(accent: CyberpunkTheme.cyan, fillOpacity: 0.16, cornerRadius: 16, fillsWidth: true, scale: layoutScale))
                        .accessibilityIdentifier("dealButton")
                        .accessibilityLabel("Deal")
                        .keyboardShortcut(.space, modifiers: [])
                        .frame(width: max(240, safeAreaGeometry.size.width * 0.5))
                        .padding(.vertical, sectionGap)
                    }

                    Spacer(minLength: sectionGap)
                    
                    HStack(spacing: 12 * layoutScale) {
                        VStack(spacing: 6 * layoutScale) {
                            Text("Player")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(CyberpunkTheme.textSecondary)
                            Text("\(viewModel.playerScore)")
                                .font(.system(size: safeAreaGeometry.size.height * 0.06 * layoutScale, weight: .bold, design: .rounded))
                                .monospacedDigit()
                                .foregroundStyle(CyberpunkTheme.cyan)
                                .scaleEffect(playerScaleEffect)
                                .onChange(of: viewModel.playerScore) { _, _ in
                                    triggerScoreAnimation(scale: $playerScaleEffect)
                                }
                        }
                        .frame(maxWidth: min(300, safeAreaGeometry.size.width * 0.46))
                        .cyberPanel(accent: CyberpunkTheme.cyan, fillOpacity: 0.06, scale: layoutScale)

                        Spacer()

                        VStack(spacing: 6 * layoutScale) {
                            Text("Computer")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(CyberpunkTheme.textSecondary)
                            Text("\(viewModel.computerScore)")
                                .font(.system(size: safeAreaGeometry.size.height * 0.06 * layoutScale, weight: .bold, design: .rounded))
                                .monospacedDigit()
                                .foregroundStyle(CyberpunkTheme.magenta)
                                .scaleEffect(computerScaleEffect)
                                .onChange(of: viewModel.computerScore) { _, _ in
                                    triggerScoreAnimation(scale: $computerScaleEffect)
                                }
                        }
                        .frame(maxWidth: min(300, safeAreaGeometry.size.width * 0.46))
                        .cyberPanel(accent: CyberpunkTheme.magenta, fillOpacity: 0.06, scale: layoutScale)
                    }
                    .padding(.horizontal, 16 * layoutScale)

                    Spacer(minLength: sectionGap)
                }
                .frame(minHeight: safeAreaGeometry.size.height, alignment: .top)
                .padding(.vertical, sectionGap * 0.5)
                    }
                }
            }
        }
        .onAppear {
            viewModel.setupGame(context: context)
            touchBarViewModel?.setActionHandlers(
                deal: { startNewRound() },
                guess: { guess in handleGuess(guess) }
            )
            touchBarViewModel?.refresh()
        }
        .onDisappear {
            roundTask?.cancel()
            guessTask?.cancel()
            voiceMessageTask?.cancel()
            voiceService.disable()
            touchBarViewModel?.setActionHandlers(deal: nil, guess: nil)
        }
        .onChange(of: voiceService.statusMessage) { _, newValue in
            showVoiceMessage(newValue)
        }
        .alert("Out of Cards", isPresented: $viewModel.showReshuffleAlert) {
            Button("Reshuffle Deck", role: .none) {
                viewModel.resetDeck()
            }
            .accessibilityIdentifier("reshuffleAlertButton")
            .accessibilityLabel("Reshuffle Deck Alert")
            Button("Cancel", role: .cancel) { }
                .accessibilityIdentifier("reshuffleAlertCancelButton")
                .accessibilityLabel("Cancel Reshuffle Alert")
        } message: {
            Text("You need at least 2 cards to play a round. Please reshuffle the deck to continue.")
        }
        .alert("Hardcore Run Finished", isPresented: $showHardcoreOutOfCardsAlert) {
            Button("Quit Hardcore", role: .destructive) {
                viewModel.finishHardcoreMode()
            }
            .accessibilityIdentifier("quitHardcoreButtonAfterFinish")
            Button("Cancel", role: .cancel) { }
            .accessibilityIdentifier("quitHardcoreButtonCancel")

        } message: {
            Text("You have run out of cards in Hardcore mode. You must quit to continue.")
        }
        .alert("Enable Voice Commands", isPresented: $showEnableVoiceConfirmation) {
            Button("Enable") {
                enableVoiceConfirmed()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Voice commands are optional. We request microphone and speech recognition only to hear commands like deal, lower, equal, and higher. You can always play using the on-screen buttons.")
        }
        .overlay {
            if showingRules {
                ZStack {
                    Color.black.opacity(0.72)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation { showingRules = false }
                        }
                    
                    VStack(spacing: 20) {
                        Text("Game Rules")
                            .font(.title.weight(.heavy))
                            .foregroundStyle(CyberpunkTheme.cyan)
                        
                        VStack(alignment: .leading, spacing: 16) {
                            RuleItem(icon: "1.circle", text: "The computer deals a card. You must guess if your next card is higher, lower, or equal.")
                            RuleItem(icon: "2.circle", text: "Correct guesses earn you a point. Incorrect guesses give a point to the computer.")
                            RuleItem(icon: "3.circle", text: "The game continues until the deck is empty. You can reshuffle at any time, but it will also reset the scores.")
                        }
                        .frame(maxWidth: 350) // Controls text width for better wrapping
                        
                        Button("Dismiss") {
                            withAnimation { showingRules = false }
                        }
                        .buttonStyle(NeonButtonStyle(accent: CyberpunkTheme.magenta, fillOpacity: 0.14, cornerRadius: 12, fillsWidth: false))
                        .accessibilityIdentifier("dismissRulesButton")
                        .accessibilityLabel("Dismiss Rules")
                        .padding(.top, 10)
                    }
                    .padding(32)
                    .background(
                        RoundedRectangle(cornerRadius: 24)
                            .fill(Color.black.opacity(0.82))
                            .overlay(
                                RoundedRectangle(cornerRadius: 24)
                                    .stroke(CyberpunkTheme.cyan.opacity(0.5), lineWidth: 1.2)
                            )
                            .shadow(color: CyberpunkTheme.cyan.opacity(0.18), radius: 22)
                    )
                    .transition(.opacity.combined(with: .scale(scale: 0.95)))
                }
            }
        }
        .overlay(alignment: .top) {
            if let voiceFeedbackMessage {
                Text(voiceFeedbackMessage)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(CyberpunkTheme.textPrimary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.black.opacity(0.78))
                    .overlay(
                        Capsule()
                            .stroke(CyberpunkTheme.cyan.opacity(0.75), lineWidth: 1)
                    )
                    .clipShape(Capsule())
                    .padding(.top, 8)
                    .transition(.opacity)
                    .accessibilityIdentifier("voiceCommandFeedback")
            }
        }

    }


}

// Helper View for wrapping text
struct RuleItem: View {
    var icon: String
    var text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(CyberpunkTheme.cyan)
                .font(.headline)
            
            Text(text)
                .font(.body)
                .lineLimit(nil)            // Allows unlimited lines
                .fixedSize(horizontal: false, vertical: true) // Forces vertical expansion instead of horizontal
                .multilineTextAlignment(.leading)
                .foregroundStyle(CyberpunkTheme.textPrimary)
        }
    }
}

#Preview {
    ContentView(navigation: AppNavigationModel())
        .modelContainer(for: PlayingCard.self, inMemory: true)
}
