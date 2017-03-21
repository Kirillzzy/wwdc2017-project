import UIKit

extension UIImage {

  func cropToBounds(posX: CGFloat, posY: CGFloat, width: CGFloat, height: CGFloat) -> UIImage {
    let contextImage: UIImage = UIImage(cgImage: self.cgImage!)
    let rect = CGRect(x: posX, y: posY, width: width, height: height)
    // Create bitmap image from context using the rect
    let imageRef: CGImage = contextImage.cgImage!.cropping(to: rect)!
    // Create a new image based on the imageRef and rotate back to the original orientation
    let image: UIImage = UIImage(cgImage: imageRef, scale: self.scale, orientation: self.imageOrientation)

    return image
  }
}
