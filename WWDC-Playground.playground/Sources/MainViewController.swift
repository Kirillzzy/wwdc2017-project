// Created by Kirill Averyanov


import UIKit

open class MainViewController: UIViewController {

  struct Corners {
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

  struct SavePoint {
    var point: CGPoint
    var timeBefore: TimeInterval = 0
    var owner: UIImageView
    init(point: CGPoint, timeBefore: TimeInterval, owner: UIImageView) {
      self.point = point
      self.timeBefore = timeBefore
      self.owner = owner
    }
  }

  struct AnimationGuide {
    var label: UILabel!
    var imageView: UIImageView!

    init(){
      label = UILabel()
      imageView = UIImageView()
    }
  }

  let timeOfAnimation: TimeInterval = 0.01

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
  var savedImageViews = [UIImageView]() {
    didSet {
      animateButton.isEnabled = savedImageViews.count > 0 ? true : false
    }
  }
  var isAnimate: Bool = false
  var cornersImage = Corners()
  var instrumentsView = UIView()
  var isClearing: Bool = false
  var pointsAnimation = [SavePoint]() {
    didSet {
      beginAnimationButton.isEnabled = pointsAnimation.count > 1 ? true : false
    }
  }
  var timer: Timer!
  var index: Int = 1

  var lineImageView: UIImageView! {
    didSet {
      lineImageView.image = UIImage.init(named: "Images/lineIcon.png")
    }
  }
  var penButton: UIButton! {
    didSet {
      penButton.setImage(UIImage.init(named: "Images/pen.png"), for: .normal)
      penButton.addTarget(self, action: #selector(penButtonPressed(_:)), for: .touchUpInside)
    }
  }
  var eraserButton: UIButton! {
    didSet {
      eraserButton.setImage(UIImage.init(named: "Images/eraser.png"), for: .normal)
      eraserButton.addTarget(self, action: #selector(eraserButtonPressed(_:)), for: .touchUpInside)
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
      beginAnimationButton.setImage(UIImage.init(named: "Images/playIcon.png"), for: .normal)
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
      animateGuide.imageView = UIImageView(frame: CGRect(x: point.x - width / 2, y: point.y - height / 2, width: width, height: height))
      animateGuide.imageView.image = UIImage.init(named: "Images/drawingPen.png")
      animateGuide.label = UILabel(frame: CGRect(x: point.x - width, y: point.y - height * 2.5, width: width * 4, height: 40))
      animateGuide.label.text = "Draw something like me"
      animateGuide.label.font = UIFont(name: "HelveticaNeue-UltraLight", size: 30)
      animateGuide.label.textColor = .gray
    }
  }

  override open func viewDidLoad() {
    super.viewDidLoad()
    registerComponents()
    showGuide()
  }

  func registerComponents() {
    self.view.backgroundColor = .white
    instrumentsView = UIView(frame: CGRect(origin: view.frame.origin, size: CGSize(width: view.frame.size.width, height: 240)))
    instrumentsView.backgroundColor = view.backgroundColor //UIColor.lightGray
    mainImageView = UIImageView(frame: self.view.frame)
    tempImageView = UIImageView(frame: self.view.frame)
    penButton = UIButton(frame: CGRect(x: 200, y: 10, width: 100, height: 150))
    eraserButton = UIButton(frame: CGRect(x: 300, y: 10, width: 50, height: 150))
    animateButton = ActionButton(frame: CGRect(x: 380, y: 10, width: 120, height: 120))
    removeAllButton = ActionButton(frame: CGRect(x: 220, y: 175, width: 60, height: 60))
    beginAnimationButton = ActionButton(frame: CGRect(x: 510, y: 10, width: 120, height: 120))
    guideButton = ActionButton(frame: CGRect(x: 300, y: 175, width: 60, height: 60))
    lineImageView = UIImageView(frame: CGRect(x: instrumentsView.frame.origin.x,
                                              y: instrumentsView.frame.size.height - 16,
                                              width: instrumentsView.frame.size.width, height: 30))
    sizeSlider = UISlider()
    sizeSlider.frame.origin = CGPoint(x: 80, y: 200)
    view.addSubview(mainImageView!)
    view.addSubview(tempImageView!)
    instrumentsView.addSubview(penButton)
    instrumentsView.addSubview(eraserButton)
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
    colorPicker = ChromaColorPicker(frame: CGRect(x: 30, y: 10, width: sizeOfColorPicker, height: sizeOfColorPicker))
    colorPicker.delegate = self
    colorPicker.padding = 10
    colorPicker.stroke = 3
    colorPicker.currentAngle = Float(M_PI)
    instrumentsView.addSubview(colorPicker)
  }

  func penButtonPressed(_ sender: UIButton) {
    brushWidth = 10.0
  }

  func eraserButtonPressed(_ sender: UIButton) {
    isClearing = !isClearing
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
    if let timer = timer {
      timer.invalidate()
    }
  }

  func sliderValueDidChanged(_ sender: UISlider) {
    brushWidth = CGFloat(sender.value)
  }

  func animateButtonPressed(_ sender: UIButton) {
    mainImageView.image = nil
    isAnimate = !isAnimate
    guard savedImageViews.count > 0 else { return }
    for imageView in savedImageViews {
      //      imageView.frame.origin = imageView.center
      isAnimate ? self.view.addSubview(imageView) : imageView.removeFromSuperview()
    }
    pointsAnimation.removeAll()
    pointsAnimation.append(SavePoint(point: CGPoint(), timeBefore: Date().timeIntervalSince1970, owner: UIImageView()))
  }

  func beginAnimationButtonPressed(_ sender: UIButton) {
    guard pointsAnimation.count > 1 else { return }
    isAnimate = false
    index = 1
    if let timer = timer {
      timer.invalidate()
    }
    timer = Timer.scheduledTimer(timeInterval: timeOfAnimation, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
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
      //      timer.invalidate()
    }
  }

  override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesBegan(touches, with: event)
    if isAnimate { return }
    self.swiped = false
    if let touch = touches.first {
      self.lastPoint = touch.location(in: self.view)
      cornersImage = Corners(point: lastPoint)
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
    if let image = tempImageView.image {
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
      let point = view.center
      imageView.frame.origin = CGPoint(x: point.x - imageView.frame.size.width / 2,
                                       y: point.y - imageView.frame.size.height / 2)
      savedImageViews.append(imageView)
    }
    self.tempImageView.image = nil
  }

  func showGuide() {
    stopGuideAnimation()
    if isAnimate {
      return
    }
    animateGuide = AnimationGuide()
    let animationImageView = animateGuide.imageView!
    let label = animateGuide.label!
    view.addSubview(animationImageView)
    view.addSubview(label)
    let timeOfAnimation: TimeInterval = 1.7
    UIView.animate(withDuration: timeOfAnimation, animations: {
      animationImageView.frame.origin = CGPoint(x: animationImageView.frame.origin.x - 200, y: animationImageView.frame.origin.y - 100)
    })
    DispatchQueue.main.asyncAfter(deadline: .now() + timeOfAnimation) {
      UIView.animate(withDuration: timeOfAnimation, animations: {
        animationImageView.frame.origin = CGPoint(x: animationImageView.frame.origin.x + 300, y: animationImageView.frame.origin.y)
      })
    }
    DispatchQueue.main.asyncAfter(deadline: .now() + timeOfAnimation * 2) {
      UIView.animate(withDuration: timeOfAnimation, animations: {
        animationImageView.frame.origin = CGPoint(x: animationImageView.frame.origin.x, y: animationImageView.frame.origin.y + 300)
      })
    }
    DispatchQueue.main.asyncAfter(deadline: .now() + timeOfAnimation * 3) {
      UIView.animate(withDuration: timeOfAnimation, animations: {
        animationImageView.frame.origin = CGPoint(x: animationImageView.frame.origin.x - 300, y: animationImageView.frame.origin.y)
      })
    }
    DispatchQueue.main.asyncAfter(deadline: .now() + timeOfAnimation * 4) {
      UIView.animate(withDuration: timeOfAnimation, animations: {
        animationImageView.frame.origin = CGPoint(x: animationImageView.frame.origin.x, y: animationImageView.frame.origin.y - 300)
      })
    }
    DispatchQueue.main.asyncAfter(deadline: .now() + timeOfAnimation * 5) {
      UIView.animate(withDuration: timeOfAnimation, animations: {
        label.alpha = 0
        animationImageView.alpha = 0
      })
      DispatchQueue.main.asyncAfter(deadline: .now() + timeOfAnimation) {
        label.removeFromSuperview()
        animationImageView.removeFromSuperview()
      }
    }
  }

  func stopGuideAnimation() {
    if let animateGuide = animateGuide {
      if let imageView = animateGuide.imageView {
        imageView.removeFromSuperview()
      }
      if let label = animateGuide.label {
        label.removeFromSuperview()
      }
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
    let blend: CGBlendMode = isClearing ? .clear : .normal
    context?.move(to: fromPoint)
    context?.addLine(to: toPoint)
    context?.setLineCap(CGLineCap.round)
    context?.setLineWidth(self.brushWidth)
    context?.setStrokeColor(red: self.red, green: self.green, blue: self.blue, alpha: 1.0)
    context?.setBlendMode(blend)
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
