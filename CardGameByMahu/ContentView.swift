//
//  ContentView.swift
//  CardGameByMahu
//
//  Created by Gergo Mahunka on 2026. 03. 01..
//

import SwiftUI

struct ContentView: View {
    
    @State var playerScore = 0
    @State var computerScore = 0

    @State var playerCard = "back"
    @State var computerCard = "back"
    
    @State private var isPlayerFlipped: Bool = false
    @State private var isComputerFlipped: Bool = false

    @State private var lastPlayerValue: Int = 0
    @State private var lastComputerValue: Int = 0
    
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
                    ZStack {
                        Image(playerCard)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 150)
                            .shadow(radius: 5)
                    }
                    .rotation3DEffect(.degrees(isPlayerFlipped ? 180 : 0), axis: (x: 0, y: 1, z: 0), perspective: 0.7)
                    .animation(.easeInOut(duration: 0.4), value: isPlayerFlipped)
                    Spacer()
                    ZStack {
                        Image(computerCard)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 150)
                            .shadow(radius: 5)
                    }
                    .rotation3DEffect(.degrees(isComputerFlipped ? 180 : 0), axis: (x: 0, y: 1, z: 0), perspective: 0.7)
                    .animation(.easeInOut(duration: 0.4), value: isComputerFlipped)
                    Spacer()
                }
                
                Spacer()
                
                Button {
                    // Start flip to 90°
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isPlayerFlipped.toggle()
                        isComputerFlipped.toggle()
                    }
                    // Midpoint: swap faces only (no scoring yet)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        dealCardFacesOnly()
                        withAnimation(.easeInOut(duration: 0.2)) {
                            // complete to 180° (already toggled once)
                            isPlayerFlipped.toggle()
                            isComputerFlipped.toggle()
                        }
                        // End: reset flip then update score from stored values
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                            isPlayerFlipped = false
                            isComputerFlipped = false
                            updateScoreFromLastDeal()
                        }
                    }
                } label: {
                    // Deal Button
                    Image("button")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 50)
                }
                Spacer()
                    
                HStack {
                    Spacer()
                    VStack{
                        Text("Player")
                            .font(.headline)
                            .padding(.bottom, 10)
                        Text(String(playerScore))
                            .font(.largeTitle)
                    }
                    Spacer()
                    VStack{
                        Text("Computer")
                            .font(.headline)
                            .padding(.bottom, 10)
                        Text(String(computerScore))
                            .font(.largeTitle)
                    }
                    Spacer()
                }
                .padding(.bottom, 50)
                .foregroundColor(.white)
            }
        }
    }
    
    private func dealCardFacesOnly() {
        let playerCardValue = Int.random(in: 2...14)
        lastPlayerValue = playerCardValue
        playerCard = "card" + String(playerCardValue)
        let computerCardValue = Int.random(in: 2...14)
        lastComputerValue = computerCardValue
        computerCard = "card" + String(computerCardValue)
    }

    private func updateScoreFromLastDeal() {
        if lastPlayerValue > lastComputerValue {
            playerScore += 1
        } else if lastComputerValue > lastPlayerValue {
            computerScore += 1
        }
    }

    func dealCards() {
        dealCardFacesOnly()
        updateScoreFromLastDeal()
    }
}

#Preview {
    ContentView()
}

#Preview {
    ContentView()
}

