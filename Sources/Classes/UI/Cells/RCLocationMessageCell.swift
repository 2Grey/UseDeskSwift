//
//  RCLocationMessageCell.swift

import Foundation

class RCLocationMessageCell: RCMessageCell {

    var viewImage: UIImageView?
    var spinner: UIActivityIndicatorView?
    
    private var indexPath: IndexPath?
    private weak var messagesView: RCMessagesView?
    
    override func bindData(_ indexPath_: IndexPath?, messagesView messagesView_: RCMessagesView?) {
        indexPath = indexPath_
        messagesView = messagesView_
        
        let rcmessage: RCMessage? = messagesView?.rcmessage(indexPath)
        
        super.bindData(indexPath, messagesView: messagesView)
        
        viewBubble.backgroundColor = rcmessage?.incoming != false ? RCMessages.locationBubbleColorIncoming() : RCMessages.locationBubbleColorOutgoing()
        
        if viewImage == nil {
            let viewImage = UIImageView()
            viewImage.layer.masksToBounds = true
            viewImage.layer.cornerRadius = RCMessages.bubbleRadius()
            self.viewBubble.addSubview(viewImage)

            self.viewImage = viewImage
        }

        if spinner == nil {
            let spinner = UIActivityIndicatorView(style: .white)
            self.viewBubble.addSubview(spinner)

            self.spinner = spinner
        }
        
        if rcmessage?.status == RCStatus.loading {
            viewImage?.image = nil
            spinner?.startAnimating()
        }
        
        if rcmessage?.status == RCStatus.succeed {
            viewImage?.image = rcmessage?.location_thumbnail
            spinner?.stopAnimating()
        }
    }
    
    override func layoutSubviews() {
        let size: CGSize = RCLocationMessageCell.size(indexPath, messagesView: messagesView)
        
        super.layoutSubviews(size)
        
        self.viewImage?.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        
        let widthSpinner = spinner?.frame.size.width ?? 0
        let heightSpinner = spinner?.frame.size.height ?? 0
        let xSpinner: CGFloat = (size.width - widthSpinner) / 2
        let ySpinner: CGFloat = (size.height - heightSpinner) / 2

        self.spinner?.frame = CGRect(x: xSpinner, y: ySpinner, width: widthSpinner, height: heightSpinner)
    }
    
    // MARK: - Size methods

    class func height(_ indexPath: IndexPath?, messagesView: RCMessagesView?) -> CGFloat {
        let size: CGSize = self.size(indexPath, messagesView: messagesView)
        return size.height
    }
    
    class func size(_ indexPath: IndexPath?, messagesView: RCMessagesView?) -> CGSize {
        if messagesView?.rcmessage(indexPath) != nil {
            return CGSize(width: RCMessages.locationBubbleWidth(), height: RCMessages.locationBubbleHeight())
        } else {
            return CGSize(width: 0, height: 0)
        }
    }
}
