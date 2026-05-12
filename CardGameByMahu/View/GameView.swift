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

    @State private var isFirstPassed = false
    let phaseDuration = 0.3

    @State private var playerRotation: Double = 0
    @State private var computerRotation: Double = 0

    private func cardStack(imageName: String, rotation: Double, accent: Color, maxWidth: CGFloat = 200) -> some View {
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
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.white.opacity(0.04))
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(accent.opacity(0.55), lineWidth: 1.2)
                )
                .shadow(color: accent.opacity(0.18), radius: 18)
        )
    }

    private func startNewRound() {
        // If computer is currently showing its back (180°), normalize to 0 first
        if computerRotation >= 179 { // tolerate precision
            withAnimation(.easeInOut(duration: phaseDuration)) {
                computerRotation = 0
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + phaseDuration) {
                proceedDeal(with: phaseDuration)
            }
        } else {
            proceedDeal(with: phaseDuration)
        }
    }

    private func proceedDeal(with phaseDuration: Double) {
        // Flip computer to 90° (hide front)
        withAnimation(.easeInOut(duration: phaseDuration)) {
            computerRotation = 90
            if isFirstPassed {
                // Ensure player's card is reset to front for new round
                playerRotation = 0
            }
            isFirstPassed = true
        }
        // Midpoint: deal and complete flip to reveal
        DispatchQueue.main.asyncAfter(deadline: .now() + phaseDuration) {
            viewModel.startRound()
            withAnimation(.easeInOut(duration: phaseDuration)) {
                computerRotation = 180
            }
        }
    }

    private func handleGuess(_ guess: Guess) {
        // Animate to 90° (hide front), then swap content, then complete to 180°.
        withAnimation(.easeInOut(duration: phaseDuration)) {
            playerRotation = 90
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + phaseDuration) {
            viewModel.makeGuess(guess) // swap to revealed card content here
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

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
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
            CyberBackdrop()
            
            LinearGradient(
                colors: [Color.black.opacity(0.02),
                         Color.black.opacity(0.18)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            GeometryReader { safeAreaGeometry in
                let sectionGap = max(10, safeAreaGeometry.size.height * 0.012)

                ZStack(alignment: .top) {
                    // Logo as background
                    VStack {
                        Spacer()
                            .frame(height: max(40, safeAreaGeometry.size.height * 0.15))
                        
                        Image("emeles")
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: safeAreaGeometry.size.height * 0.25)
                            .opacity(0.5)
                            .shadow(color: CyberpunkTheme.cyan.opacity(0.08), radius: 16)
                        
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
                            .frame(maxWidth: .infinity, alignment: .leading)
                            
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
                            }
                            .buttonStyle(CompactNeonButtonStyle(accent: voiceService.isVoiceModeEnabled ? CyberpunkTheme.cyan : CyberpunkTheme.panelStroke))
                            .accessibilityIdentifier("voiceCommandToggle")
                            .accessibilityLabel(voiceService.isVoiceModeEnabled ? "Disable Voice Commands" : "Enable Voice Commands")
                            .frame(maxWidth: .infinity, alignment: .center)
                            
                            VStack(alignment: .trailing, spacing: 4) {
                                Text("Hardcore Mode")
                                    .font(.headline.weight(.bold))
                                    .foregroundStyle(CyberpunkTheme.magenta)
                                Text(String(format: "Time: %.1fs", viewModel.hardcoreElapsedTime))
                                    .font(.title3.bold())
                                    .monospacedDigit()
                                    .foregroundStyle(CyberpunkTheme.textPrimary)
                                Text(String(format: "Optimal guesses: %.1f%%", viewModel.hardcoreAccuracyPercent))
                                    .font(.caption)
                                    .foregroundStyle(CyberpunkTheme.textSecondary)
                            }
                            .frame(maxHeight: .infinity)
                            .cyberPanel(accent: CyberpunkTheme.magenta, fillOpacity: 0.08)
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
                            .frame(maxWidth: .infinity, alignment: .leading)
                            
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
                            }
                            .buttonStyle(CompactNeonButtonStyle(accent: voiceService.isVoiceModeEnabled ? CyberpunkTheme.cyan : CyberpunkTheme.panelStroke))
                            .accessibilityIdentifier("voiceCommandToggle")
                            .accessibilityLabel(voiceService.isVoiceModeEnabled ? "Disable Voice Commands" : "Enable Voice Commands")
                            .frame(maxWidth: .infinity, alignment: .center)
                            
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
                            .frame(maxWidth: .infinity, alignment: .trailing)
                        }
                    }
                    .frame(height: 80)
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
                    
                    HStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Cards Remaining")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(CyberpunkTheme.textSecondary)
                            Text("\(viewModel.remainingCards)")
                                .font(.system(size: min(28, safeAreaGeometry.size.height * 0.08), weight: .bold, design: .rounded))
                                .monospacedDigit()
                                .foregroundStyle(CyberpunkTheme.cyan)
                        }
                        .cyberPanel(accent: CyberpunkTheme.cyan, fillOpacity: 0.06)

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
                    .padding(.horizontal, 30)
                    .padding(.vertical, 4)

                    Spacer(minLength: sectionGap)
                    
                    GeometryReader { geometry in
                        let availableWidth = geometry.size.width
                        let cardWidth = min(availableWidth * 0.35, safeAreaGeometry.size.height * 0.2)
                        
                        HStack(spacing: 12) {
                            Spacer()
                            cardStack(imageName: viewModel.playerCard, rotation: playerRotation, accent: CyberpunkTheme.cyan, maxWidth: cardWidth)
                            
                            Spacer()

                            cardStack(imageName: viewModel.computerCard, rotation: computerRotation, accent: CyberpunkTheme.magenta, maxWidth: cardWidth)
                            
                            Spacer()
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 12)
                    }
                    .frame(height: safeAreaGeometry.size.height * 0.32)

                    Spacer(minLength: sectionGap)
                    
                    if viewModel.waitingForGuess {
                        HStack(spacing: 8) {
                            Button {
                                handleGuess(.lower)
                            } label: {
                                Text("LOWER")
                            }
                            .buttonStyle(NeonButtonStyle(accent: CyberpunkTheme.cyan, fillOpacity: 0.12, cornerRadius: 12, fillsWidth: true))
                            .keyboardShortcut(.leftArrow, modifiers: [])
                            
                            Button {
                                handleGuess(.equal)
                            } label: {
                                Text("EQUAL")
                            }
                            .buttonStyle(NeonButtonStyle(accent: CyberpunkTheme.magenta, fillOpacity: 0.11, cornerRadius: 12, fillsWidth: true))
                            .keyboardShortcut(.downArrow, modifiers: [])
                            
                            Button {
                                handleGuess(.higher)
                            } label: {
                                Text("HIGHER")
                            }
                            .buttonStyle(NeonButtonStyle(accent: CyberpunkTheme.cyan, fillOpacity: 0.12, cornerRadius: 12, fillsWidth: true))
                            .keyboardShortcut(.rightArrow, modifiers: [])
                        }
                        .padding(.horizontal, 16)
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
                        .buttonStyle(NeonButtonStyle(accent: CyberpunkTheme.cyan, fillOpacity: 0.16, cornerRadius: 16, fillsWidth: true))
                        .accessibilityIdentifier("dealButton")
                        .accessibilityLabel("Deal")
                        .keyboardShortcut(.space, modifiers: [])
                        .padding(.horizontal, 16)
                        .padding(.vertical, sectionGap)
                    }

                    Spacer(minLength: sectionGap)
                    
                    HStack(spacing: 12) {
                        VStack(spacing: 6) {
                            Text("Player")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(CyberpunkTheme.textSecondary)
                            Text("\(viewModel.playerScore)")
                                .font(.system(size: min(30, safeAreaGeometry.size.height * 0.07), weight: .bold, design: .rounded))
                                .monospacedDigit()
                                .foregroundStyle(CyberpunkTheme.cyan)
                        }
                        .frame(maxWidth: .infinity)
                        .cyberPanel(accent: CyberpunkTheme.cyan, fillOpacity: 0.06)

                        Spacer()

                        VStack(spacing: 6) {
                            Text("Computer")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(CyberpunkTheme.textSecondary)
                            Text("\(viewModel.computerScore)")
                                .font(.system(size: min(30, safeAreaGeometry.size.height * 0.07), weight: .bold, design: .rounded))
                                .monospacedDigit()
                                .foregroundStyle(CyberpunkTheme.magenta)
                        }
                        .frame(maxWidth: .infinity)
                        .cyberPanel(accent: CyberpunkTheme.magenta, fillOpacity: 0.06)
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, sectionGap * 0.5)

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
            Button("Cancel", role: .cancel) { }
                .accessibilityIdentifier("reshuffleAlertCancelButton")
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
            Text("Allow microphone access to use voice commands.")
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
