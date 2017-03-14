//: Playground - noun: a place where people can play
//  Created by Kirill Averyanov


import UIKit
import PlaygroundSupport

class ViewController: UIViewController {

  var lastPoint = CGPoint.zero
  var red: CGFloat = 0.0
  var green: CGFloat = 0.0
  var blue: CGFloat = 0.0
  var brushWidth: CGFloat = 10.0
  var opacity: CGFloat = 1.0
  var swiped = false

  var mainImageView: UIImageView!
  var tempImageView: UIImageView!

  override func viewDidLoad() {
    super.viewDidLoad()
    self.view.backgroundColor = .white
    mainImageView = UIImageView(frame: self.view.frame)
    tempImageView = UIImageView(frame: self.view.frame)
    self.view.addSubview(mainImageView!)
    self.view.addSubview(tempImageView!)
  }

  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    swiped = false
    if let touch = touches.first {
      lastPoint = touch.location(in: self.view)
    }
  }

  override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    swiped = true
    if let touch = touches.first {
      let currentPoint = touch.location(in: view)
      drawLineFrom(fromPoint: lastPoint, toPoint: currentPoint)
      lastPoint = currentPoint
    }
  }

  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    if !swiped {
      drawLineFrom(fromPoint: lastPoint, toPoint: lastPoint)
    }

    // Merge tempImageView into mainImageView
    UIGraphicsBeginImageContext(mainImageView.frame.size)
    mainImageView.image?.draw(in: CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height), blendMode: CGBlendMode.normal, alpha: 1.0)
    tempImageView.image?.draw(in: CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height), blendMode: CGBlendMode.normal, alpha: opacity)
    mainImageView.image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()

    tempImageView.image = nil
  }

  func drawLineFrom(fromPoint: CGPoint, toPoint: CGPoint) {
    UIGraphicsBeginImageContext(view.frame.size)
    let context = UIGraphicsGetCurrentContext()
    tempImageView.image?.draw(in: CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height))

    context?.move(to: fromPoint)
    context?.addLine(to: toPoint)
    context?.setLineCap(CGLineCap.round)
    context?.setLineWidth(brushWidth)
    context?.setStrokeColor(red: red, green: green, blue: blue, alpha: 1.0)
    context?.setBlendMode(CGBlendMode.normal)
    context?.strokePath()

    tempImageView.image = UIGraphicsGetImageFromCurrentImageContext()
    tempImageView.alpha = opacity
    UIGraphicsEndImageContext()
  }
}

let viewController = ViewController()
PlaygroundPage.current.liveView = viewController.view
