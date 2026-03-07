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
                
                Button {
                    // Start flip to 90°
                    withAnimation(.easeInOut(duration: 0.2)) {
                        viewModel.isPlayerFlipped.toggle()
                        viewModel.isComputerFlipped.toggle()
                    }
                    // Midpoint: swap faces only (no scoring yet)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        viewModel.dealFacesOnly()
                        withAnimation(.easeInOut(duration: 0.2)) {
                            // complete to 180° (already toggled once)
                            viewModel.isPlayerFlipped.toggle()
                            viewModel.isComputerFlipped.toggle()
                        }
                        // End: reset flip then update score from stored values
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                            viewModel.isPlayerFlipped = false
                            viewModel.isComputerFlipped = false
                            viewModel.updateScoreFromLastDeal()
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
}

#Preview {
    ContentView()
}

