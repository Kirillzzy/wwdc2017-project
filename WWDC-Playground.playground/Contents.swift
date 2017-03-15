//: Playground - noun: a place where people can play
//  Created by Kirill Averyanov // github.com/kirillzzy


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
  var colorPicker: ChromaColorPicker!
  var mainImageView: UIImageView!
  var tempImageView: UIImageView!
  var showColorPickerButton: UIButton!

  override func viewDidLoad() {
    super.viewDidLoad()
    self.view.backgroundColor = .white
    mainImageView = UIImageView(frame: self.view.frame)
    tempImageView = UIImageView(frame: self.view.frame)
    showColorPickerButton = UIButton(frame: CGRect(x: 50, y: 0, width: 50, height: 50))
    showColorPickerButton.setTitle("Hello", for: .normal)
    self.view.addSubview(mainImageView!)
    self.view.addSubview(tempImageView!)
    self.view.addSubview(showColorPickerButton)
    addColorPicker()
  }

  func addColorPicker() {
    colorPicker = ChromaColorPicker(frame: CGRect(x: 50, y: 500, width: 300, height: 300))
    colorPicker.delegate = self
    colorPicker.padding = 10
    colorPicker.stroke = 3
    colorPicker.currentAngle = Float(M_PI)
    colorPicker.hexLabel.textColor = UIColor.white
    self.view.addSubview(colorPicker)
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

// MARK: - ColorPickerDelegate
extension ViewController: ChromaColorPickerDelegate{
  func colorPickerDidChooseColor(_ colorPicker: ChromaColorPicker, color: UIColor) {
    color.getRed(&red, green: &green, blue: &blue, alpha: nil)

    //Perform zesty animation
    UIView.animate(withDuration: 0.2,
                   animations: {
                    self.view.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
    }, completion: { (done) in
      UIView.animate(withDuration: 0.2, animations: {
        self.view.transform = CGAffineTransform.identity
      })
    })
  }
}

let viewController = ViewController()
PlaygroundPage.current.liveView = viewController.view
