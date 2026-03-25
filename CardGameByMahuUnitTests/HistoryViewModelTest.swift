//
//  HistoryViewModelTest.swift
//  CardGameByMahuUnitTests
//
//  Created by Gergo Mahunka on 2026. 03. 25..
//

import Foundation
import Testing
@testable import CardGameByMahu

struct HistoryViewModelTest {

    @Test("rows maps correct round and emphasizes chosen pill")
    func rowsMapsCorrectRound() {
        let sut = HistoryViewModel()
        let round = makeRound(
            playerCard: "card7",
            computerCard: "card9",
            wasCorrect: true,
            playerChoice: GuessOption.higher,
            correctAnswer: GuessOption.higher,
            isHardcoreMode: false,
            lowerChance: 0.10,
            equalChance: 0.20,
            higherChance: 0.70
        )

        let rows = sut.rows(from: [round])

        #expect(rows.count == 1)
        let row = rows[0]
        #expect(row.id == round.id)
        #expect(row.playerCard == "card7")
        #expect(row.computerCard == "card9")
        #expect(row.resultTitle == "Correct")
        #expect(row.resultSystemImage == "checkmark.circle.fill")
        #expect(row.isHardcoreMode == false)

        #expect(row.pills.count == 3)
        #expect(row.pills[0].id == GuessOption.lower.rawValue)
        #expect(row.pills[1].id == GuessOption.equal.rawValue)
        #expect(row.pills[2].id == GuessOption.higher.rawValue)

        #expect(row.pills[0].title == GuessOption.lower.displayText)
        #expect(row.pills[1].title == GuessOption.equal.displayText)
        #expect(row.pills[2].title == GuessOption.higher.displayText)

        #expect(row.pills[0].text == "\(GuessOption.lower.displayText): 10%")
        #expect(row.pills[1].text == "\(GuessOption.equal.displayText): 20%")
        #expect(row.pills[2].text == "\(GuessOption.higher.displayText): 70%")

        #expect(row.pills[0].isEmphasized == false)
        #expect(row.pills[1].isEmphasized == false)
        #expect(row.pills[2].isEmphasized == true)
    }

    @Test("rows maps wrong round metadata")
    func rowsMapsWrongRound() {
        let sut = HistoryViewModel()
        let round = makeRound(
            playerCard: "card12",
            computerCard: "card3",
            wasCorrect: false,
            playerChoice: GuessOption.higher,
            correctAnswer: GuessOption.lower,
            isHardcoreMode: true,
            lowerChance: 0.55,
            equalChance: 0.10,
            higherChance: 0.35
        )

        let row = sut.rows(from: [round])[0]

        #expect(row.resultTitle == "Wrong")
        #expect(row.resultSystemImage == "xmark.circle.fill")
        #expect(row.isHardcoreMode == true)

        #expect(row.pills[0].isEmphasized == false)
        #expect(row.pills[1].isEmphasized == false)
        #expect(row.pills[2].isEmphasized == true)
    }

    @Test("rows rounds percentages")
    func rowsRoundsPercentages() {
        let sut = HistoryViewModel()
        let round = makeRound(
            lowerChance: 0.124,
            equalChance: 0.125,
            higherChance: 0.999
        )

        let row = sut.rows(from: [round])[0]

        #expect(row.pills[0].text == "\(GuessOption.lower.displayText): 12%")
        #expect(row.pills[1].text == "\(GuessOption.equal.displayText): 13%")
        #expect(row.pills[2].text == "\(GuessOption.higher.displayText): 100%")
    }

    @Test("rows preserves input order")
    func rowsPreservesOrder() {
        let sut = HistoryViewModel()
        let first = makeRound(playerCard: "card2")
        let second = makeRound(playerCard: "card14")
        let third = makeRound(playerCard: "card8")

        let rows = sut.rows(from: [first, second, third])

        #expect(rows[0].id == first.id)
        #expect(rows[1].id == second.id)
        #expect(rows[2].id == third.id)

        #expect(rows[0].playerCard == "card2")
        #expect(rows[1].playerCard == "card14")
        #expect(rows[2].playerCard == "card8")
    }

    private func makeRound(
            id: UUID = UUID(),
            playerCard: String = "card5",
            computerCard: String = "card6",
            wasCorrect: Bool = true,
            playerChoice: GuessOption = .lower,
            correctAnswer: GuessOption = .lower,
            isHardcoreMode: Bool = false,
            lowerChance: Double = 0.33,
            equalChance: Double = 0.34,
            higherChance: Double = 0.33
        ) -> RoundHistoryItem {
            RoundHistoryItem(
                id: id,
                computerCard: computerCard,
                playerCard: playerCard,
                playerChoiceOption: playerChoice,
                correctAnswerOption: correctAnswer,
                wasCorrect: wasCorrect,
                higherChance: higherChance,
                equalChance: equalChance,
                lowerChance: lowerChance,
                isHardcoreMode: isHardcoreMode
            )
    }
}
