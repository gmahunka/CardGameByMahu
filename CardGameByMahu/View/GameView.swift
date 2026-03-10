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
    @StateObject private var viewModel = CardGameViewModel()
    @State private var showingRules = false
    
    var body: some View {
        
        ZStack {
            // Background with better macOS appearance
            Image("background-wood-grain")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            // Semi-transparent overlay for better UI contrast
            Color.black.opacity(0.15)
                .ignoresSafeArea()
            VStack() {
                
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
                    .padding(.trailing, 20)
                    .padding(.top, 10)
                }
                
                // Logo
                Image("emeles")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 200)
                    .padding(.top, 20)
                HStack {
                    Text("Cards in Deck: \(viewModel.remainingCards)")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button {
                        // Manually trigger a deck reset
                        viewModel.resetDeck()
                    } label: {
                        HStack {
                            Image(systemName: "arrow.triangle.2.circlepath")
                            Text("Reshuffle")
                        }
                        .font(.subheadline).bold()
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.orange.opacity(0.8))
                        .cornerRadius(8)
                    }
                }
                .padding(.horizontal, 30)
                Spacer()
                
                // Cards
                HStack(spacing: 20) {
                    Spacer()
                    // Player Card
                    ZStack {
                        // Front (hidden face/back) — visible for 0...89°
                        Image("back")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 150)
                            .opacity(playerRotation < 90 ? 1 : 0)
                            .rotation3DEffect(.degrees(playerRotation), axis: (x: 0, y: 1, z: 0), perspective: 0.7)
                        
                        // Back (revealed face) — visible for 90...180°
                        Image(viewModel.playerCard)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 150)
                            .opacity(playerRotation >= 90 ? 1 : 0)
                            .rotation3DEffect(.degrees(playerRotation + 180), axis: (x: 0, y: 1, z: 0), perspective: 0.7)
                    }
                    
                    Spacer()
                    
                    // Computer Card (two-sided flip)
                    ZStack {
                        // Front (hidden face/back) — visible for 0...89°
                        Image("back")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 150)
                            .opacity(computerRotation < 90 ? 1 : 0)
                            .rotation3DEffect(.degrees(computerRotation), axis: (x: 0, y: 1, z: 0), perspective: 0.7)
                        
                        // Back (revealed face) — visible for 90...180°
                        Image(viewModel.computerCard)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 150)
                            .opacity(computerRotation >= 90 ? 1 : 0)
                            .rotation3DEffect(.degrees(computerRotation + 180), axis: (x: 0, y: 1, z: 0), perspective: 0.7)
                    }
                    
                    Spacer()
                }
                
                Spacer()
                
                // Button section - Three guess buttons or start button
                if viewModel.waitingForGuess {
                    // Three guess buttons
                    HStack(spacing: 20) {
                        // Lower Button
                        Button {
                            handleGuess(.lower)
                        } label: {
                            Text("Lower")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(width: 100, height: 50)
                                .background(Color.blue)
                                .cornerRadius(10)
                                .shadow(radius: 3)
                        }
                        
                        // Equal Button
                        Button {
                            handleGuess(.equal)
                        } label: {
                            Text("Equal")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(width: 100, height: 50)
                                .background(Color.green)
                                .cornerRadius(10)
                                .shadow(radius: 3)
                        }
                        
                        // Higher Button
                        Button {
                            handleGuess(.higher)
                        } label: {
                            Text("Higher")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(width: 100, height: 50)
                                .background(Color.red)
                                .cornerRadius(10)
                                .shadow(radius: 3)
                        }
                    }
                } else {
                    // Start Round Button
                    Button {
                        if viewModel.remainingCards < 2 {
                            viewModel.showReshuffleAlert = true
                        } else {
                            startNewRound()
                        }
                    } label: {
                        Image("button")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 50)
                    }
                }
                
                Spacer()
                
                HStack {
                    Spacer()
                    VStack{
                        Text("Player")
                            .font(.headline)
                            .padding(.bottom, 10)
                        Text(String(viewModel.playerScore))
                            .font(.largeTitle)
                    }
                    Spacer()
                    VStack{
                        Text("Computer")
                            .font(.headline)
                            .padding(.bottom, 10)
                        Text(String(viewModel.computerScore))
                            .font(.largeTitle)
                    }
                    Spacer()
                }
                .padding(.bottom, 50)
                .foregroundColor(.white)
            }
        }
        .onAppear {
            viewModel.setupGame(context: context)
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

