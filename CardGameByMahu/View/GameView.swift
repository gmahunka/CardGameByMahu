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
    @State private var showingRules = false
    
    var body: some View {
        
        ZStack(alignment: .topLeading) {
            Color(nsColor: .gray)
                .ignoresSafeArea()

            if !viewModel.isHardcoreMode {
                Button {
                    viewModel.isHardcoreMode = true
                } label: {
                    Label("Hardcore Mode", systemImage: "flame.fill")
                        .font(.subheadline.bold())
                        .foregroundStyle(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.red.opacity(0.8))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .padding(.top, 20)
                .padding(.leading, 20)
                .zIndex(2)
            }
            
            // Subtle global tint for UI readability
            LinearGradient(
                colors: [Color.black.opacity(0.08),
                         Color.black.opacity(0.18)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 12) {
                    
                    HStack {
                        Spacer()
                        // Info Button
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                showingRules = true
                            }
                        } label: {
                            Image(systemName: "info.circle.fill")
                                .font(.title2)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        .buttonStyle(.plain)
                        .padding(.trailing, 12)
                        .padding(.top, 12)
                    }
                    
                    // Logo
                    Image("emeles")
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 100)
                    
                    HStack(spacing: 8) {
                        Text("Cards: \(viewModel.remainingCards)")
                            .font(.subheadline)
                            .foregroundColor(.white)
                                                if !viewModel.isHardcoreMode {
                            Spacer()
                            Button {
                                viewModel.resetDeck()
                            } label: {
                                HStack(spacing: 4) {
                                    Image(systemName: "arrow.triangle.2.circlepath")
                                    Text("Reshuffle")
                                }
                                .font(.caption.bold())
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 6)
                                .background(Color.orange.opacity(0.8))
                                .cornerRadius(6)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    
                    // Cards
                    HStack(spacing: 12) {
                        Spacer()
                        // Player Card
                        ZStack {
                            Image("back")
                                .resizable()
                                .scaledToFit()
                                .frame(maxHeight: 120)
                                .opacity(playerRotation < 90 ? 1 : 0)
                                .rotation3DEffect(.degrees(playerRotation), axis: (x: 0, y: 1, z: 0), perspective: 0.7)
                            
                            Image(viewModel.playerCard)
                                .resizable()
                                .scaledToFit()
                                .frame(maxHeight: 120)
                                .opacity(playerRotation >= 90 ? 1 : 0)
                                .rotation3DEffect(.degrees(playerRotation + 180), axis: (x: 0, y: 1, z: 0), perspective: 0.7)
                        }
                        
                        Spacer()
                        
                        // Computer Card
                        ZStack {
                            Image("back")
                                .resizable()
                                .scaledToFit()
                                .frame(maxHeight: 120)
                                .opacity(computerRotation < 90 ? 1 : 0)
                                .rotation3DEffect(.degrees(computerRotation), axis: (x: 0, y: 1, z: 0), perspective: 0.7)
                            
                            Image(viewModel.computerCard)
                                .resizable()
                                .scaledToFit()
                                .frame(maxHeight: 120)
                                .opacity(computerRotation >= 90 ? 1 : 0)
                                .rotation3DEffect(.degrees(computerRotation + 180), axis: (x: 0, y: 1, z: 0), perspective: 0.7)
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal, 8)
                    
                    // Button section
                    if viewModel.waitingForGuess {
                        HStack(spacing: 8) {
                            Button {
                                handleGuess(.lower)
                            } label: {
                                Text("Lower")
                                    .font(.caption.bold())
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 40)
                                    .background(Color.blue)
                                    .cornerRadius(8)
                            }
                            
                            Button {
                                handleGuess(.equal)
                            } label: {
                                Text("Equal")
                                    .font(.caption.bold())
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 40)
                                    .background(Color.green)
                                    .cornerRadius(8)
                            }
                            
                            Button {
                                handleGuess(.higher)
                            } label: {
                                Text("Higher")
                                    .font(.caption.bold())
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 40)
                                    .background(Color.red)
                                    .cornerRadius(8)
                            }
                        }
                        .padding(.horizontal, 16)
                    } else {
                        Button {
                            if viewModel.remainingCards < 2 {
                                if viewModel.isHardcoreMode {
                                    viewModel.finishHardcoreMode()
                                } else {
                                    viewModel.showReshuffleAlert = true
                                }
                            } else {
                                startNewRound()
                            }
                        } label: {
                            Image("button")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 44)
                        }
                    }
                    
                    HStack(spacing: 16) {
                        VStack(spacing: 4) {
                            Text("Player")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                            Text(String(viewModel.playerScore))
                                .font(.title2.bold())
                                .foregroundColor(.white)
                        }
                        Spacer()
                        VStack(spacing: 4) {
                            Text("Computer")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                            Text(String(viewModel.computerScore))
                                .font(.title2.bold())
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                }
            }
        }
        .onAppear {
            viewModel.setupGame(context: context)
        }
        .onChange(of: viewModel.isHardcoreMode) { _, isHardcore in
            guard isHardcore else { return }
            viewModel.startHardcoreMode()
        }
        .alert("Out of Cards!", isPresented: $viewModel.showReshuffleAlert) {
            Button("Reshuffle Deck", role: .none) {
                viewModel.resetDeck()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("You need at least 2 cards to play a round. Please reshuffle the deck to continue.")
        }
        .overlay {
            if showingRules {
                ZStack {
                    // Full screen shading
                    Color.black.opacity(0.6)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation { showingRules = false }
                        }
                    
                    // Rules Card
                    VStack(spacing: 20) {
                        Text("Game Rules")
                            .font(.title).bold()
                        
                        VStack(alignment: .leading, spacing: 16) {
                            RuleItem(icon: "1.circle", text: "The computer deals a card. You must guess if your next card is higher, lower, or equal.")
                            RuleItem(icon: "2.circle", text: "Correct guesses earn you a point. Incorrect guesses give a point to the computer.")
                            RuleItem(icon: "3.circle", text: "The game continues until the deck is empty. You can reshuffle at any time, but it will also reset the scores.")
                        }
                        .frame(maxWidth: 350) // Controls text width for better wrapping
                        
                        Button("Dismiss") {
                            withAnimation { showingRules = false }
                        }
                        .buttonStyle(.borderedProminent)
                        .padding(.top, 10)
                    }
                    .padding(40)
                    .background(
                        RoundedRectangle(cornerRadius: 24)
                            .fill(Color(NSColor.windowBackgroundColor))
                            .shadow(color: .black.opacity(0.3), radius: 20)
                    )
                    .transition(.opacity.combined(with: .scale(scale: 0.95)))
                }
            }
        }
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
}

// Helper View for wrapping text
struct RuleItem: View {
    var icon: String
    var text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.orange)
                .font(.headline)
            
            Text(text)
                .font(.body)
                .lineLimit(nil)            // Allows unlimited lines
                .fixedSize(horizontal: false, vertical: true) // Forces vertical expansion instead of horizontal
                .multilineTextAlignment(.leading)
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: PlayingCard.self, inMemory: true)
}
