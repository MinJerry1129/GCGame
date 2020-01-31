//
//  Round.swift
//  gciosBags
//


import Foundation

/// Represents a round in a cornhole game. A round is over when both teams 
/// have made 4 throws.
class Round {

  let startingTeam: Team

  var redThrows = [Throw]()
  var blueThrows = [Throw]()

  var isNew: Bool {
    return redThrows.isEmpty && blueThrows.isEmpty
  }

  init(startingTeam: Team) {
    self.startingTeam = startingTeam
  }
}
