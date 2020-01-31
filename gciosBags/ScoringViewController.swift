//
//  ViewController.swift
//  gciosBags
//


import UIKit

class ScoringViewController: UIViewController {

  private static let redColor = UIColor(red: 0.75, green: 0.16, blue: 0.16, alpha: 1.00)
  private static let blueColor = UIColor(red:0.20, green:0.50, blue:0.81, alpha:1.00)

  private var gameScorer = GameScorer()
  private var bagViews = [BagView]()
  private var canThrow = true
  private var holePath = UIBezierPath()
  private var boardPath = UIBezierPath()

  @IBOutlet weak var boardImageView: UIImageView!
  @IBOutlet weak var roundLabel: UILabel!
  @IBOutlet weak var playView: UIView!

  @IBOutlet weak var redGameScoreLabel: UILabel!
  @IBOutlet weak var blueGameScoreLabel: UILabel!
  @IBOutlet weak var redRoundScoreLabel: UILabel!
  @IBOutlet weak var blueRoundScoreLabel: UILabel!
  @IBOutlet weak var redThrowIndicatorView: UIImageView!
  @IBOutlet weak var blueThrowIndicatorView: UIImageView!
  @IBOutlet weak var redBagCountContainerStackView: UIStackView!
  @IBOutlet weak var blueBagCountContainerStackView: UIStackView!

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    NotificationCenter.default.addObserver(self, selector: #selector(regenerateAllThrowsInRound), name: .bagViewMoved, object: nil)
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    self.refreshViews()
    self.redBagCountContainerStackView.arrangedSubviews.forEach({ self.configureBagCountIndicator($0, color: ScoringViewController.redColor) })
    self.blueBagCountContainerStackView.arrangedSubviews.forEach({ self.configureBagCountIndicator($0, color: ScoringViewController.blueColor) })
    self.boardImageView.layer.zPosition = 2
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    self.recalculatePaths()
  }

  private func configureBagCountIndicator(_ countView: UIView, color: UIColor) {
    countView.layer.cornerRadius = 2
    countView.layer.borderWidth = 1
    countView.layer.borderColor = color.cgColor
  }

  private func handleTap(in point: CGPoint) {
    guard let nextTeam = self.gameScorer.nextTeamToThrow(),
      self.gameScorer.gameState == .roundInProgress else {
      return
    }

    let newBag = BagView(color: BagColor.color(for: nextTeam))
    self.playView.addSubview(newBag)
    newBag.center = point

    self.addThrowForBag(bag: newBag)
    self.bagViews.append(newBag)
    self.refreshViews()
  }

  private func addThrowForBag(bag: BagView) {
    let newThrow = self.newThrow(in: bag.center)
    self.gameScorer.addThrow(newThrow)

    if newThrow == .hole {
      bag.layer.zPosition = 1
    } else {
      bag.layer.zPosition = 3
    }

    switch self.gameScorer.gameState {
    case .roundOver:
      self.presentRoundOverAlert()
    case .gameOver:
      self.presentGameOverAlert()
    default:
      break
    }
  }

  private func newThrow(in point: CGPoint) -> Throw {
    if self.holePath.contains(point) {
      return .hole
    } else if self.boardPath.contains(point) {
      return .board
    } else {
      return .out
    }
  }

  private func presentRoundOverAlert() {
    let startNextRoundAction = UIAlertAction(title: "Start Next Round", style: .default) { _ in
      self.clearBoard()
      self.gameScorer.startNewRound()
      self.refreshViews()
    }

    let title: String
    let message: String
    switch self.gameScorer.result(forRound: self.gameScorer.game.currentRound) {
    case .over(let winner, let points):
      if let winner = winner {
        title = "\(winner.name) Team wins round \(self.gameScorer.game.currentRoundNumber)!"
        message = "\(points) \(points == 1 ? "point" : "points") added to their total score"
      } else {
        title = "Round \(self.gameScorer.game.currentRoundNumber) is a tie!"
        message = "No point will be added to either team"
      }
    case .inProgress:
      fatalError("Can't call presentRoundOverAlert when round is inProgress")
    }

    let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
    alertController.addAction(startNextRoundAction)

    self.present(alertController, animated: true, completion: nil)
  }

  private func presentGameOverAlert() {
    guard let winner = self.gameScorer.winner else {
      fatalError("There must be a winner before attempting to present the game over alert")
    }

    let startNewGameAction = UIAlertAction(title: "Start New Game", style: .default) { _ in
      self.clearBoard()
      self.gameScorer = GameScorer()
      self.refreshViews()
    }

    let title = "\(winner.name) Team Wins!"
    let message = "Final score:\n" +
      "\(Team.red.name) Team: \(self.gameScorer.score(for: .red)), " +
      "\(Team.blue.name) Team: \(self.gameScorer.score(for: .blue))"

    let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
    alertController.addAction(startNewGameAction)

    self.present(alertController, animated: true, completion: nil)
  }
  
  private func clearBoard() {
    self.bagViews.forEach({ $0.removeFromSuperview() })
    self.bagViews.removeAll()
  }

  // For simplicity when users drag and drop a bag we regenerate all the
  // throws in the round
  @objc private func regenerateAllThrowsInRound() {
    self.gameScorer.clearCurrentRound()
    self.bagViews.forEach({ self.addThrowForBag(bag: $0) })
    self.refreshViews()
  }

  private func refreshViews() {
    self.roundLabel.text = "Round \(self.gameScorer.game.currentRoundNumber)"
    self.redGameScoreLabel.text = "\(self.gameScorer.score(for: .red))"
    self.blueGameScoreLabel.text = "\(self.gameScorer.score(for: .blue))"
    self.redRoundScoreLabel.text = "\(self.gameScorer.scoreInRound(self.gameScorer.game.currentRound, forTeam: .red))"
    self.blueRoundScoreLabel.text = "\(self.gameScorer.scoreInRound(self.gameScorer.game.currentRound, forTeam: .blue))"
    self.redThrowIndicatorView.isHidden = self.gameScorer.nextTeamToThrow() != .red
    self.blueThrowIndicatorView.isHidden = self.gameScorer.nextTeamToThrow() != .blue
    self.upateBagCountView(self.redBagCountContainerStackView, for: .red)
    self.upateBagCountView(self.blueBagCountContainerStackView, for: .blue)
  }

  /// Updates the bag indicators that show app below the round's score
  private func upateBagCountView(_ bagCountView: UIStackView, for team: Team) {
    let throwCount = team == .red ? self.gameScorer.numberOfThrowsInRound(self.gameScorer.game.currentRound, forTeam: .red) : self.gameScorer.numberOfThrowsInRound(self.gameScorer.game.currentRound, forTeam: .blue)
    let color = team == .red ? ScoringViewController.redColor : ScoringViewController.blueColor
    let remainingThrows = 4 - throwCount

    bagCountView.arrangedSubviews.enumerated().forEach { index, view in
      if remainingThrows > index {
        view.backgroundColor = color
      } else {
        view.backgroundColor = .clear
      }
    }
  }

  // These paths are based on where the shapes and sizes of the board and the whole in the 
  // original assets

  private func recalculatePaths() {
    self.recalculateHolePath()
    self.recalculateBoardPath()
  }

  private func recalculateBoardPath() {
    self.boardPath = UIBezierPath(rect: CGRect(x: self.boardImageView.frame.minX + 23,
                                               y: self.boardImageView.frame.minY + 16,
                                               width: 204,
                                               height: 408))
  }

  private func recalculateHolePath() {
    let enclosingRect = CGRect(x: self.boardImageView.frame.minX + 97,
                               y: self.boardImageView.frame.minY + 68,
                               width: 56,
                               height: 56)

    self.holePath = UIBezierPath(ovalIn: enclosingRect)
  }

  // MARK: Actions

  @IBAction func tapAction(_ sender: UITapGestureRecognizer) {
    if sender.state == .ended {
      self.handleTap(in: sender.location(in: self.playView))
    }
  }
}

