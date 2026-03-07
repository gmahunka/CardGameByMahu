//
//  ContentView.swift
//  CardGameByMahu
//
//  Created by Gergo Mahunka on 2026. 03. 01..
//

import SwiftUI

struct ContentView: View {
    
    @StateObject private var viewModel = CardGameViewModel()
    
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
                // Logo
                Image("emeles")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 200)
                    .padding(.top, 30)
                
                Spacer()
                
                // Cards
                HStack(spacing: 20) {
                    Spacer()
                    // Player Card
                    ZStack {
                        Image(viewModel.playerCard)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 150)
                            .shadow(radius: 5)
                    }
                    .rotation3DEffect(.degrees(viewModel.isPlayerFlipped ? 180 : 0), axis: (x: 0, y: 1, z: 0), perspective: 0.7)
                    .animation(.easeInOut(duration: 0.4), value: viewModel.isPlayerFlipped)
                    Spacer()
                    // Computer Card
                    ZStack {
                        Image(viewModel.computerCard)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 150)
                            .shadow(radius: 5)
                    }
                    .rotation3DEffect(.degrees(viewModel.isComputerFlipped ? 180 : 0), axis: (x: 0, y: 1, z: 0), perspective: 0.7)
                    .animation(.easeInOut(duration: 0.4), value: viewModel.isComputerFlipped)
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
                        startNewRound()
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
    }
    
    @State private var isFirstPassed = false
    
    private func startNewRound() {
        // Flip computer card
        withAnimation(.easeInOut(duration: 0.2)) {
            viewModel.isComputerFlipped = true
            if isFirstPassed {
                viewModel.isPlayerFlipped = true
            }
            isFirstPassed = true
        }
        
        // At midpoint, deal computer card
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            viewModel.startRound()
            
            // Complete flip animation
            withAnimation(.easeInOut(duration: 0.2)) {
                viewModel.isComputerFlipped = false
                viewModel.isPlayerFlipped = false
            }
        }
    }
    
    private func handleGuess(_ guess: Guess) {
        // Flip player card
        withAnimation(.easeInOut(duration: 0.2)) {
            viewModel.isPlayerFlipped = true
        }
        
        // At midpoint, reveal player card and determine winner
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            viewModel.makeGuess(guess)
            
            // Complete flip animation
            withAnimation(.easeInOut(duration: 0.2)) {
                viewModel.isPlayerFlipped = false
            }
        }
    }
}

#Preview {
    ContentView()
}

