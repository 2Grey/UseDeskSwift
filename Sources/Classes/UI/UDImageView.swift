//
//  UDImageView.swift

import Foundation
import UIKit
import AVKit

protocol UDImageViewDelegate: class {
    func close()
}

class UDImageView: UIViewController, UIScrollViewDelegate {

    @IBOutlet var backView: UIView!
    @IBOutlet var viewimage: UIImageView!
    @IBOutlet var scrollView: UIScrollView!

    weak var delegate: UDImageViewDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 6.0
        scrollView.delegate = self

        scrollView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleSingleTap(_:))))
    }

    func showImage(image: UIImage) {
        scrollView.alpha = 1
        viewimage.image = image
    }

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.viewimage
    }

    @objc func handleSingleTap(_ sender: UITapGestureRecognizer?) {
        delegate?.close()
    }
}
