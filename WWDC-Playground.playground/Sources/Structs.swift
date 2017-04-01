import UIKit

public struct Corners {
  var left: CGFloat
  var right: CGFloat
  var up: CGFloat
  var down: CGFloat
  init(point: CGPoint) {
    left = point.x
    right = point.x
    down = point.y
    up = point.y
  }
  init() {
    left = 0
    right = 0
    down = 0
    up = 0
  }
}

public struct SavePoint {
  var point: CGPoint
  var timeBefore: TimeInterval = 0
  var owner: UIImageView
  init(point: CGPoint, timeBefore: TimeInterval, owner: UIImageView) {
    self.point = point
    self.timeBefore = timeBefore
    self.owner = owner
  }
}
