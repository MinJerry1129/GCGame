//
//  BagView.swift
//  gciosBags


import UIKit

extension Notification.Name {
  static let bagViewMoved = Notification.Name("bagViewMoved")
}

enum BagColor {
  case blue
  case red

  fileprivate var image: UIImage {
    switch self {
    case .blue: return #imageLiteral(resourceName: "bluebag")
    case .red: return #imageLiteral(resourceName: "redbag")
    }
  }

  static func color(for team: Team) -> BagColor {
    switch team {
    case .red: return .red
    case .blue: return .blue
    }
  }
}

class BagView: UIView {

  let imageView: UIImageView

  init(color: BagColor) {
    self.imageView = UIImageView(image: color.image)
    super.init(frame: CGRect(x: 0, y: 0, width: 52, height: 52))
    self.imageView.frame = self.bounds
    self.imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    self.isUserInteractionEnabled =  true
    self.imageView.isUserInteractionEnabled = true
    self.transform = CGAffineTransform(rotationAngle: CGFloat.pi * 2 * CGFloat(arc4random_uniform(100)) / 100)
    self.layer.shadowOpacity = 0.6
    self.addSubview(self.imageView)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    self.handleTouches(touches)
  }

  override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    self.handleTouches(touches)
    self.layer.zPosition = 3
  }

  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    self.handleTouches(touches)
    NotificationCenter.default.post(name: .bagViewMoved, object: self)
  }

  private func handleTouches(_ touches: Set<UITouch>) {
    guard let superview = self.superview,
      let location =  touches.first?.location(in: superview),
       superview.bounds.contains(location) else {
      return
    }

    self.center = location
  }
}
