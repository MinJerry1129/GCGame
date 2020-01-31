//
//  Team.swift
//  gciosBags
//

import Foundation

/// Possible teams in a game
enum Team {
  case red
  case blue

  var name: String {
    switch self {
    case .red: return "Red"
    case .blue: return "Blue"
    }
  }
}
