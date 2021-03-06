//
//  RCPictureMessageCell.swift

import Foundation

class RCPictureMessageCell: RCMessageCell {

    var viewImage: UIImageView?
    var imageManual: UIImageView?
    var spinner: UIActivityIndicatorView?
    var textView: UITextView?

    private var indexPath: IndexPath?
    private weak var messagesView: RCMessagesView?
    // private var viewText: UITextView?

    override func bindData(_ indexPath_: IndexPath?, messagesView messagesView_: RCMessagesView?) {

        self.indexPath = indexPath_
        self.messagesView = messagesView_

        let rcmessage: RCMessage? = messagesView?.rcmessage(indexPath)
        if rcmessage?.status == RCStatus.openimage {
            // viewImage!.image = nil
            spinner?.startAnimating()
            // imageManual!.isHidden = false
        } else {
            super.bindData(indexPath, messagesView: messagesView)

            self.viewBubble.backgroundColor = rcmessage?.incoming != false ? RCMessages.pictureBubbleColorIncoming() : RCMessages.pictureBubbleColorOutgoing()

            if textView == nil {
                let textView = UITextView()
                textView.font = RCMessages.textFont()
                textView.isEditable = false
                textView.isSelectable = false
                textView.isScrollEnabled = false
                textView.isUserInteractionEnabled = false
                textView.backgroundColor = UIColor.clear
                textView.textContainer.lineFragmentPadding = 0
                textView.textContainerInset = RCMessages.textInset()
                viewBubble.addSubview(textView)

                self.textView = textView
            }

            textView?.textColor = rcmessage?.incoming != false ? RCMessages.textTextColorIncoming() : RCMessages.textTextColorOutgoing()
            textView?.text = rcmessage?.text

            if viewImage == nil {
                let viewImage = UIImageView()
                viewImage.layer.masksToBounds = true
                viewImage.layer.cornerRadius = RCMessages.bubbleRadius()
                viewBubble.addSubview(viewImage)

                self.viewImage = viewImage
            }

            if spinner == nil {
                let spinner = UIActivityIndicatorView(style: .white)
                viewBubble.addSubview(spinner)

                self.spinner = spinner
            }

            if imageManual == nil {
                let imageManual = UIImageView(image: RCMessages.pictureImageManual())
                viewBubble.addSubview(imageManual)

                self.imageManual = imageManual
            }

            weak var weakSelf: RCPictureMessageCell? = self

            if rcmessage?.status == RCStatus.loading {
                self.viewImage?.image = nil
                self.spinner?.startAnimating()
                self.imageManual?.isHidden = true

                let session = URLSession.shared
                if let url = URL(string: rcmessage?.file?.content ?? "") {
                    session.dataTask(with: url, completionHandler: { [weak self] data, response, error in
                        guard let wSelf = self else { return }

                        if error == nil {
                            let udMineType = UDMimeType()
                            let mimeType = udMineType.typeString(for: data)
                            if mimeType == "image" {
                                DispatchQueue.main.async(execute: {
                                    if let data = data {
                                        rcmessage?.picture_image = UIImage(data: data)
                                    }
                                    weakSelf?.viewImage?.image = rcmessage?.picture_image
                                    wSelf.spinner?.stopAnimating()
                                    rcmessage?.status = RCStatus.succeed
                                    rcmessage?.file?.type = mimeType
                                })
                            } else {
                                DispatchQueue.main.async(execute: {
                                    rcmessage?.picture_image = UIImage.named("icon_file.png")
                                    weakSelf?.imageView?.image = rcmessage?.picture_image
                                    wSelf.spinner?.stopAnimating()
                                    rcmessage?.status = RCStatus.succeed
                                    rcmessage?.file?.type = mimeType
                                })
                            }
                        }
                    }).resume()
                }
                self.spinner?.startAnimating()
            }

            if rcmessage?.status == RCStatus.succeed {
                viewImage?.image = rcmessage?.picture_image
                spinner?.stopAnimating()
                imageManual?.isHidden = true
            }

            if rcmessage?.status == RCStatus.manual {
                viewImage?.image = nil
                spinner?.stopAnimating()
                imageManual?.isHidden = false
            }
        }
    }

    override func layoutSubviews() {

        let sizeText: CGSize = RCPictureMessageCell.textSize(indexPath, messagesView: messagesView)

        textView?.frame = CGRect(x: 0, y: 0, width: sizeText.width, height: sizeText.height)

        let sizePicture: CGSize = RCPictureMessageCell.size(indexPath, messagesView: messagesView)
        let size = CGSize(width: sizePicture.width, height: sizeText.height + sizePicture.height)

        super.layoutSubviews(size)

        viewImage?.frame = CGRect(x: 0, y: sizeText.height, width: sizePicture.width, height: sizePicture.height)

        if let spinner = self.spinner {
            let widthSpinner = spinner.frame.size.width
            let heightSpinner = spinner.frame.size.height
            let xSpinner: CGFloat = (size.width - widthSpinner) / 2
            let ySpinner: CGFloat = sizeText.height + (sizePicture.height - heightSpinner) / 2

            self.spinner?.frame = CGRect(x: xSpinner, y: ySpinner, width: widthSpinner, height: heightSpinner)
        }

        if let image = self.imageManual?.image {
            let widthManual = image.size.width
            let heightManual = image.size.height
            let xManual: CGFloat = (size.width - widthManual) / 2
            let yManual: CGFloat = (size.height - heightManual) / 2

            self.imageManual?.frame = CGRect(x: xManual, y: yManual, width: widthManual, height: heightManual)
        }
    }

    // MARK: - Size methods

    class func height(_ indexPath: IndexPath?, messagesView: RCMessagesView?) -> CGFloat {
        let size: CGSize = self.size(indexPath, messagesView: messagesView)
        let sizeText: CGSize = RCPictureMessageCell.textSize(indexPath, messagesView: messagesView)

        return size.height + sizeText.height + 20
    }

    class func size(_ indexPath: IndexPath?, messagesView: RCMessagesView?) -> CGSize {
        guard let rcmessage = messagesView?.rcmessage(indexPath) else {
            return CGSize(width: 0, height: 0)
        }

        let width = fminf(Float(RCMessages.pictureBubbleWidth()), Float(rcmessage.picture_width))
        return CGSize(width: CGFloat(width), height: CGFloat(Float(rcmessage.picture_height) * width / Float(rcmessage.picture_width)))
    }

    class func textHeight(_ indexPath: IndexPath?, messagesView: RCMessagesView?) -> CGFloat {
        let size: CGSize = self.textSize(indexPath, messagesView: messagesView)
        return size.height
    }

    class func textSize(_ indexPath: IndexPath?, messagesView: RCMessagesView?) -> CGSize {
        let size: CGSize = self.size(indexPath, messagesView: messagesView)

        let rcmessage: RCMessage? = messagesView?.rcmessage(indexPath)
        if rcmessage?.text.count == 0 || rcmessage?.text == nil {
            return CGSize(width: 0, height: 0)
        }
        //// (0.6 * SCREEN_WIDTH)
        let maxwidth: CGFloat = size.width - RCMessages.textInsetLeft() - RCMessages.textInsetRight()
        let rect: CGRect? = rcmessage?.text.boundingRect(with: CGSize(width: maxwidth, height: CGFloat(MAXFLOAT)), options: .usesLineFragmentOrigin, attributes: [
            NSAttributedString.Key.font: RCMessages.textFont() as Any
        ], context: nil)

        let width = Float((rect?.size.width ?? 0.0) + RCMessages.textInsetLeft() + RCMessages.textInsetRight())
        let height = Float((rect?.size.height ?? 0.0) + RCMessages.textInsetTop() + RCMessages.textInsetBottom())
        return CGSize(width: CGFloat(fmaxf(width, Float(RCMessages.pictureBubbleWidth()))), height: CGFloat(fmaxf(height, Float(RCMessages.textBubbleHeightMin()))))
    }
}
