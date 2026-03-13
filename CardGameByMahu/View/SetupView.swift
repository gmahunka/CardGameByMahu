//
//  SetupView.swift
//  CardGameByMahu
//
//  Created by Gergo Mahunka on 2026. 03. 09..
//

import SwiftUI

struct SetupView: View {
    @Bindable var viewModel: SetupViewModel
    let onApply: () -> Void

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
                viewModel.resetToRegularDeck()
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
            List(viewModel.cardConfigs) { config in
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
                        viewModel.decreaseCount(for: config.id)
                    }) {
                        Image(systemName: "minus.circle.fill")
                            .font(.system(size: 26, weight: .semibold))
                            .frame(width: 44, height: 44)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Decrease quantity")

                    TextField(
                        "Count",
                        value: Binding(
                            get: { config.count },
                            set: { newValue in viewModel.updateCount(config.id, count: newValue) }
                        ),
                        format: .number
                    )
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 60)
                        .multilineTextAlignment(.center)

                    Button(action: {
                        viewModel.increaseCount(for: config.id)
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
            
            // 3. Apply Button
            Button(action: {
                onApply()
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
}
