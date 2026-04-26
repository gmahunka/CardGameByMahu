#if os(macOS)

import AppKit
import SwiftUI

@MainActor
final class GameTouchBarController: NSObject, NSTouchBarDelegate {
    static let shared = GameTouchBarController()

    enum Mode: Equatable {
        case deal
        case guessOptions
    }

    private static let dealIdentifier = NSTouchBarItem.Identifier("com.cardgamebymahu.touchbar.deal")
    private static let lowerIdentifier = NSTouchBarItem.Identifier("com.cardgamebymahu.touchbar.lower")
    private static let equalIdentifier = NSTouchBarItem.Identifier("com.cardgamebymahu.touchbar.equal")
    private static let higherIdentifier = NSTouchBarItem.Identifier("com.cardgamebymahu.touchbar.higher")

    private weak var window: NSWindow?
    private var mode: Mode = .deal
    private var dealAction: (() -> Void)?
    private var lowerAction: (() -> Void)?
    private var equalAction: (() -> Void)?
    private var higherAction: (() -> Void)?

    func update(
        mode: Mode,
        dealAction: @escaping () -> Void,
        lowerAction: @escaping () -> Void,
        equalAction: @escaping () -> Void,
        higherAction: @escaping () -> Void
    ) {
        self.mode = mode
        self.dealAction = dealAction
        self.lowerAction = lowerAction
        self.equalAction = equalAction
        self.higherAction = higherAction
        refreshTouchBar()
    }

    func attach(to window: NSWindow?) {
        self.window = window
        refreshTouchBar()
        window?.makeFirstResponder(window?.contentView)
    }

    private func refreshTouchBar() {
        guard let window else { return }
        window.touchBar = makeTouchBar()
    }

    private func makeTouchBar() -> NSTouchBar? {
        let touchBar = NSTouchBar()
        touchBar.delegate = self
        touchBar.customizationIdentifier = NSTouchBar.CustomizationIdentifier("com.cardgamebymahu.touchbar")
        touchBar.defaultItemIdentifiers = mode == .deal
            ? [Self.dealIdentifier]
            : [Self.lowerIdentifier, Self.equalIdentifier, Self.higherIdentifier]
        return touchBar
    }

    func touchBar(_ touchBar: NSTouchBar, makeItemForIdentifier identifier: NSTouchBarItem.Identifier) -> NSTouchBarItem? {
        switch identifier {
        case Self.dealIdentifier:
            return buttonItem(title: "Deal", symbolName: "hand.point.up.left.fill", action: #selector(dealPressed))
        case Self.lowerIdentifier:
            return buttonItem(title: "Lower", symbolName: "arrow.down.circle.fill", action: #selector(lowerPressed))
        case Self.equalIdentifier:
            return buttonItem(title: "Equal", symbolName: "equal.circle.fill", action: #selector(equalPressed))
        case Self.higherIdentifier:
            return buttonItem(title: "Higher", symbolName: "arrow.up.circle.fill", action: #selector(higherPressed))
        default:
            return nil
        }
    }

    private func buttonItem(title: String, symbolName: String, action: Selector) -> NSTouchBarItem {
        let identifier: NSTouchBarItem.Identifier
        switch title {
        case "Deal": identifier = Self.dealIdentifier
        case "Lower": identifier = Self.lowerIdentifier
        case "Equal": identifier = Self.equalIdentifier
        default: identifier = Self.higherIdentifier
        }

        let item = NSButtonTouchBarItem(identifier: identifier, title: title, target: self, action: action)
        let symbolImage = NSImage(systemSymbolName: symbolName, accessibilityDescription: title)
        symbolImage?.isTemplate = true
        item.image = symbolImage
        item.bezelColor = .controlAccentColor
        return item
    }

    @objc private func dealPressed() { dealAction?() }
    @objc private func lowerPressed() { lowerAction?() }
    @objc private func equalPressed() { equalAction?() }
    @objc private func higherPressed() { higherAction?() }
}

#endif
