// Created by Kirill Averyanov


import UIKit


open class StarterViewController: UIViewController {

  var beginButton: ActionButton! {
    didSet {
      beginButton.setTitle("Begin Draw", for: .normal)
      beginButton.backgroundColor = .blue
      beginButton.addTarget(self, action: #selector(beginButtonPressed(_:)), for: .touchUpInside)
      beginButton.layer.masksToBounds = true
      beginButton.layer.cornerRadius = 5.0
    }
  }

  override open func viewDidLoad() {
    super.viewDidLoad()
    self.view.backgroundColor = .white
    beginButton = ActionButton(frame: CGRect(origin: view.center, size: CGSize(width: 200, height: 100)))
    self.view.addSubview(beginButton)
  }

  func beginButtonPressed(_ sender: ActionButton!) {
    let viewController = MainViewController()
    self.present(viewController, animated: true, completion: nil)
  }

}
