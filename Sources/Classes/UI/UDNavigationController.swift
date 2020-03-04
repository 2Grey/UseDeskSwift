//
//  UDNavigationController.swift

import Foundation

class UDNavigationController: UINavigationController {

    var barTintColor: UIColor?
    var tintColor: UIColor?
    var titleTextAttributes: UIColor?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.navigationBar.isTranslucent = false
        
        self.tintColor = self.tintColor ?? navBarTextColor
        self.barTintColor = barTintColor ?? navBarBackgroundColor
        self.titleTextAttributes = titleTextAttributes ?? navBarTextColor
    }
    
    func setTitleTextAttributes() {
        navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: titleTextAttributes!]
    }
}
