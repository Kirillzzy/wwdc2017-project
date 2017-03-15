// Created by Kirill Averyanov


import UIKit


public extension UIColor{
  public var hexCode: String {
    get{
      let colorComponents = self.cgColor.components
      return String(format: "%02x%02x%02x", Int(colorComponents![0]*255.0), Int(colorComponents![1]*255.0),Int(colorComponents![2]*255.0)).uppercased()
    }
  }

  public func lighterColor(_ amount: CGFloat) -> UIColor{
    return UIColor.blendColors(color: self, destinationColor: UIColor.white, amount: amount)
  }

  public func darkerColor(_ amount: CGFloat) -> UIColor{
    return UIColor.blendColors(color: self, destinationColor: UIColor.black, amount: amount)
  }

  public static func blendColors(color: UIColor, destinationColor: UIColor, amount : CGFloat) -> UIColor{
    var amountToBlend = amount;
    if amountToBlend > 1{
      amountToBlend = 1.0
    }
    else if amountToBlend < 0{
      amountToBlend = 0
    }
    var r,g,b, alpha : CGFloat
    r = 0
    g = 0
    b = 0
    alpha = 0
    color.getRed(&r, green: &g, blue: &b, alpha: &alpha)
    var dest_r, dest_g, dest_b, dest_alpha : CGFloat
    dest_r = 0
    dest_g = 0
    dest_b = 0
    dest_alpha = 0
    destinationColor.getRed(&dest_r, green: &dest_g, blue: &dest_b, alpha: &dest_alpha)

    r = amountToBlend * (dest_r * 255) + (1 - amountToBlend) * (r * 255)
    g = amountToBlend * (dest_g * 255) + (1 - amountToBlend) * (g * 255)
    b = amountToBlend * (dest_b * 255) + (1 - amountToBlend) * (b * 255)
    alpha = fabs(alpha / dest_alpha)

    return UIColor(red: r/255.0, green: g/255.0, blue: b/255.0, alpha: alpha)
  }

  var tapButtonChangeColor: UIColor {
    var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
    if self.getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
      if red < 0.16 && green < 0.16 && blue < 0.16 {
        return lighterColorForColor()
      }
    }
    return darkerColorForColor()
  }

  private func darkerColorForColor() -> UIColor {
    return changeColor(value: -0.2)
  }

  private func lighterColorForColor() -> UIColor {
    return changeColor(value: 0.2)
  }

  private func changeColor(value: CGFloat) -> UIColor {
    var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
    if self.getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
      return UIColor(red: min(red + value, 1.0),
                     green: min(green + value, 1.0),
                     blue: min(blue + value, 1.0),
                     alpha: alpha)
    }
    return self
  }
  
}
