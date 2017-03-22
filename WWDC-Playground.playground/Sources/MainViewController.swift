// Created by Kirill Averyanov


import UIKit

open class MainViewController: UIViewController {

  struct corners {
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

  struct savePoint {
    var point: CGPoint
    var timeBefore: TimeInterval = 0
    var owner: UIImageView
    init(point: CGPoint, timeBefore: TimeInterval, owner: UIImageView) {
      self.point = point
      self.timeBefore = timeBefore
      self.owner = owner
    }
  }

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
  var savedImageViews = [UIImageView]()
  var isAnimate: Bool = false
  var cornersImage = corners()
  var pointsAnimation = [savePoint]()

  var penButton: UIButton! {
    didSet {
      penButton.setImage(UIImage.init(named: "pen.png"), for: .normal)
      penButton.addTarget(self, action: #selector(penButtonPressed(_:)), for: .touchUpInside)
    }
  }
  var markerButton: UIButton! {
    didSet {
      markerButton.setImage(UIImage.init(named: "marker.png"), for: .normal)
      markerButton.addTarget(self, action: #selector(markerButtonPressed(_:)), for: .touchUpInside)
    }
  }
  var animateButton: UIButton! {
    didSet {
      animateButton.backgroundColor = .blue
      animateButton.setTitle("Animate", for: .normal)
      animateButton.addTarget(self, action: #selector(animateButtonPressed(_:)), for: .touchUpInside)
    }
  }
  var beginAnimationButton: UIButton! {
    didSet {
      beginAnimationButton.backgroundColor = .blue
      beginAnimationButton.setTitle("Begin Animate", for: .normal)
      beginAnimationButton.addTarget(self, action: #selector(beginAnimationButtonPressed(_:)), for: .touchUpInside)
    }
  }

  override open func viewDidLoad() {
    super.viewDidLoad()
    registerComponents()
  }

  func registerComponents() {
    self.view.backgroundColor = .white
    mainImageView = UIImageView(frame: self.view.frame)
    tempImageView = UIImageView(frame: self.view.frame)
    penButton = UIButton(frame: CGRect(x: 250, y: 30, width: 100, height: 200))
    markerButton = UIButton(frame: CGRect(x: 320, y: 30, width: 100, height: 200))
    animateButton = UIButton(frame: CGRect(x: 400, y: 30, width: 100, height: 50))
    beginAnimationButton = UIButton(frame: CGRect(x: 550, y: 30, width: 150, height: 50))
    view.addSubview(mainImageView!)
    view.addSubview(tempImageView!)
    view.addSubview(penButton)
    view.addSubview(markerButton)
    view.addSubview(animateButton)
    view.addSubview(beginAnimationButton)
    addColorPicker()
  }

  func addColorPicker() {
    colorPicker = ChromaColorPicker(frame: CGRect(x: 30, y: 30, width: sizeOfColorPicker, height: sizeOfColorPicker))
    colorPicker.delegate = self
    colorPicker.padding = 10
    colorPicker.stroke = 3
    colorPicker.currentAngle = Float(M_PI)
    view.addSubview(colorPicker)
  }

  func penButtonPressed(_ sender: UIButton) {
    brushWidth = 5.0
  }

  func markerButtonPressed(_ sender: UIButton) {
    brushWidth = 10.0
  }

  func animateButtonPressed(_ sender: UIButton) {
    mainImageView.image = nil
    isAnimate = !isAnimate
    guard savedImageViews.count > 0 else { return }
    for imageView in savedImageViews {
      isAnimate ? self.view.addSubview(imageView) : imageView.removeFromSuperview()
    }
    pointsAnimation.removeAll()
    pointsAnimation.append(savePoint(point: CGPoint(), timeBefore: Date().timeIntervalSince1970, owner: UIImageView()))
  }

  func beginAnimationButtonPressed(_ sender: UIButton) {
    guard pointsAnimation.count > 0 else { return }
    isAnimate = false
    print(pointsAnimation)
    for i in 1..<pointsAnimation.count {
      let time = pointsAnimation[i].timeBefore - pointsAnimation[i - 1].timeBefore
      let point = pointsAnimation[i]
      UIView.animate(withDuration: time, animations: {
        point.owner.center = point.point
      })
    }
  }

  override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesBegan(touches, with: event)
    if isAnimate { return }
    self.swiped = false
    if let touch = touches.first {
      self.lastPoint = touch.location(in: self.view)
      cornersImage = corners(point: lastPoint)
    }
  }

  override open func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesMoved(touches, with: event)
    if isAnimate { return }
    self.swiped = true
    if let touch = touches.first {
      let currentPoint = touch.location(in: self.view)
      self.drawLineFrom(fromPoint: self.lastPoint, toPoint: currentPoint)
      self.lastPoint = currentPoint
      checkCorners(point: lastPoint)
    }
  }

  override open func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesEnded(touches, with: event)
    if isAnimate { return }
    if !self.swiped {
      self.drawLineFrom(fromPoint: self.lastPoint, toPoint: self.lastPoint)
      checkCorners(point: lastPoint)
    }

    // Merge tempImageView into mainImageView
    UIGraphicsBeginImageContext(self.mainImageView.frame.size)
    self.mainImageView.image?.draw(in: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height), blendMode: CGBlendMode.normal, alpha: 1.0)
    self.tempImageView.image?.draw(in: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height), blendMode: CGBlendMode.normal, alpha: self.opacity)
    self.mainImageView.image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    if let image = tempImageView.image{
      let imageView = UIImageView(image: image)
      imageView.isUserInteractionEnabled = true
      let width = cornersImage.right - cornersImage.left
      let height = cornersImage.up - cornersImage.down
      imageView.frame.size = CGSize(width: width, height: height)
      imageView.image = imageView.image?.cropToBounds(posX: cornersImage.left,
                                    posY: cornersImage.down,
                                    width: width,
                                    height: height)
      imageView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(imageDragged(gesture:))))
      savedImageViews.append(imageView)
    }
    self.tempImageView.image = nil
  }


}

// MARK: - Working with images
extension MainViewController {

  func checkCorners(point: CGPoint) {
    let lineWidth: CGFloat = 10 // for line width
    cornersImage.left = point.x < cornersImage.left ? point.x - lineWidth : cornersImage.left
    cornersImage.right = point.x > cornersImage.right ? point.x + lineWidth: cornersImage.right
    cornersImage.down = point.y < cornersImage.down ? point.y - lineWidth: cornersImage.down
    cornersImage.up = point.y > cornersImage.up ? point.y + lineWidth: cornersImage.up
  }

  func imageDragged(gesture: UIPanGestureRecognizer) {
    let imageView = gesture.view as! UIImageView
    let point = gesture.location(in: view)
    imageView.center = point
    pointsAnimation.append(savePoint(point: point,
                                     timeBefore: Date().timeIntervalSince1970,
                                     owner: imageView))
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
    }, completion: { done in
      UIView.animate(withDuration: 0.2, animations: {
        self.view.transform = CGAffineTransform.identity
      })
    })
  }
}
