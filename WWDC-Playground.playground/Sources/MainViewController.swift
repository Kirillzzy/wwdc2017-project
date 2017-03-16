// Created by Kirill Averyanov


import UIKit

open class MainViewController: UIViewController {

  var lastPoint = CGPoint.zero
  var red: CGFloat = 0.0 {
    didSet {
      showColorPickerButton.color = UIColor(displayP3Red: red, green: green, blue: blue, alpha: 1.0)
    }
  }
  var green: CGFloat = 0.999999916517394
  var blue: CGFloat = 1.0
  var brushWidth: CGFloat = 10.0
  var opacity: CGFloat = 1.0
  var swiped = false
  var colorPicker: ChromaColorPicker!
  var mainImageView: UIImageView!
  var tempImageView: UIImageView!
  var isHiddenColorPicker: Bool! {
    didSet {
      let osX = colorPicker.isHidden ? 50 : 0
      let osY = colorPicker.isHidden ? 150 : 0
      let size = 200 //colorPicker.isHidden ? 300 : 0
      UIView.animate(withDuration: Double(0.17), animations: {
        self.colorPicker.frame = CGRect(x: osX, y: osY, width: size, height: size)
        self.colorPicker.isHidden = self.colorPicker.isHidden ? false : true
      })
    }
  }
  var showColorPickerButton: ChromaAddButton! {
    didSet {
      showColorPickerButton.color = UIColor(displayP3Red: red, green: green, blue: blue, alpha: 1.0)
      showColorPickerButton.addTarget(self, action: #selector(showColorPickerButtonPressed(_:)), for: .touchUpInside)
    }
  }

  override open func viewDidLoad() {
    super.viewDidLoad()
    self.view.backgroundColor = .white
    mainImageView = UIImageView(frame: self.view.frame)
    tempImageView = UIImageView(frame: self.view.frame)
    showColorPickerButton = ChromaAddButton(frame: CGRect(x: 50, y: 50, width: 50, height: 50))
    self.view.addSubview(mainImageView!)
    self.view.addSubview(tempImageView!)
    self.view.addSubview(showColorPickerButton)
    addColorPicker()
    isHiddenColorPicker = true
  }

  func addColorPicker() {
    colorPicker = ChromaColorPicker(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
    colorPicker.delegate = self
    colorPicker.padding = 10
    colorPicker.stroke = 3
    colorPicker.currentAngle = Float(M_PI)
    self.view.addSubview(colorPicker)
  }

  func showColorPickerButtonPressed(_ sender: Any) {
    isHiddenColorPicker = !isHiddenColorPicker
  }

  override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    self.swiped = false
    isHiddenColorPicker = true
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