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
        
        // Wait for element to exist first
        let existsPredicate = NSPredicate(format: "exists == true")
        let expectation = XCTNSPredicateExpectation(predicate: existsPredicate, object: element)
        _ = XCTWaiter().wait(for: [expectation], timeout: 2)
        
        // If already hittable, no need to scroll
        if element.isHittable { return }

        let scrollDirection: CGVector = direction == .down 
            ? CGVector(dx: 0.5, dy: 0.2)  // Scroll down (drag from bottom to top)
            : CGVector(dx: 0.5, dy: 0.8)  // Scroll up (drag from top to bottom)

        var attempts = 0
        while !element.isHittable && attempts < maxScrolls {
            // Use drag to scroll the scroll view
            let start = coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: direction == .down ? 0.8 : 0.2))
            let finish = coordinate(withNormalizedOffset: scrollDirection)
            start.press(forDuration: 0.1, thenDragTo: finish)
            
            // Give time for view to update
            Thread.sleep(forTimeInterval: 0.1)
            attempts += 1
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
        app/*@START_MENU_TOKEN@*/.radioButtons["Setup"]/*[[".tabGroups",".radioButtons[\"Setup\"]",".radioButtons[\"slider.horizontal.3\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[1]]@END_MENU_TOKEN@*/.firstMatch.click()
        
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
        
        app.buttons["Save & Apply"].firstMatch.click()
        app.buttons["Regular Deck"].firstMatch.click()
        
    }
    
    func testTabs() {
        let app = XCUIApplication()
        app.activate()
        let element = app/*@START_MENU_TOKEN@*/.radioButtons["playTab"]/*[[".tabGroups",".radioButtons[\"Play\"]",".radioButtons[\"playTab\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.firstMatch
        element.click()
        
        let element2 = app/*@START_MENU_TOKEN@*/.radioButtons["historyTab"]/*[[".tabGroups",".radioButtons[\"History\"]",".radioButtons[\"historyTab\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.firstMatch
        element2.click()
        app/*@START_MENU_TOKEN@*/.radioButtons["leaderboardTab"]/*[[".tabGroups",".radioButtons[\"Leaderboard\"]",".radioButtons[\"leaderboardTab\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.firstMatch.click()
        element2.click()
        element.click()
        app/*@START_MENU_TOKEN@*/.radioButtons["setupTab"]/*[[".tabGroups",".radioButtons[\"Setup\"]",".radioButtons[\"setupTab\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.firstMatch.click()
        
    }
    
    func testPlayGame() {
        let app = XCUIApplication()
        app.activate()
        app/*@START_MENU_TOKEN@*/.radioButtons["playTab"]/*[[".tabGroups",".radioButtons[\"Play\"]",".radioButtons[\"playTab\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.firstMatch.click()
        
        let element = app.buttons["dealButton"].firstMatch
        
        element.click()
        
        let higher = app.buttons["higherButton"].firstMatch
        higher.click()
        
        element.click()
        
        let equal = app.buttons["equalButton"].firstMatch
        equal.click()
        
        element.click()
        
        let lower = app.buttons["lowerButton"].firstMatch
        lower.click()
        
        app.radioButtons["historyTab"].firstMatch.click()
        
    }
    
    func testInfoPanel() {
        let app = XCUIApplication()
        app.activate()
        app/*@START_MENU_TOKEN@*/.radioButtons["playTab"]/*[[".tabGroups",".radioButtons[\"Play\"]",".radioButtons[\"playTab\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.firstMatch.click()
        
        let infoButton = app.buttons["showRulesButton"].firstMatch
        infoButton.click()
        
        app.buttons["Dismiss Rules"].firstMatch.click()
    }
    
    func testTooFewCardsRemain() {
        let app = XCUIApplication()
        app.activate()
        app/*@START_MENU_TOKEN@*/.radioButtons["playTab"]/*[[".tabGroups",".radioButtons[\"Play\"]",".radioButtons[\"playTab\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.firstMatch.click()

        for _ in 0..<26 {
            app.buttons["dealButton"].firstMatch.click()
            app.buttons["higherButton"].firstMatch.click()
        }
        
        app.buttons["dealButton"].firstMatch.click()
        app.buttons["Cancel Reshuffle Alert"].firstMatch.click()
        
        app.buttons["dealButton"].firstMatch.click()
        app.buttons["Reshuffle Deck Alert"].firstMatch.click()
    }
    
    func testHardcoreQuit() {
        let app = XCUIApplication()
        app.activate()
        app/*@START_MENU_TOKEN@*/.radioButtons["playTab"]/*[[".tabGroups",".radioButtons[\"Play\"]",".radioButtons[\"playTab\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.firstMatch.click()
        app.buttons["hardcoreModeButton"].firstMatch.click()
        app.buttons["dealButton"].firstMatch.click()
        app.buttons["equalButton"].firstMatch.click()
        app.buttons["quitHardcoreButton"].firstMatch.click()
        
        app/*@START_MENU_TOKEN@*/.radioButtons["leaderboardTab"]/*[[".radioGroups",".radioButtons[\"Leaderboard\"]",".radioButtons[\"leaderboardTab\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.firstMatch.click()
        
        let element = app/*@START_MENU_TOKEN@*/.buttons["SCORE"]/*[[".groups.buttons[\"SCORE\"]",".buttons[\"SCORE\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.firstMatch
        element.click()
        element.click()
    }
    
    func testHardcoreExit() {
        let app = XCUIApplication()
        app.activate()
        app/*@START_MENU_TOKEN@*/.radioButtons["playTab"]/*[[".tabGroups",".radioButtons[\"Play\"]",".radioButtons[\"playTab\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.firstMatch.click()
        app.buttons["hardcoreModeButton"].firstMatch.click()
        for _ in 0..<26 {
            app.buttons["dealButton"].firstMatch.click()
            app.buttons["equalButton"].firstMatch.click()
        }
        app.buttons["dealButton"].firstMatch.click()
        
        app.buttons["dealButton"].firstMatch.click()
        app.buttons["quitHardcoreButtonCancel"].firstMatch.click()
        
        app.buttons["dealButton"].firstMatch.click()
        app.buttons["quitHardcoreButtonAfterFinish"].firstMatch.click()
        
        app.radioButtons["historyTab"].firstMatch.click()
        app/*@START_MENU_TOKEN@*/.radioButtons["leaderboardTab"]/*[[".tabGroups",".radioButtons[\"Leaderboard\"]",".radioButtons[\"leaderboardTab\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.firstMatch.click()
        
        app.radioButtons["sortByScoreButton"].firstMatch.click()
        app.radioButtons["sortByAccuracyButton"].firstMatch.click()
        app.radioButtons["sortByTimeButton"].firstMatch.click()
        
        app.buttons["deleteLeaderboardEntrybutton"].firstMatch.click()
        app.buttons["cancelDeleteEntryButton"].firstMatch.click()
        app.buttons["deleteLeaderboardEntrybutton"].firstMatch.click()
        app.buttons["confirmDeleteEntryButton"].firstMatch.click()
    }
    
    func testVoiceCommandToggle() {
        let app = XCUIApplication()
        app.activate()
        app.radioButtons["playTab"].firstMatch.click()
        app/*@START_MENU_TOKEN@*/.buttons["voiceCommandToggle"]/*[[".scrollViews",".buttons[\"Enable Voice Commands\"]",".buttons[\"voiceCommandToggle\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.firstMatch.click()
        app/*@START_MENU_TOKEN@*/.buttons["action-button-1"]/*[[".sheets[\"_NS:87\"].buttons",".sheets",".buttons[\"Enable\"]",".buttons[\"action-button-1\"]"],[[[-1,3],[-1,1,1],[-1,0]],[[-1,3],[-1,2]]],[0]]@END_MENU_TOKEN@*/.firstMatch.click()
        
        app/*@START_MENU_TOKEN@*/.buttons["voiceCommandToggle"]/*[[".scrollViews",".buttons[\"Disable Voice Commands\"]",".buttons[\"voiceCommandToggle\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.firstMatch.click()
    }
    
}

