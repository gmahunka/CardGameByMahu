//
//  CardGameByMahuUITests.swift
//  CardGameByMahuUITests
//
//  Created by Gergo Mahunka on 2026. 03. 29..
//

import XCTest
@testable import CardGameByMahu

extension XCUIElement {
    func scrollToMakeElementHittable(_ element: XCUIElement, in app: XCUIApplication, maxScrolls: Int = 12, direction: ScrollDirection = .down) {
        guard self.exists else { return }
        if element.isHittable { return }

        enum KeyDirection { case down, up }
        let keyFor: (KeyDirection) -> XCUIKeyboardKey = { dir in
            switch dir { case .down: return .pageDown; case .up: return .pageUp }
        }

        var attempts = 0
        while !element.isHittable && attempts < maxScrolls {
            app.typeKey(keyFor(direction == .down ? .down : .up), modifierFlags: [])
            attempts += 1
        }

        if !element.isHittable {
            let start = coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.8))
            let finish = coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.2))
            start.press(forDuration: 0.01, thenDragTo: finish)
        }
    }

    enum ScrollDirection { case up, down }
}

final class CardGameByMahuUITests: XCTestCase {
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        let app = XCUIApplication()
        app.launchArguments.append("-uitesting")
        app.launch()
    }
    
    override func tearDownWithError() throws {
        let app = XCUIApplication()
        app.terminate()
    }
    
    func testSetupTab() {
        let app = XCUIApplication()
        app.activate()
        app/*@START_MENU_TOKEN@*/.tabs["Setup"]/*[[".tabGroups",".tabs[\"Setup\"]",".tabs[\"slider.horizontal.3\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[1]]@END_MENU_TOKEN@*/.firstMatch.click()
        
        let minusButtons = app.buttons.matching(identifier: "minus.circle.fill")
        let plusButtons = app.buttons.matching(identifier: "plus.circle.fill")
        let countFields = app.textFields.matching(identifier: "Count")
        
        XCTAssertGreaterThan(minusButtons.count, 0, "Expected at least one decrease button on Setup screen.")
        XCTAssertGreaterThan(plusButtons.count, 0, "Expected at least one increase button on Setup screen.")
        XCTAssertGreaterThan(countFields.count, 0, "Expected at least one count text field on Setup screen.")
        
        let firstCountField = countFields.element(boundBy: 0)
        XCTAssertTrue(firstCountField.exists, "First count field should exist.")
        
        XCTAssertEqual(firstCountField.value as? String, "4", "Expected initial count to be 4 in regular deck.")
        minusButtons.element(boundBy: 0).click()
        XCTAssertEqual(firstCountField.value as? String, "3", "Count should decrease to 3 after one minus tap.")
        
        for _ in 0..<6 {
            minusButtons.element(boundBy: 0).click()
        }
        
        XCTAssertEqual(firstCountField.value as? String, "0", "Count should not decrease below 0.")
        
        
        plusButtons.element(boundBy: 0).click()
        XCTAssertEqual(firstCountField.value as? String, "1", "Count should return to 1 after one plus tap.")
        
        app.buttons["saveApplyButton"].firstMatch.click()
        app.buttons["resetDeckOfCardstoRegularButton"].firstMatch.click()
        
    }
    
    func testTabs() {
        let app = XCUIApplication()
        app.activate()
        let element = app/*@START_MENU_TOKEN@*/.tabs["playTab"]/*[[".tabGroups",".tabs[\"Play\"]",".tabs[\"playTab\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.firstMatch
        element.click()
        
        let element2 = app/*@START_MENU_TOKEN@*/.tabs["historyTab"]/*[[".tabGroups",".tabs[\"History\"]",".tabs[\"historyTab\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.firstMatch
        element2.click()
        app/*@START_MENU_TOKEN@*/.tabs["leaderboardTab"]/*[[".tabGroups",".tabs[\"Leaderboard\"]",".tabs[\"leaderboardTab\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.firstMatch.click()
        element2.click()
        element.click()
        app/*@START_MENU_TOKEN@*/.tabs["setupTab"]/*[[".tabGroups",".tabs[\"Setup\"]",".tabs[\"setupTab\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.firstMatch.click()
        
    }
    
    func testPlayGame() {
        let app = XCUIApplication()
        app.activate()
        app/*@START_MENU_TOKEN@*/.tabs["playTab"]/*[[".tabGroups",".tabs[\"Play\"]",".tabs[\"playTab\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.firstMatch.click()
        
        let element = app.buttons["dealButton"]
        
        element.click()
        
        let higher = app.buttons["Higher"].firstMatch
        higher.click()
        
        element.click()
        
        let equal = app.buttons["Equal"].firstMatch
        equal.click()
        
        element.click()
        
        let lower = app.buttons["Lower"].firstMatch
        lower.click()
        
        app.tabs["historyTab"].firstMatch.click()
        
    }
    
    func testInfoPanel() {
        let app = XCUIApplication()
        app.activate()
        app/*@START_MENU_TOKEN@*/.tabs["playTab"]/*[[".tabGroups",".tabs[\"Play\"]",".tabs[\"playTab\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.firstMatch.click()
        
        let infoButton = app.buttons["showRulesButton"].firstMatch
        infoButton.click()
        
        app.buttons["dismissRulesButton"].firstMatch.click()
    }
    
    func testTooFewCardsRemain() {
        let app = XCUIApplication()
        app.activate()
        app.tabs["setupTab"].firstMatch.click()
        
        let minusButtons = app.buttons.matching(identifier: "minus.circle.fill")
        let typeOfCards = 0..<12
        let scrollView = app.scrollViews.firstMatch
        for card in typeOfCards {
            let target = minusButtons.element(boundBy: card)
            scrollView.scrollToMakeElementHittable(target, in: app, maxScrolls: 12, direction: .down)
            for _ in 0...3 {
                target.click()
            }
        }
        app.buttons["saveApplyButton"].firstMatch.click()
        app/*@START_MENU_TOKEN@*/.tabs["playTab"]/*[[".tabGroups",".tabs[\"Play\"]",".tabs[\"playTab\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.firstMatch.click()

        for _ in 0..<2 {
            app.buttons["dealButton"].firstMatch.click()
            app/*@START_MENU_TOKEN@*/.buttons["Higher"]/*[[".scrollViews.buttons[\"Higher\"]",".buttons[\"Higher\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.firstMatch.click()
        }
        
        app.buttons["dealButton"].firstMatch.click()
        app.buttons["reshuffleAlertCancelButton"].firstMatch.click()
        
        app.buttons["dealButton"].firstMatch.click()
        app.buttons["reshuffleAlertButton"].firstMatch.click()
    }
    
    func testHardcoreQuit() {
        let app = XCUIApplication()
        app.activate()
        app/*@START_MENU_TOKEN@*/.tabs["playTab"]/*[[".tabGroups",".tabs[\"Play\"]",".tabs[\"playTab\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.firstMatch.click()
        app/*@START_MENU_TOKEN@*/.buttons["Hardcore Mode"]/*[[".groups.buttons[\"Hardcore Mode\"]",".buttons[\"Hardcore Mode\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.firstMatch.click()
        app/*@START_MENU_TOKEN@*/.sheets.buttons["dealButton"].firstMatch/*[[".buttons.matching(identifier: \"dealButton\").element(boundBy: 0)",".sheets",".buttons[\"Deal\"].firstMatch",".buttons[\"dealButton\"].firstMatch"],[[[-1,1,1],[-1,0]],[[-1,3],[-1,2]]],[0,0]]@END_MENU_TOKEN@*/.click()
        app/*@START_MENU_TOKEN@*/.sheets.buttons["Equal"].firstMatch/*[[".buttons.matching(identifier: \"Equal\").element(boundBy: 0)",".sheets.buttons[\"Equal\"].firstMatch"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.click()
        app/*@START_MENU_TOKEN@*/.buttons["quitHardcoreButton"]/*[[".groups",".buttons[\"Quit\"]",".buttons[\"quitHardcoreButton\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.firstMatch.click()
        
    }
    
    func testHardcoreExit() {
        let app = XCUIApplication()
        app.activate()
        app/*@START_MENU_TOKEN@*/.tabs["playTab"]/*[[".tabGroups",".tabs[\"Play\"]",".tabs[\"playTab\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.firstMatch.click()
        app/*@START_MENU_TOKEN@*/.buttons["Hardcore Mode"]/*[[".groups.buttons[\"Hardcore Mode\"]",".buttons[\"Hardcore Mode\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.firstMatch.click()
        for _ in 0..<26 {
            app/*@START_MENU_TOKEN@*/.sheets.buttons["dealButton"].firstMatch/*[[".buttons.matching(identifier: \"dealButton\").element(boundBy: 0)",".sheets",".buttons[\"Deal\"].firstMatch",".buttons[\"dealButton\"].firstMatch"],[[[-1,1,1],[-1,0]],[[-1,3],[-1,2]]],[0,0]]@END_MENU_TOKEN@*/.click()
            app/*@START_MENU_TOKEN@*/.sheets.buttons["Equal"].firstMatch/*[[".buttons.matching(identifier: \"Equal\").element(boundBy: 0)",".sheets.buttons[\"Equal\"].firstMatch"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.click()
        }
        app/*@START_MENU_TOKEN@*/.sheets.buttons["dealButton"].firstMatch/*[[".buttons.matching(identifier: \"dealButton\").element(boundBy: 0)",".sheets",".buttons[\"Deal\"].firstMatch",".buttons[\"dealButton\"].firstMatch"],[[[-1,1,1],[-1,0]],[[-1,3],[-1,2]]],[0,0]]@END_MENU_TOKEN@*/.click()
        
        app/*@START_MENU_TOKEN@*/.sheets.buttons["dealButton"].firstMatch/*[[".buttons.matching(identifier: \"dealButton\").element(boundBy: 0)",".sheets",".buttons[\"Deal\"].firstMatch",".buttons[\"dealButton\"].firstMatch"],[[[-1,1,1],[-1,0]],[[-1,3],[-1,2]]],[0,0]]@END_MENU_TOKEN@*/.click()
        app.sheets.buttons["quitHardcoreButtonCancel"].firstMatch.click()
        
        app/*@START_MENU_TOKEN@*/.sheets.buttons["dealButton"].firstMatch/*[[".buttons.matching(identifier: \"dealButton\").element(boundBy: 0)",".sheets",".buttons[\"Deal\"].firstMatch",".buttons[\"dealButton\"].firstMatch"],[[[-1,1,1],[-1,0]],[[-1,3],[-1,2]]],[0,0]]@END_MENU_TOKEN@*/.click()
        app.sheets.buttons["quitHardcoreButtonAfterFinish"].firstMatch.click()
        
        app.tabs["historyTab"].firstMatch.click()
        app/*@START_MENU_TOKEN@*/.tabs["leaderboardTab"]/*[[".tabGroups",".tabs[\"Leaderboard\"]",".tabs[\"leaderboardTab\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.firstMatch.click()
    }
}

