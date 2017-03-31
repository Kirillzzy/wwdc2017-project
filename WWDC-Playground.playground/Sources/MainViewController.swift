// Created by Kirill Averyanov


import UIKit

open class MainViewController: UIViewController {

  let timeOfAnimation: TimeInterval = 0.02
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
  var sizeOfColorPicker: CGFloat = 150.0
  var isAnimate: Bool = false
  var cornersImage = Corners()
  var instrumentsView = UIView()
  var timer: Timer!
  var index: Int = 1
  var arrowButton: UIButton!

  var savedImageViews = [UIImageView]() {
    didSet {
      animateButton.isEnabled = savedImageViews.count > 0 ? true : false
      stopGuideAnimation()
      if savedImageViews.count == 1 {
        let points: [CGPoint] = [
          CGPoint(x: 360, y: 40),
          CGPoint(x: 390, y: 40),
          CGPoint(x: 360, y: 40),
          CGPoint(x: 390, y: 40),
          CGPoint(x: 360, y: 40)
        ]
        showArrow(x: 390, y: 40, image: UIImage.init(named: "Images/arrow.png")!, points: points, timeOfAnimation: 1.5, textLabel: "Tap on button 'Animate'")
      }
    }
  }

  var pointsAnimation = [SavePoint]() {
    didSet {
      beginAnimationButton.isEnabled = pointsAnimation.count > 1 ? true : false
      if pointsAnimation.count == 25 {
        removeArrowButton()
        let points: [CGPoint] = [
          CGPoint(x: 500, y: 50),
          CGPoint(x: 470, y: 50),
          CGPoint(x: 500, y: 50),
          CGPoint(x: 470, y: 50),
          CGPoint(x: 500, y: 50)
        ]
        showArrow(x: 470, y: 50, image: UIImage.init(named: "Images/arrow.png")!, points: points, timeOfAnimation: 1.5, textLabel: "Tap on button 'Begin Animation'")
      }
    }
  }
  var lineImageView: UIImageView! {
    didSet {
      lineImageView.image = UIImage.init(named: "Images/lineIcon.png")
    }
  }
  var penButton: ActionButton! {
    didSet {
      penButton.setImage(UIImage.init(named: "Images/pen.png"), for: .normal)
      penButton.addTarget(self, action: #selector(penButtonPressed(_:)), for: .touchUpInside)
    }
  }
  var removeAllButton: ActionButton! {
    didSet {
      removeAllButton.setImage(UIImage.init(named: "Images/remove.png"), for: .normal)
      removeAllButton.addTarget(self, action: #selector(removeAllButtonPressed), for: .touchUpInside)
    }
  }
  var animateButton: ActionButton! {
    didSet {
      animateButton.setImage(UIImage.init(named: "Images/animateButton.png"), for: .normal)
      animateButton.addTarget(self, action: #selector(animateButtonPressed(_:)), for: .touchUpInside)
      animateButton.isEnabled = false
    }
  }
  var beginAnimationButton: ActionButton! {
    didSet {
      beginAnimationButton.setImage(UIImage.init(named: "Images/begin.png"), for: .normal)
      beginAnimationButton.addTarget(self, action: #selector(beginAnimationButtonPressed(_:)), for: .touchUpInside)
      beginAnimationButton.isEnabled = false
    }
  }
  var sizeSlider: UISlider! {
    didSet {
      sizeSlider.minimumValue = 5
      sizeSlider.maximumValue = 15
      sizeSlider.value = 10
      sizeSlider.isEnabled = true
      sizeSlider.addTarget(self, action: #selector(sliderValueDidChanged(_:)), for: .valueChanged)
    }
  }
  var guideButton: ActionButton! {
    didSet {
      guideButton.setImage(UIImage.init(named: "Images/guide.png"), for: .normal)
      guideButton.addTarget(self, action: #selector(showGuide), for: .touchUpInside)
    }
  }
  var animateGuide: AnimationGuide! {
    didSet {
      let point = view.center
      let width: CGFloat = 100
      let height = width
      animateGuide.button = UIButton(frame: CGRect(x: point.x - width / 2, y: point.y - height / 2, width: width, height: height))
      animateGuide.button.setImage(UIImage.init(named: "Images/drawingPen.png"), for: .normal)
      animateGuide.label = UIButton(frame: CGRect(x: view.center.x - width * 2, y: point.y - height * 3, width: width * 4, height: 40))
      animateGuide.label.setTitle("Draw something like me", for: .normal)
      animateGuide.label.titleLabel?.font = UIFont(name: "HelveticaNeue-UltraLight", size: 30)
      animateGuide.label.setTitleColor(.darkGray, for: .normal)
    }
  }

  // MARK: - ViewDidLoad()
  // ------------- VIEW DID LOAD ---------------- //
  override open func viewDidLoad() {
    super.viewDidLoad()
    self.view.backgroundColor = .white
    startExecude()
  }

  func startExecude() {
    registerComponents()
    showGuide()
  }

  func registerComponents() {
    instrumentsView = UIView(frame: CGRect(origin: view.frame.origin, size: CGSize(width: view.frame.size.width, height: 180)))
    instrumentsView.backgroundColor = view.backgroundColor
    mainImageView = UIImageView(frame: self.view.frame)
    tempImageView = UIImageView(frame: self.view.frame)
    // registering components
    penButton = ActionButton(frame: CGRect(x: 180, y: 20, width: 100, height: sizeOfColorPicker - 20))
    animateButton = ActionButton(frame: CGRect(x: 270, y: 40, width: sizeOfColorPicker - 50, height: sizeOfColorPicker - 50))
    beginAnimationButton = ActionButton(frame: CGRect(x: 370, y: 45, width: sizeOfColorPicker - 60, height: sizeOfColorPicker - 60))
    removeAllButton = ActionButton(frame: CGRect(x: 470, y: 40, width: sizeOfColorPicker - 50, height: sizeOfColorPicker - 50))
    guideButton = ActionButton(frame: CGRect(x: 570, y: 40, width: sizeOfColorPicker - 50, height: sizeOfColorPicker - 50))
    lineImageView = UIImageView(frame: CGRect(x: instrumentsView.frame.origin.x,
                                              y: instrumentsView.frame.size.height - 16,
                                              width: instrumentsView.frame.size.width, height: 30))
    sizeSlider = UISlider()
    sizeSlider.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi / 2))
    sizeSlider.frame.origin = CGPoint(x: 170, y: 40)
    // adding on view
    view.addSubview(mainImageView!)
    view.addSubview(tempImageView!)
    instrumentsView.addSubview(penButton)
    instrumentsView.addSubview(animateButton)
    instrumentsView.addSubview(beginAnimationButton)
    instrumentsView.addSubview(sizeSlider)
    instrumentsView.addSubview(removeAllButton)
    instrumentsView.addSubview(guideButton)
    view.addSubview(lineImageView)
    view.addSubview(instrumentsView)
    addColorPicker()
  }

  func addColorPicker() {
    colorPicker = ChromaColorPicker(frame: CGRect(x: 30, y: 12, width: sizeOfColorPicker, height: sizeOfColorPicker))
    colorPicker.delegate = self
    colorPicker.padding = 10
    colorPicker.stroke = 3
    colorPicker.currentAngle = .pi
    instrumentsView.addSubview(colorPicker)
  }

  func penButtonPressed(_ sender: UIButton) {
    brushWidth = 10.0
  }

  func removeAllButtonPressed() {
    mainImageView.image = nil
    tempImageView.image = nil
    isAnimate = false
    sizeSlider.value = 10
    for imageView in savedImageViews {
      imageView.removeFromSuperview()
    }
    stopGuideAnimation()
    savedImageViews.removeAll()
    pointsAnimation.removeAll()
    invalidateTimer()
    swiped = false
//    removeArrowButton()
    lastPoint = .zero
  }

  func sliderValueDidChanged(_ sender: UISlider) {
    brushWidth = CGFloat(sender.value)
  }

  func animateButtonPressed(_ sender: UIButton) {
    mainImageView.image = nil
    isAnimate = !isAnimate
    stopGuideAnimation()
    removeArrowButton()
    guard savedImageViews.count > 0 else { return }
    for imageView in savedImageViews {
      //      imageView.frame.origin = imageView.center
      isAnimate ? self.view.addSubview(imageView) : imageView.removeFromSuperview()
    }
    invalidateTimer()
    let points: [CGPoint] = [
      CGPoint(x: view.center.x - 200, y: view.center.y),
      CGPoint(x: view.center.x + 200, y: view.center.y),
      CGPoint(x: view.center.x - 100, y: view.center.y)]
    showArrow(x: view.center.x, y: view.center.y, image: UIImage.init(named: "Images/hand.png")!, points: points, timeOfAnimation: 1.3, textLabel: "Drag images")
    pointsAnimation.removeAll()
    pointsAnimation.append(SavePoint(point: CGPoint(), timeBefore: Date().timeIntervalSince1970, owner: UIImageView()))
  }

  func beginAnimationButtonPressed(_ sender: UIButton) {
    guard pointsAnimation.count > 1 else { return }
    isAnimate = false
    removeArrowButton()
    stopGuideAnimation()
    index = 1
    invalidateTimer()
    timer = Timer.scheduledTimer(timeInterval: timeOfAnimation, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
  }

  func backButtonPressed() {
    guard savedImageViews.count > 0 && !isAnimate else {
      return
    }
    for imageView in savedImageViews {
      imageView.removeFromSuperview()
    }
    savedImageViews.removeAll()
  }

  func updateTimer() {
    let i = index
    index += 1
    // let time = pointsAnimation[i].timeBefore - pointsAnimation[i - 1].timeBefore
    let point = pointsAnimation[i]
    if i == 1 {
      point.owner.center = point.point
      return
    }
    UIView.animate(withDuration: timeOfAnimation * 2, animations: {
      point.owner.center = point.point
    })
    if index >= pointsAnimation.count {
      index = 1
    }
  }

  func invalidateTimer() {
    if let timer = timer {
      timer.invalidate()
    }
  }

  override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesBegan(touches, with: event)
    if isAnimate { return }
    invalidateTimer()
    swiped = false
    if let touch = touches.first {
      if touch.location(in: self.view).y < 240 { return }
      lastPoint = touch.location(in: self.view)
      cornersImage = Corners(point: lastPoint)
    }
  }

  override open func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesMoved(touches, with: event)
    if isAnimate { return }
    invalidateTimer()
    swiped = true
    if let touch = touches.first {
      let currentPoint = touch.location(in: self.view)
      drawLineFrom(fromPoint: self.lastPoint, toPoint: currentPoint)
      lastPoint = currentPoint
      checkCorners(point: lastPoint)
    }
  }

  override open func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesEnded(touches, with: event)
    if isAnimate { return }
    invalidateTimer()
    if !swiped {
      self.drawLineFrom(fromPoint: lastPoint, toPoint: lastPoint)
      checkCorners(point: lastPoint)
    }
    // Merge tempImageView into mainImageView
    UIGraphicsBeginImageContext(self.mainImageView.frame.size)
    mainImageView.image?.draw(in: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height), blendMode: CGBlendMode.normal, alpha: 1.0)
    tempImageView.image?.draw(in: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height), blendMode: CGBlendMode.normal, alpha: self.opacity)
    mainImageView.image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    if let image = tempImageView.image {
      let imageView = UIImageView(image: image)
      imageView.isUserInteractionEnabled = true
      let width = cornersImage.right - cornersImage.left
      let height = cornersImage.up - cornersImage.down
      if width == 0 && height == 0 {
        tempImageView.image = nil
        return
      }
      imageView.frame.size = CGSize(width: width, height: height)
      imageView.image = imageView.image?.cropToBounds(posX: cornersImage.left,
                                                      posY: cornersImage.down,
                                                      width: width,
                                                      height: height)
      imageView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(imageDragged(gesture:))))
      let point = view.center
      imageView.frame.origin = CGPoint(x: point.x - imageView.frame.size.width / 2,
                                       y: point.y - imageView.frame.size.height / 2)
      savedImageViews.append(imageView)
    }
    tempImageView.image = nil
  }
}

// MARK: - Setup Guides
extension MainViewController {

  func showGuide() {
    removeAllButtonPressed()
    stopGuideAnimation()
    invalidateTimer()
    if isAnimate {
      return
    }
    animateGuide = AnimationGuide()
    let animationImageView = animateGuide.button!
    guard let label = animateGuide.label else {
      return
    }
    view.addSubview(label)
    view.addSubview(animationImageView)
    let timeOfAnimation: TimeInterval = 1.7
    UIView.animate(withDuration: timeOfAnimation, animations: {
      animationImageView.frame.origin = CGPoint(x: animationImageView.frame.origin.x - 200, y: animationImageView.frame.origin.y - 100)
    })
    UIView.animate(withDuration: timeOfAnimation, delay: timeOfAnimation, options: .allowAnimatedContent, animations: {
      animationImageView.frame.origin = CGPoint(x: animationImageView.frame.origin.x + 300, y: animationImageView.frame.origin.y)
    }, completion: nil)
    UIView.animate(withDuration: timeOfAnimation, delay: timeOfAnimation * 2, options: .allowAnimatedContent, animations: {
      animationImageView.frame.origin = CGPoint(x: animationImageView.frame.origin.x, y: animationImageView.frame.origin.y + 300)
    }, completion: nil)
    UIView.animate(withDuration: timeOfAnimation, delay: timeOfAnimation * 3, options: .allowAnimatedContent, animations: {
      animationImageView.frame.origin = CGPoint(x: animationImageView.frame.origin.x - 300, y: animationImageView.frame.origin.y)
    }, completion: nil)
    UIView.animate(withDuration: timeOfAnimation, delay: timeOfAnimation * 4, options: .allowAnimatedContent, animations: {
      animationImageView.frame.origin = CGPoint(x: animationImageView.frame.origin.x, y: animationImageView.frame.origin.y - 300)
    }, completion: nil)
    //    DispatchQueue.main.asyncAfter(deadline: .now() + timeOfAnimation * 5) {
    //      self.showGuide()
    //    }
    UIView.animate(withDuration: timeOfAnimation, delay: timeOfAnimation * 5, options: .allowAnimatedContent, animations: {
      label.alpha = 0
      animationImageView.alpha = 0
    }, completion: { _ in
      label.removeFromSuperview()
      animationImageView.removeFromSuperview()
    })
  }

  func stopGuideAnimation() {
    UIView.commitAnimations()
    if let animateGuide = animateGuide {
      if let imageView = animateGuide.button {
        imageView.removeFromSuperview()
      }
      if let label = animateGuide.label {
        label.setTitle("Cool!", for: .normal)
        let timeOfAnimation = 2.0
        UIView.animate(withDuration: timeOfAnimation, animations: {
          label.alpha = 0
        }, completion: { _ in
          label.removeFromSuperview()
        })
      }
    }
  }

  func showArrow(x: CGFloat, y: CGFloat, image: UIImage, points: [CGPoint], timeOfAnimation: TimeInterval, textLabel: String?) {
    removeArrowButton()
    if let textLabel = textLabel {
      animateGuide.label.setTitle(textLabel, for: .normal)
      animateGuide.label.alpha = 1
      view.addSubview(animateGuide.label)
    }
    arrowButton = UIButton(frame: CGRect(x: x, y: y, width: 70, height: 70))
    arrowButton.setImage(image, for: .normal)
    view.addSubview(arrowButton)
    for i in 0..<points.count {
      UIView.animate(withDuration: timeOfAnimation, delay: timeOfAnimation * Double(i), options: .allowAnimatedContent, animations: {
        self.arrowButton.frame.origin = points[i]
      }, completion: nil)
    }

    UIView.animate(withDuration: timeOfAnimation, delay: timeOfAnimation * Double(points.count), options: .allowAnimatedContent, animations: {
      self.arrowButton.alpha = 0
    }, completion: { _ in
      self.removeArrowButton()
    })
  }

  func removeArrowButton() {
    UIView.commitAnimations()
    if let arrow = self.arrowButton {
      arrow.removeFromSuperview()
    }
    if let label = animateGuide.label {
      label.removeFromSuperview()
    }
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
    pointsAnimation.append(SavePoint(point: point,
                                     timeBefore: Date().timeIntervalSince1970,
                                     owner: imageView))
  }

  func drawLineFrom(fromPoint: CGPoint, toPoint: CGPoint) {
    UIGraphicsBeginImageContext(self.view.frame.size)
    let context = UIGraphicsGetCurrentContext()
    self.tempImageView.image?.draw(in: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height))
//    let blend: CGBlendMode = isClearing ? .clear : .normal
    context?.move(to: fromPoint)
    context?.addLine(to: toPoint)
    context?.setLineCap(CGLineCap.round)
    context?.setLineWidth(self.brushWidth)
    context?.setStrokeColor(red: self.red, green: self.green, blue: self.blue, alpha: 1.0)
//    context?.setBlendMode(blend)
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
    }, completion: { _ in
      UIView.animate(withDuration: 0.2, animations: {
        self.view.transform = CGAffineTransform.identity
      })
    })
  }
}
