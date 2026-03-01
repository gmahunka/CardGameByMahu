//
//  ContentView.swift
//  CardGameByMahu
//
//  Created by Gergo Mahunka on 2026. 03. 01..
//

import SwiftUI

struct ContentView: View {
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
                    .padding(.top, 50)
                
                Spacer()
                
                // Cards
                HStack(spacing: 20) {
                    Spacer()
                    Image("card2")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 150)
                        .shadow(radius: 5)
                    Spacer()
                    Image("card3")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 150)
                        .shadow(radius: 5)
                    Spacer()
                }
                
                Spacer()
                
                // Play Button
                Image("button")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 50)
                    .padding(.bottom, 20)
                
                Spacer()
                
                
                HStack {
                    Spacer()
                    VStack{
                        Text("Player")
                            .font(.headline)
                            .padding(.bottom, 10)
                        Text("0")
                            .font(.largeTitle)
                    }
                    Spacer()
                    VStack{
                        Text("Computer")
                            .font(.headline)
                            .padding(.bottom, 10)
                        Text("0")
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

#Preview {
    ContentView()
}

