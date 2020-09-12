//
//  UDNavigationController.swift

import Foundation

class UDNavigationController: UINavigationController {

    public var onDissmis: (() -> Void)?

    var barTintColor: UIColor?
    var tintColor: UIColor?
    var titleTextAttributes: UIColor?

    override func viewDidLoad() {

        super.viewDidLoad()

        self.navigationBar.isTranslucent = false

        self.tintColor = self.tintColor ?? RCMessages.shared.navBarTextColor
        self.barTintColor = self.barTintColor ?? RCMessages.shared.navBarBackgroundColor
        self.titleTextAttributes = self.titleTextAttributes ?? RCMessages.shared.navBarTextColor
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.onDissmis?()
    }

    func setTitleTextAttributes() {
        navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: titleTextAttributes!]
    }
}
