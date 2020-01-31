//
//  Throw.swift
//  gciosBags
//


import Foundation


/// Representes a single throw in a round, with one of the three possible results
///
/// - out: throw landed on the grass
/// - board: throw landed on the board
/// - hole: throw went in the hole
enum Throw: Int {
  case out = 0
  case board = 1
  case hole = 3

  var points: Int {
    return self.rawValue
  }
}
