//
//  UDOfflineForm.swift

import Foundation
import MBProgressHUD
import Alamofire

class UDOfflineForm: UIViewController, UITextFieldDelegate {

    @IBOutlet var messageTextField: UITextField!

    var url = ""
    weak var usedesk: UseDeskSDK?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Offline form"

        let singleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.handleSingleTap(_:)))
        singleTapGestureRecognizer.numberOfTapsRequired = 1
        view.addGestureRecognizer(singleTapGestureRecognizer)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    // ********** VIEW TAPPED **********
    @objc func handleSingleTap(_ sender: UITapGestureRecognizer?) {
        view.endEditing(true)
    }

    @IBAction func sendMessage(_ sender: Any) {
        guard let usedesk = usedesk else { return }

        let hud = MBProgressHUD.showAdded(to: view, animated: true)
        hud.mode = MBProgressHUDMode.indeterminate
        hud.label.text = "Отправка сообщения..."

        usedesk.sendOfflineForm(withMessage: messageTextField.text) { [weak self] result, error in
            guard let wSelf = self else { return }

            if result {
                DispatchQueue.main.async(execute: {
                    hud.hide(animated: true)
                    wSelf.dismiss(animated: true)
                })
            } else {
                wSelf.showAlert("Error", text: error)
                hud.hide(animated: true)
            }
        }
    }

    @IBAction func cancelMessage(_ sender: Any) {
        dismiss(animated: true)
    }

    func showAlert(_ title: String?, text: String?) {
        let alert = UIAlertController(title: title, message: text, preferredStyle: .alert)

        let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(ok)
        present(alert, animated: true)
    }
}
