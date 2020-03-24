//
//  UDStartViewController.swift
//  UseDesk_Example

import Foundation
import UIKit
import UseDesk_SDK_Swift

class UDStartViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet var companyIdTextField: UITextField!
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var urlTextField: UITextField!
    @IBOutlet var portTextField: UITextField!
    @IBOutlet weak var accountIdTextField: UITextField!
    @IBOutlet weak var apiTokenTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var nameChatTextField: UITextField!

    var collection: BaseCollection?
    var usedesk = UseDeskSDK()

    override func viewDidLoad() {

        super.viewDidLoad()
        
        navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor(red: 208.0 / 255.0, green: 88.0 / 255.0, blue: 93.0 / 255.0, alpha: 1.0)
        ]

        navigationController?.navigationBar.barStyle = .black

        title = "UseDesk SDK"
        let singleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.handleSingleTap(_:)))

        singleTapGestureRecognizer.numberOfTapsRequired = 1
        view.addGestureRecognizer(singleTapGestureRecognizer)

    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    @objc func handleSingleTap(_ sender: UITapGestureRecognizer?) {
        view.endEditing(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func startChatButton(_ sender: Any) {
        var accountId = ""
        var nameChat = ""
        var isUseBase = false

        if let accountIdTextField = accountIdTextField.text, accountIdTextField.isEmpty == false {
            isUseBase = true
            accountId = accountIdTextField
        }

        if let nameChatTextField = nameChatTextField.text, nameChatTextField.isEmpty == false {
            nameChat = nameChatTextField
        }

        let config = UDSDKConfig(url: urlTextField.text!,
                                 port: portTextField.text!,
                                 apiToken: apiTokenTextField.text!,
                                 companyId: companyIdTextField.text!,
                                 email: emailTextField.text!,
                                 isUseBase: isUseBase)
        config.accountId = accountId
        config.phone = phoneTextField.text
        config.name = nameTextField.text
        config.nameChat = nameChat

        usedesk.start(with: config, on: self) { (_, _) in
            
        }
    }
}
