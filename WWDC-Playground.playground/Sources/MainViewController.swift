// Created by Kirill Averyanov


import UIKit

open class MainViewController: UIViewController {

  var lastPoint = CGPoint.zero
  var red: CGFloat = 0.0
  var green: CGFloat = 0.999999916517394
  var blue: CGFloat = 1.0
  var brushWidth: CGFloat = 10.0
  var opacity: CGFloat = 1.0
  var swiped = false
  var colorPicker: ChromaColorPicker!
  var mainImageView: UIImageView!
  var tempImageView: UIImageView!
  var sizeOfColorPicker: CGFloat = 200.0


  override open func viewDidLoad() {
    super.viewDidLoad()
    self.view.backgroundColor = .white
    mainImageView = UIImageView(frame: self.view.frame)
    tempImageView = UIImageView(frame: self.view.frame)
    self.view.addSubview(mainImageView!)
    self.view.addSubview(tempImageView!)
    addColorPicker()
  }

  func addColorPicker() {
    colorPicker = ChromaColorPicker(frame: CGRect(x: 30, y: 30, width: 150, height: 150))
    colorPicker.delegate = self
    colorPicker.padding = 10
    colorPicker.stroke = 3
    colorPicker.currentAngle = Float(M_PI)
    self.view.addSubview(colorPicker)
  }

  override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    self.swiped = false
    if let touch = touches.first {
      self.lastPoint = touch.location(in: self.view)
    }
  }

  override open func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    self.swiped = true
    if let touch = touches.first {
      let currentPoint = touch.location(in: self.view)
      self.drawLineFrom(fromPoint: self.lastPoint, toPoint: currentPoint)
      self.lastPoint = currentPoint
    }
  }

  override open func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    if !self.swiped {
      self.drawLineFrom(fromPoint: self.lastPoint, toPoint: self.lastPoint)
    }

    // Merge tempImageView into mainImageView
    UIGraphicsBeginImageContext(self.mainImageView.frame.size)
    self.mainImageView.image?.draw(in: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height), blendMode: CGBlendMode.normal, alpha: 1.0)
    self.tempImageView.image?.draw(in: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height), blendMode: CGBlendMode.normal, alpha: self.opacity)
    self.mainImageView.image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()

    self.tempImageView.image = nil
  }

  func drawLineFrom(fromPoint: CGPoint, toPoint: CGPoint) {
    UIGraphicsBeginImageContext(self.view.frame.size)
    let context = UIGraphicsGetCurrentContext()
    self.tempImageView.image?.draw(in: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height))

    context?.move(to: fromPoint)
    context?.addLine(to: toPoint)
    context?.setLineCap(CGLineCap.round)
    context?.setLineWidth(self.brushWidth)
    context?.setStrokeColor(red: self.red, green: self.green, blue: self.blue, alpha: 1.0)
    context?.setBlendMode(CGBlendMode.normal)
    context?.strokePath()

    self.tempImageView.image = UIGraphicsGetImageFromCurrentImageContext()
    self.tempImageView.alpha = self.opacity
    UIGraphicsEndImageContext()
  }
}

// MARK: - ColorPickerDelegate
extension MainViewController: ChromaColorPickerDelegate{
  public func colorPickerDidChooseColor(_ colorPicker: ChromaColorPicker, color: UIColor) {
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
