// Created by Kirill Averyanov


import UIKit

open class ChromaAddButton: UIButton {
  var color = UIColor.gray{
    didSet{
      if let layer = circleLayer{
        layer.fillColor = color.cgColor
        layer.strokeColor = color.darkerColor(0.075).cgColor
      }
    }
  }
  override open var frame: CGRect{
    didSet{
      self.layoutCircleLayer()
      self.layoutPlusIconLayer()
    }
  }
  var circleLayer: CAShapeLayer?
  var plusIconLayer: CAShapeLayer?


  override public init(frame: CGRect) {
    super.init(frame: frame)
    self.createGraphics()
  }
  required public init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    self.createGraphics()
  }

  func createGraphics(){
    circleLayer = CAShapeLayer()
    self.layoutCircleLayer()
    circleLayer!.fillColor = color.cgColor
    self.layer.addSublayer(circleLayer!)
    let plusPath = UIBezierPath()
    plusPath.move(to: CGPoint(x: self.bounds.width/2 - self.bounds.width/8, y: self.bounds.height/2))
    plusPath.addLine(to: CGPoint(x: self.bounds.width/2 + self.bounds.width/8, y: self.bounds.height/2))
    plusPath.move(to: CGPoint(x: self.bounds.width/2, y: self.bounds.height/2 + self.bounds.height/8))
    plusPath.addLine(to: CGPoint(x: self.bounds.width/2, y: self.bounds.height/2 - self.bounds.height/8))

    plusIconLayer = CAShapeLayer()
    self.layoutPlusIconLayer()
    plusIconLayer!.strokeColor = UIColor.white.cgColor
    self.layer.addSublayer(plusIconLayer!)
  }

  func layoutCircleLayer(){
    if let layer = circleLayer{
      layer.path = UIBezierPath(ovalIn: self.bounds).cgPath
      layer.lineWidth = frame.width * 0.04
    }
  }

  func layoutPlusIconLayer(){
    if let layer = plusIconLayer{
      let plusPath = UIBezierPath()
      plusPath.move(to: CGPoint(x: self.bounds.width/2 - self.bounds.width/8, y: self.bounds.height/2))
      plusPath.addLine(to: CGPoint(x: self.bounds.width/2 + self.bounds.width/8, y: self.bounds.height/2))
      plusPath.move(to: CGPoint(x: self.bounds.width/2, y: self.bounds.height/2 + self.bounds.height/8))
      plusPath.addLine(to: CGPoint(x: self.bounds.width/2, y: self.bounds.height/2 - self.bounds.height/8))

      layer.path = plusPath.cgPath
      layer.lineWidth = frame.width * 0.03
    }
  }

}

public protocol ChromaColorPickerDelegate {
  /* Called when the user taps the add button in the center */
  func colorPickerDidChooseColor(_ colorPicker: ChromaColorPicker, color: UIColor)
}

public class ChromaColorPicker: UIControl {
  open var shadeSlider: ChromaShadeSlider!
  var handleView: ChromaHandle!
  open var handleLine: CAShapeLayer!
  var addButton: ChromaAddButton!

  private(set) var currentColor = UIColor.red
  open var delegate: ChromaColorPickerDelegate?
  open var currentAngle: Float = 0
  private(set) var radius: CGFloat = 0
  open var stroke: CGFloat = 1
  open var padding: CGFloat = 15
  open var handleSize: CGSize{
    get{ return CGSize(width: self.bounds.width * 0.1, height: self.bounds.height * 0.1) }
  }

  //MARK: - Initialization
  override public init(frame: CGRect) {
    super.init(frame: frame)
    self.commonInit()
  }

  required public init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    self.commonInit()
  }

  private func commonInit(){
    self.backgroundColor = UIColor.clear

    let minDimension = min(self.bounds.size.width, self.bounds.size.height)
    radius = minDimension/2 - handleSize.width/2
    handleView = ChromaHandle(frame: CGRect(x: 0,y: 0, width: handleSize.width, height: handleSize.height))
    handleView.shadowOffset = CGSize(width: 0,height: 2)
    let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(ChromaColorPicker.handleWasMoved(_:)))
    handleView.addGestureRecognizer(panRecognizer)
    addButton = ChromaAddButton()
    self.layoutAddButton()
    addButton.addTarget(self, action: #selector(ChromaColorPicker.addButtonPressed(_:)), for: .touchUpInside)
    handleLine = CAShapeLayer()
    handleLine.lineWidth = 2
    handleLine.strokeColor = UIColor.white.withAlphaComponent(0.2).cgColor
    shadeSlider = ChromaShadeSlider()
    shadeSlider.delegate = self
    self.layoutShadeSlider()
    self.layer.addSublayer(handleLine)
    self.addSubview(shadeSlider)
    self.addSubview(handleView)
    self.addSubview(addButton)
  }

  override public func willMove(toSuperview newSuperview: UIView?) {
    currentColor = colorOnWheelFromAngle(currentAngle)
    handleView.center = positionOnWheelFromAngle(currentAngle)
    self.layoutHandleLine()
    handleView.color = currentColor
    addButton.color = currentColor
    shadeSlider.primaryColor = currentColor
  }

  func adjustToColor(_ color: UIColor){
    var saturation: CGFloat = 0.0
    var brightness: CGFloat = 0.0
    var hue: CGFloat = 0.0
    var alpha: CGFloat = 0.0

    color.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
    let newColor = UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: alpha)

    shadeSlider.primaryColor = UIColor(hue: hue, saturation: 1, brightness: 1, alpha: 1)

    currentAngle = angleForColor(newColor)
    currentColor = newColor

    if brightness < 1.0 {
      shadeSlider.currentValue = brightness-1
    }else{
      shadeSlider.currentValue = -(saturation-1)
    }
    shadeSlider.updateHandleLocation()
    addButton.color = shadeSlider.currentColor
    self.layoutHandle()
    self.layoutHandleLine()
  }

  override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
    let touchPoint = touches.first!.location(in: self)
    if handleView.frame.contains(touchPoint) {
      self.sendActions(for: .touchDown)
      UIView.animate(withDuration: 0.15, delay: 0, options: .curveEaseIn, animations: { () -> Void in
        self.handleView.transform = CGAffineTransform(scaleX: 1.45, y: 1.45)
      }, completion: nil)
    }
  }
  override public func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    if handleView.transform.d > 1 {
      self.executeHandleShrinkAnimation()
    }
  }

  func handleWasMoved(_ recognizer: UIPanGestureRecognizer) {
    switch(recognizer.state){

    case UIGestureRecognizerState.changed:
      let touchPosition = recognizer.location(in: self)
      self.moveHandleTowardPoint(touchPosition)
      self.sendActions(for: .touchDragInside)
      break

    case UIGestureRecognizerState.ended:
      self.executeHandleShrinkAnimation()
      break

    default:
      break
    }
  }

  private func executeHandleShrinkAnimation(){
    self.sendActions(for: .touchUpInside)
    UIView.animate(withDuration: 0.15, delay: 0, options: .curveEaseOut, animations: { () -> Void in
      self.handleView.transform = CGAffineTransform(scaleX: 1, y: 1)
    }, completion: nil)
  }

  private func moveHandleTowardPoint(_ point: CGPoint){
    currentAngle = angleToCenterFromPoint(point)
    self.layoutHandle()
    self.layoutHandleLine()
    shadeSlider.primaryColor = handleView.color

    if shadeSlider.currentValue == 0 {
      self.updateCurrentColor(shadeSlider.currentColor)
    }
  }

  func addButtonPressed(_ sender: ChromaAddButton){
    //Do a 'bob' animation
    UIView.animate(withDuration: 0.2,
                   delay: 0,
                   options: .curveEaseIn,
                   animations: { () -> Void in
                    sender.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
    }, completion: { (done) -> Void in
      UIView.animate(withDuration: 0.1, animations: { () -> Void in
        sender.transform = CGAffineTransform(scaleX: 1, y: 1)
      })
    })

    delegate?.colorPickerDidChooseColor(self, color: sender.color) //Delegate call
  }


  //MARK: - Drawing
  open override func draw(_ rect: CGRect) {
    super.draw(rect)
    let ctx = UIGraphicsGetCurrentContext()
    drawRainbowCircle(in: ctx, outerRadius: radius - padding, innerRadius: radius - stroke - padding, resolution: 1)
  }

  func drawRainbowCircle(in context: CGContext?, outerRadius: CGFloat, innerRadius: CGFloat, resolution: Float){
    context?.saveGState()
    context?.translateBy(x: self.bounds.midX, y: self.bounds.midY)

    let subdivisions:CGFloat = CGFloat(resolution * 512)

    let innerHeight = (CGFloat(M_PI)*innerRadius)/subdivisions
    let outterHeight = (CGFloat(M_PI)*outerRadius)/subdivisions

    let segment = UIBezierPath()
    segment.move(to: CGPoint(x: innerRadius, y: -innerHeight/2))
    segment.addLine(to: CGPoint(x: innerRadius, y: innerHeight/2))
    segment.addLine(to: CGPoint(x: outerRadius, y: outterHeight/2))
    segment.addLine(to: CGPoint(x: outerRadius, y: -outterHeight/2))
    segment.close()

    for i in 0 ..< Int(ceil(subdivisions)) {
      UIColor(hue: CGFloat(i)/subdivisions, saturation: 1, brightness: 1, alpha: 1).set()
      segment.fill()
      let lineTailSpace = CGFloat(M_PI*2)*outerRadius/subdivisions
      segment.lineWidth = lineTailSpace
      segment.stroke()

      //Rotate to correct location
      let rotate = CGAffineTransform(rotationAngle: -(CGFloat(M_PI*2)/subdivisions))
      segment.apply(rotate)
    }

    context?.translateBy(x: -self.bounds.midX, y: -self.bounds.midY)
    context?.restoreGState()
  }


  //MARK: - Layout Updates
  func layout() {
    self.setNeedsDisplay()

    let minDimension = min(self.bounds.size.width, self.bounds.size.height)
    radius = minDimension/2 - handleSize.width/2

    self.layoutAddButton()
    handleView.frame = CGRect(origin: .zero, size: handleSize)
    self.layoutHandle()

    self.updateCurrentColor(handleView.color)
    shadeSlider.primaryColor = handleView.color

    self.layoutShadeSlider()
    self.layoutHandleLine()
  }

  func layoutAddButton(){
    let addButtonSize = CGSize(width: self.bounds.width/5, height: self.bounds.height/5)
    addButton.frame = CGRect(x: self.bounds.midX - addButtonSize.width/2, y: self.bounds.midY - addButtonSize.height/2, width: addButtonSize.width, height: addButtonSize.height)
  }

  func layoutHandle(){
    let angle = currentAngle
    let newPosition = positionOnWheelFromAngle(angle)
    handleView.center = newPosition
    handleView.color = colorOnWheelFromAngle(angle)
  }
  func layoutHandleLine(){
    let linePath = UIBezierPath()
    linePath.move(to: addButton.center)
    linePath.addLine(to: positionOnWheelFromAngle(currentAngle))
    handleLine.path = linePath.cgPath
  }

  func layoutShadeSlider(){
    /* Calculate proper length for slider */
    let centerPoint = CGPoint(x: bounds.midX, y: bounds.midY)
    let insideRadius = radius - padding

    let pointLeft = CGPoint(x: centerPoint.x + insideRadius*CGFloat(cos(7*M_PI/6)), y: centerPoint.y - insideRadius*CGFloat(sin(7*M_PI/6)))
    let pointRight = CGPoint(x: centerPoint.x + insideRadius*CGFloat(cos(11*M_PI/6)), y: centerPoint.y - insideRadius*CGFloat(sin(11*M_PI/6)))
    let deltaX = pointRight.x - pointLeft.x


    let sliderSize = CGSize(width: deltaX * 0.75, height: 0.08 * (bounds.height - padding*2))
    shadeSlider.frame = CGRect(x: bounds.midX - sliderSize.width/2, y: pointLeft.y - sliderSize.height/2, width: sliderSize.width, height: sliderSize.height)
    shadeSlider.handleCenterX = shadeSlider.bounds.width/2
    shadeSlider.layoutLayerFrames()
  }

  func updateCurrentColor(_ color: UIColor){
    currentColor = color
    addButton.color = color
    self.sendActions(for: .valueChanged)
  }

  //MARK: - Helper Methods
  private func angleToCenterFromPoint(_ point: CGPoint) -> Float {
    let deltaX = Float(self.bounds.midX - point.x)
    let deltaY = Float(self.bounds.midY - point.y)
    let angle = atan2f(deltaX, deltaY)

    var adjustedAngle = angle + Float(M_PI/2)
    if (adjustedAngle < 0){
      adjustedAngle += Float(M_PI*2)
    }

    return adjustedAngle
  }

  private func colorOnWheelFromAngle(_ angle: Float) -> UIColor {
    return UIColor(hue: CGFloat(Double(angle)/(2*M_PI)), saturation: 1, brightness: 1, alpha: 1)
  }

  private func angleForColor(_ color: UIColor) -> Float {
    var hue: CGFloat = 0
    color.getHue(&hue, saturation: nil, brightness: nil, alpha: nil)
    return Float(hue * CGFloat(2*M_PI))
  }

  private func positionOnWheelFromAngle(_ angle: Float) -> CGPoint{
    let buffer = padding + stroke/2
    return CGPoint(x: self.bounds.midX + ((radius - buffer) * CGFloat(cos(-angle))), y: self.bounds.midY + ((radius - buffer) * CGFloat(sin(-angle))))
  }
}


extension ChromaColorPicker: ChromaShadeSliderDelegate{
  open func shadeSliderChoseColor(_ slider: ChromaShadeSlider, color: UIColor) {
    self.updateCurrentColor(color)
  }
}


class ChromaHandle: UIView {
  var color = UIColor.black {
    didSet{
      circleLayer.fillColor = color.cgColor
    }
  }
  override var frame: CGRect{
    didSet { self.layoutCircleLayer() }
  }
  var circleLayer = CAShapeLayer()

  var shadowOffset: CGSize?{
    set{
      if let offset = newValue {
        circleLayer.shadowColor = UIColor.black.cgColor
        circleLayer.shadowRadius = 3
        circleLayer.shadowOpacity = 0.3
        circleLayer.shadowOffset = offset
      }
    }
    get{
      return circleLayer.shadowOffset
    }
  }

  override public init(frame: CGRect) {
    super.init(frame:frame)
    self.backgroundColor = UIColor.clear
    self.layoutCircleLayer()
    circleLayer.strokeColor = UIColor.white.cgColor
    circleLayer.fillColor = color.cgColor

    self.layer.addSublayer(circleLayer)
  }

  func layoutCircleLayer(){
    circleLayer.path = UIBezierPath(ovalIn: self.bounds).cgPath
    circleLayer.strokeColor = UIColor.white.cgColor
    circleLayer.lineWidth = frame.width/8.75 //4
  }

  required public init(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}


class ChromaSliderTrackLayer: CALayer{
  let gradient = CAGradientLayer()

  override public init() {
    super.init()
    gradient.actions = ["position" : NSNull(), "bounds" : NSNull(), "path" : NSNull()]
    self.addSublayer(gradient)
  }
  override init(layer: Any) {
    super.init(layer: layer)
  }
  required public init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

public protocol ChromaShadeSliderDelegate {
  func shadeSliderChoseColor(_ slider: ChromaShadeSlider, color: UIColor)
}

open class ChromaShadeSlider: UIControl {
  var currentValue: CGFloat = 0.0

  let trackLayer = ChromaSliderTrackLayer()
  let handleView = ChromaHandle()
  var handleWidth: CGFloat{ return self.bounds.height }
  var handleCenterX: CGFloat = 0.0
  var delegate: ChromaShadeSliderDelegate?

  var primaryColor = UIColor.gray{
    didSet{
      self.changeColorHue(to: currentColor)
      self.updateGradientTrack(for: primaryColor)
    }
  }
  var currentColor: UIColor{
    get{
      if currentValue < 0 {
        return primaryColor.darkerColor(-currentValue)
      }
      else{
        return primaryColor.lighterColor(currentValue)
      }
    }
  }

  override public init(frame: CGRect) {
    super.init(frame: frame)
    self.commonInit()
  }

  required public init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    self.commonInit()
  }

  private func commonInit(){
    self.backgroundColor = nil
    handleCenterX = self.bounds.width/2

    trackLayer.backgroundColor = UIColor.blue.cgColor
    trackLayer.masksToBounds = true
    trackLayer.actions = ["position" : NSNull(), "bounds" : NSNull(), "path" : NSNull()]
    self.layer.addSublayer(trackLayer)

    handleView.color = UIColor.blue
    handleView.circleLayer.borderWidth = 3
    handleView.isUserInteractionEnabled = false
    self.layer.addSublayer(handleView.layer)

    let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(doubleTapRecognized))
    doubleTapGesture.numberOfTapsRequired = 2
    self.addGestureRecognizer(doubleTapGesture)

    self.layoutLayerFrames()
    self.changeColorHue(to: currentColor)
    self.updateGradientTrack(for: primaryColor)
  }

  override open func didMoveToSuperview() {
    self.updateGradientTrack(for: primaryColor)
  }

  func layoutLayerFrames(){
    trackLayer.frame = self.bounds.insetBy(dx: handleWidth/2, dy: self.bounds.height/4)
    trackLayer.cornerRadius = trackLayer.bounds.height/2

    self.updateGradientTrack(for: primaryColor)
    self.updateHandleLocation()
    self.layoutHandleFrame()
  }

  func layoutHandleFrame(){
    handleView.frame = CGRect(x: handleCenterX - handleWidth/2, y: self.bounds.height/2 - handleWidth/2, width: handleWidth, height: handleWidth)
  }

  func changeColorHue(to newColor: UIColor){
    handleView.color = newColor
    if currentValue != 0 {
      self.delegate?.shadeSliderChoseColor(self, color: newColor)
    }
  }

  func updateGradientTrack(for color: UIColor){
    trackLayer.gradient.frame = trackLayer.bounds
    trackLayer.gradient.startPoint = CGPoint(x: 0, y: 0.5)
    trackLayer.gradient.endPoint = CGPoint(x: 1, y: 0.5)

    trackLayer.gradient.colors = [color.darkerColor(0.65).cgColor, color.cgColor, color.lighterColor(0.65).cgColor]
  }

  func updateHandleLocation(){
    handleCenterX = (currentValue+1)/2 * (bounds.width - handleView.bounds.width) +  handleView.bounds.width/2
    handleView.color = currentColor
    self.layoutHandleFrame()
  }

  override open func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
    let location = touch.location(in: self)

    if handleView.frame.contains(location) {
      return true
    }
    return false
  }

  override open func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
    let location = touch.location(in: self)
    handleCenterX = location.x
    handleCenterX = fittedValueInBounds(handleCenterX)
    currentValue = ((handleCenterX - handleWidth/2)/trackLayer.bounds.width - 0.5) * 2
    self.changeColorHue(to: currentColor)
    CATransaction.begin()
    CATransaction.setDisableActions(true)
    self.layoutHandleFrame()
    CATransaction.commit()

    self.sendActions(for: .valueChanged)
    return true
  }

  func doubleTapRecognized(_ recognizer: UITapGestureRecognizer){
    let location = recognizer.location(in: self)
    guard handleView.frame.contains(location) else {
      return
    }
    resetHandleToCenter()
  }

  func resetHandleToCenter(){

    handleCenterX = self.bounds.width/2
    self.layoutHandleFrame()
    handleView.color = primaryColor
    currentValue = 0.0

    self.sendActions(for: .valueChanged)
    self.delegate?.shadeSliderChoseColor(self, color: currentColor)
  }
  private func fittedValueInBounds(_ value: CGFloat) -> CGFloat {
    return min(max(value, trackLayer.frame.minX), trackLayer.frame.maxX)
  }

}
