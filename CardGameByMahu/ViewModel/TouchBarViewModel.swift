//
//  TouchBarViewModel.swift
//  CardGameByMahu
//
//  Created by GitHub Copilot on 2026. 04. 26..
//

import Foundation
import Observation

@MainActor
@Observable
final class TouchBarViewModel {
    private weak var gameViewModel: CardGameViewModel?
    private let controller: GameTouchBarController

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

        controller.update(
            isVisible: true,
            mode: mode,
            dealAction: {
                guard !gameViewModel.waitingForGuess else { return }
                gameViewModel.startRound()
            },
            lowerAction: {
                guard gameViewModel.waitingForGuess else { return }
                gameViewModel.makeGuess(.lower)
            },
            equalAction: {
                guard gameViewModel.waitingForGuess else { return }
                gameViewModel.makeGuess(.equal)
            },
            higherAction: {
                guard gameViewModel.waitingForGuess else { return }
                gameViewModel.makeGuess(.higher)
            }
        )
    }
}
