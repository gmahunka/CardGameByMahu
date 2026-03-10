//
//  SetupView.swift
//  CardGameByMahu
//
//  Created by Gergo Mahunka on 2026. 03. 09..
//

import SwiftUI

// A helper struct to track the desired count for each card value
struct CardConfiguration: Identifiable {
    let id: Int // Card value (2...14)
    var count: Int
}

struct SetupView: View {
    // Initialize with a standard deck (4 of each card)
    @State private var cardConfigs: [CardConfiguration] = (2...14).map { CardConfiguration(id: $0, count: 4) }
    
    var body: some View {
        VStack {
            // Header
            HStack {
                Image(systemName: "gearshape.fill")
                    .font(.largeTitle)
                Text("Game Setup")
                    .font(.title)
            }
            .padding(.top)

            // 1. Regular Deck Option
            Button(action: {
                setToRegularDeck()
            }) {
                HStack {
                    Image(systemName: "suit.spade.fill")
                    Text("Regular Deck (4 of each)")
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue)
                .cornerRadius(10)
            }
            .padding(.horizontal)
            .padding(.bottom, 5)
            
            // 2. List of Cards with input boxes
            List($cardConfigs) { $config in
                HStack(alignment: .center) {
                    Spacer(minLength: 0)

                    // Show the actual card image instead of text
                    Image("card\(config.id)")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 70, height: 100)
                        .shadow(radius: 2)
                        .padding(.trailing, 8)


                    Button(action: {
                        if config.count > 0 { config.count -= 1 }
                    }) {
                        Image(systemName: "minus.circle.fill")
                            .font(.system(size: 26, weight: .semibold))
                            .frame(width: 44, height: 44)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Decrease quantity")

                    TextField("Count", value: $config.count, format: .number)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 60)
                        .multilineTextAlignment(.center)

                    Button(action: {
                        if config.count < 12 { config.count += 1 }
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 26, weight: .semibold))
                            .frame(width: 44, height: 44)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Increase quantity")

                    Spacer(minLength: 0)
                }
                .padding(.vertical, 8)
            }
            .listStyle(.plain)
            
            // 3. Apply Button (To hook up later)
            Button(action: {
                // Here is where you'll pass cardConfigs to your ViewModel
                print("Ready to generate deck with these configs!")
            }) {
                Text("Save & Apply")
                    .font(.title3)
                    .bold()
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.green)
                    .cornerRadius(10)
            }
            .padding()
        }
    }
    
    // MARK: - Helpers
    
    private func setToRegularDeck() {
        // Iterate through the array and reset all counts to 4
        for index in cardConfigs.indices {
            cardConfigs[index].count = 4
        }
    }
}

