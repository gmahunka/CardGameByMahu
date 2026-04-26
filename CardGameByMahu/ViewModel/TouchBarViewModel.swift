//
//  TouchBarViewModel.swift
//  CardGameByMahu
//
//  Created by Gergo Mahunka on 2026. 04. 26..
//

import Foundation
import Observation

@MainActor
@Observable
final class TouchBarViewModel {
    private weak var gameViewModel: CardGameViewModel?
    private let controller: GameTouchBarController
    private var dealHandler: (() -> Void)?
    private var guessHandler: ((Guess) -> Void)?

    var isPlayTabVisible: Bool {
        didSet { refresh() }
    }

    init(
        gameViewModel: CardGameViewModel,
        isPlayTabVisible: Bool = false,
        controller: GameTouchBarController? = nil
    ) {
        self.gameViewModel = gameViewModel
        self.isPlayTabVisible = isPlayTabVisible
        self.controller = controller ?? .shared
        refresh()
    }

    func setPlayTabVisible(_ isVisible: Bool) {
        isPlayTabVisible = isVisible
    }

    func setActionHandlers(
        deal: (() -> Void)?,
        guess: ((Guess) -> Void)?
    ) {
        dealHandler = deal
        guessHandler = guess
        refresh()
    }

    func refresh() {
        guard isPlayTabVisible, let gameViewModel else {
            controller.update(
                isVisible: false,
                mode: .deal,
                dealAction: nil,
                lowerAction: nil,
                equalAction: nil,
                higherAction: nil
            )
            return
        }

        let mode: GameTouchBarController.Mode = gameViewModel.waitingForGuess ? .guessOptions : .deal
        let dealHandler = self.dealHandler
        let guessHandler = self.guessHandler

        controller.update(
            isVisible: true,
            mode: mode,
            dealAction: {
                guard !gameViewModel.waitingForGuess else { return }
                if let dealHandler {
                    dealHandler()
                } else {
                    gameViewModel.startRound()
                }
            },
            lowerAction: {
                guard gameViewModel.waitingForGuess else { return }
                if let guessHandler {
                    guessHandler(.lower)
                } else {
                    gameViewModel.makeGuess(.lower)
                }
            },
            equalAction: {
                guard gameViewModel.waitingForGuess else { return }
                if let guessHandler {
                    guessHandler(.equal)
                } else {
                    gameViewModel.makeGuess(.equal)
                }
            },
            higherAction: {
                guard gameViewModel.waitingForGuess else { return }
                if let guessHandler {
                    guessHandler(.higher)
                } else {
                    gameViewModel.makeGuess(.higher)
                }
            }
        )
    }
}
