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
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) {
                    // Unified Header Bar
                    HStack(spacing: 0) {
                        // Hardcore Mode Button
                        if !viewModel.isHardcoreMode {
                            Button {
                                viewModel.isHardcoreMode = true
                            } label: {
                                VStack(spacing: 2) {
                                    Image(systemName: "flame.fill")
                                        .font(.system(size: 16, weight: .semibold))
                                    Text("Hardcore")
                                        .font(.caption2.weight(.semibold))
                                }
                                .frame(height: 44)
                            }
                            .buttonStyle(CompactNeonButtonStyle(accent: CyberpunkTheme.magenta))
                        }
                        
                        Spacer()
                        
                        // Voice Toggle Button
                        Button {
                            voiceService.toggle { command in
                                handleVoiceCommand(command)
                            }
                            showVoiceMessage(voiceService.statusMessage)
                        } label: {
                            VStack(spacing: 2) {
                                Image(systemName: voiceService.isVoiceModeEnabled ? "mic.fill" : "mic")
                                    .font(.system(size: 16, weight: .semibold))
                                Text("Voice")
                                    .font(.caption2.weight(.semibold))
                            }
                            .frame(height: 44)
                        }
                        .buttonStyle(CompactNeonButtonStyle(accent: voiceService.isVoiceModeEnabled ? CyberpunkTheme.cyan : CyberpunkTheme.panelStroke))
                        .accessibilityIdentifier("voiceCommandToggle")
                        .accessibilityLabel(voiceService.isVoiceModeEnabled ? "Disable Voice Commands" : "Enable Voice Commands")
                        
                        Spacer()
                        
                        // Info Button
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                showingRules = true
                            }
                        } label: {
                            Image(systemName: "info.circle.fill")
                                .font(.system(size: 18, weight: .semibold))
                                .frame(width: 44, height: 44)
                        }
                        .buttonStyle(CompactNeonButtonStyle(accent: CyberpunkTheme.cyan, isIconOnly: true))
                        .accessibilityIdentifier("showRulesButton")
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
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
                    .padding(.horizontal, 12)
                    .padding(.vertical, 12)
                    
                    Image("emeles")
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 100)
                        .shadow(color: CyberpunkTheme.cyan.opacity(0.28), radius: 16)
                    
                    HStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Cards Remaining")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(CyberpunkTheme.textSecondary)
                            Text("\(viewModel.remainingCards)")
                                .font(.system(size: 28, weight: .bold, design: .rounded))
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
                    .padding(.horizontal, 16)
                    
                    HStack(spacing: 12) {
                        Spacer()
                        cardStack(imageName: viewModel.playerCard, rotation: playerRotation, accent: CyberpunkTheme.cyan)
                        
                        Spacer()

                        cardStack(imageName: viewModel.computerCard, rotation: computerRotation, accent: CyberpunkTheme.magenta)
                        
                        Spacer()
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 6)
                    
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
                    }
                    
                    HStack(spacing: 12) {
                        VStack(spacing: 6) {
                            Text("Player")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(CyberpunkTheme.textSecondary)
                            Text("\(viewModel.playerScore)")
                                .font(.system(size: 30, weight: .bold, design: .rounded))
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
                                .font(.system(size: 30, weight: .bold, design: .rounded))
                                .monospacedDigit()
                                .foregroundStyle(CyberpunkTheme.magenta)
                        }
                        .frame(maxWidth: .infinity)
                        .cyberPanel(accent: CyberpunkTheme.magenta, fillOpacity: 0.06)
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 8)
                }
                .padding(.vertical, 12)
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

    private func cardStack(imageName: String, rotation: Double, accent: Color) -> some View {
        ZStack {
            Image("back")
                .resizable()
                .scaledToFit()
                .frame(maxHeight: 128)
                .opacity(rotation < 90 ? 1 : 0)
                .rotation3DEffect(.degrees(rotation), axis: (x: 0, y: 1, z: 0), perspective: 0.7)
                .shadow(color: accent.opacity(0.4), radius: 16)

            Image(imageName)
                .resizable()
                .scaledToFit()
                .frame(maxHeight: 128)
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
    
    @State private var isFirstPassed = false
    let phaseDuration = 0.3
    
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
    
    @State private var playerRotation: Double = 0
    @State private var computerRotation: Double = 0
    
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
