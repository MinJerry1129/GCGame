//
//  Game.swift
//  gciosBags
//


import Foundation

/// Represents a single game of cornhole.
class Game {

  var rounds: [Round]

  var currentRoundNumber: Int {
    return self.rounds.count
  }

  var currentRound: Round {
    return self.rounds.last!
  }

  init(startingTeam: Team = .red) {
    self.rounds = [Round(startingTeam: startingTeam)]
  }
}
