// Created by Kirill Averyanov

import UIKit

open class ActionButton: UIButton {

  private var nessesaryBackgroundColor: UIColor?
  private var isSetup = false
  private var notChange = false

  override open var backgroundColor: UIColor? {
    didSet {
      if oldValue == backgroundColor || notChange {
        notChange = false
        return
      }

      if !isSetup {
        nessesaryBackgroundColor = backgroundColor
        notChange = true
        backgroundColor = oldValue
      }

      updateAppearance()
    }
  }

  private func updateAppearance() {
    isSetup = true
    if (isSelected || isHighlighted) && isEnabled {
      backgroundColor = nessesaryBackgroundColor?.tapButtonChangeColor
    } else {
      backgroundColor = nessesaryBackgroundColor
    }
    self.alpha = isEnabled ? 1 : 0.8

    isSetup = false
  }

  override open var isHighlighted: Bool {
    didSet {
      if oldValue != isHighlighted {
        updateAppearance()
      }
    }
  }

  override open var isEnabled: Bool {
    didSet {
      if oldValue != isEnabled {
        updateAppearance()
      }
    }
  }

  override open var isSelected: Bool {
    didSet {
      if oldValue != isSelected {
        updateAppearance()
      }
    }
  }
  
}
