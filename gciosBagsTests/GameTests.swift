//
//  GameTests.swift
//  gciosBags
//


import XCTest
@testable import gciosBags

class GameTests: XCTestCase {

  var sut: GameScorer! // System Under Test

  override func setUp() {
    super.setUp()
    self.sut = GameScorer()
  }

  func testNewGameHasCorrectState() {
    XCTAssertEqual(self.sut.game.currentRoundNumber, 1)
    XCTAssertEqual(self.sut.score(for: .blue), 0)
    XCTAssertEqual(self.sut.score(for: .red), 0)
    XCTAssertEqual(self.sut.scoreInRound(self.sut.game.currentRound, forTeam: .blue), 0)
    XCTAssertEqual(self.sut.scoreInRound(self.sut.game.currentRound, forTeam: .red), 0)
    XCTAssert(self.sut.game.currentRound.isNew)
    XCTAssertEqual(self.sut.gameState, .roundInProgress)
    XCTAssertEqual(self.sut.nextTeamToThrow(), .red)
  }

  func testAddThrowGeneratesCorrectRoundAndGameScore() {
    self.sut.addThrow(.board)

    XCTAssertEqual(self.sut.game.currentRoundNumber, 1)
    XCTAssertEqual(self.sut.score(for: .blue), 0)
    XCTAssertEqual(self.sut.score(for: .red), 0)
    XCTAssertEqual(self.sut.scoreInRound(self.sut.game.currentRound, forTeam: .blue), 0)
    XCTAssertEqual(self.sut.scoreInRound(self.sut.game.currentRound, forTeam: .red), 1)
    XCTAssertFalse(self.sut.game.currentRound.isNew)
    XCTAssertEqual(self.sut.gameState, .roundInProgress)
    XCTAssertEqual(self.sut.nextTeamToThrow(), .blue)

    self.sut.addThrow(.hole)

    XCTAssertEqual(self.sut.game.currentRoundNumber, 1)
    XCTAssertEqual(self.sut.score(for: .blue), 0)
    XCTAssertEqual(self.sut.score(for: .red), 0)
    XCTAssertEqual(self.sut.scoreInRound(self.sut.game.currentRound, forTeam: .blue), 3)
    XCTAssertEqual(self.sut.scoreInRound(self.sut.game.currentRound, forTeam: .red), 1)
    XCTAssertFalse(self.sut.game.currentRound.isNew)
    XCTAssertEqual(self.sut.gameState, .roundInProgress)
    XCTAssertEqual(self.sut.nextTeamToThrow(), .red)
  }

  func testRoundOverLogic() {
    // Eight throws make a round
    self.sut.addThrow(.board)
    self.sut.addThrow(.out)
    self.sut.addThrow(.board)
    self.sut.addThrow(.out)
    self.sut.addThrow(.board)
    self.sut.addThrow(.out)
    self.sut.addThrow(.board)
    self.sut.addThrow(.out)

    XCTAssertEqual(self.sut.game.currentRoundNumber, 1) // Shouldn't change after startNewRound() is called
    XCTAssertEqual(self.sut.score(for: .blue), 0)
    XCTAssertEqual(self.sut.score(for: .red), 4)
    XCTAssertEqual(self.sut.scoreInRound(self.sut.game.currentRound, forTeam: .blue), 0)
    XCTAssertEqual(self.sut.scoreInRound(self.sut.game.currentRound, forTeam: .red), 4)
    XCTAssertEqual(self.sut.gameState, .roundOver)
  }

  func testStartNewRound() {
    // Eight throws make a round
    (0..<4).forEach { _ in
      self.sut.addThrow(.board)
      self.sut.addThrow(.out)
    }
    self.sut.startNewRound()

    XCTAssertEqual(self.sut.game.currentRoundNumber, 2)
    XCTAssertEqual(self.sut.score(for: .blue), 0)
    XCTAssertEqual(self.sut.score(for: .red), 4)
    XCTAssertEqual(self.sut.scoreInRound(self.sut.game.currentRound, forTeam: .blue), 0)
    XCTAssertEqual(self.sut.scoreInRound(self.sut.game.currentRound, forTeam: .red), 0)
    XCTAssertEqual(self.sut.gameState, .roundInProgress)
  }

  func testGameOverLogic() {
    // Red 21, Blue 0

     // After first round: 12 - 0
    (0..<4).forEach { _ in
      self.sut.addThrow(.hole)
      self.sut.addThrow(.out)
    }
    self.sut.startNewRound()

    // After second round: 21 - 0
    (0..<3).forEach { _ in
      self.sut.addThrow(.hole)
      self.sut.addThrow(.out)
    }
    self.sut.addThrow(.out)
    self.sut.addThrow(.out)

    XCTAssertEqual(self.sut.game.currentRoundNumber, 2)
    XCTAssertEqual(self.sut.score(for: .blue), 0)
    XCTAssertEqual(self.sut.score(for: .red), 21)
    XCTAssertEqual(self.sut.scoreInRound(self.sut.game.currentRound, forTeam: .blue), 0)
    XCTAssertEqual(self.sut.scoreInRound(self.sut.game.currentRound, forTeam: .red), 9)
    XCTAssertEqual(self.sut.gameState, .gameOver)
  }

  func testTwoPointDifferenceRule() {
    // Red 23, Blue 21

    // After first round: 12 - 0
    (0..<4).forEach { _ in
      self.sut.addThrow(.hole)
      self.sut.addThrow(.out)
    }
    self.sut.startNewRound()

    // After second round: 12 - 12
    (0..<4).forEach { _ in
      self.sut.addThrow(.out)
      self.sut.addThrow(.hole)
    }
    self.sut.startNewRound()

    // After third round: 20 - 12
    (0..<4).forEach { _ in
      self.sut.addThrow(.hole)
      self.sut.addThrow(.board)
    }
    self.sut.startNewRound()

    // After fourth round: 20 - 20
    (0..<4).forEach { _ in
      self.sut.addThrow(.board)
      self.sut.addThrow(.hole)
    }
    self.sut.startNewRound()

    // After fifth round: 21 - 20
    self.sut.addThrow(.board)
    self.sut.addThrow(.out)
    (0..<3).forEach { _ in
      self.sut.addThrow(.out)
      self.sut.addThrow(.out)
    }
    self.sut.startNewRound()

    XCTAssertEqual(self.sut.score(for: .blue), 20)
    XCTAssertEqual(self.sut.score(for: .red), 21)
    XCTAssertEqual(self.sut.gameState, .roundInProgress)

    // After sixth round: 22 - 20
    self.sut.addThrow(.board)
    self.sut.addThrow(.out)
    (0..<3).forEach { _ in
      self.sut.addThrow(.out)
      self.sut.addThrow(.out)
    }
    self.sut.startNewRound()
    self.sut.startNewRound()

    XCTAssertEqual(self.sut.score(for: .blue), 20)
    XCTAssertEqual(self.sut.score(for: .red), 22)
    XCTAssertEqual(self.sut.gameState, .gameOver)
  }

}
