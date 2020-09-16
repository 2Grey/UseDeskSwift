//
//  UDArticleView.swift

import Foundation
import UIKit
import WebKit

class UDArticleView: UIViewController, UIWebViewDelegate, UISearchBarDelegate {

    @IBOutlet var webView: WKWebView!
    @IBOutlet var loadingView: UIView!

    var article: Article?
    weak var usedesk: UseDeskSDK?
    var url: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: chatButtonText, style: .done, target: self, action: #selector(self.actionChat))

        self.webView.navigationDelegate = self
        self.webView.loadHTMLString(article?.text ?? "", baseURL: nil)
    }

    // MARK: - User actions

    @objc func actionChat() {
        guard let usedesk = usedesk, let config = usedesk.config else { return }

        UIView.animate(withDuration: 0.3) {
            self.loadingView.alpha = 1
        }

        usedesk.startWithoutGUICompanyID(with: config) { [weak self] success, error in
            guard let wSelf = self else { return }
            guard wSelf.usedesk != nil else { return }

            if success {
                DispatchQueue.main.async(execute: {
                    let dialogflowVC = DialogflowView()
                    dialogflowVC.usedesk = wSelf.usedesk
                    dialogflowVC.isFromBase = true
                    wSelf.navigationController?.pushViewController(dialogflowVC, animated: true)
                    UIView.animate(withDuration: 0.3) {
                        wSelf.loadingView.alpha = 0
                    }
                })
            } else {
                if error == "noOperators" {
                    let offlineVC = UDOfflineForm(nibName: "UDOfflineForm", bundle: nil)
                    if let url = wSelf.url {
                        offlineVC.url = url
                    }
                    offlineVC.usedesk = wSelf.usedesk
                    wSelf.navigationController?.pushViewController(offlineVC, animated: true)
                    UIView.animate(withDuration: 0.3) {
                        wSelf.loadingView.alpha = 0
                    }
                }
            }
        }
    }
}

// MARK: - WKNavigationDelegate

extension UDArticleView: WKNavigationDelegate {

    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation) {
        UIView.animate(withDuration: 0.3) {
            self.loadingView.alpha = 0
        }
    }
}
