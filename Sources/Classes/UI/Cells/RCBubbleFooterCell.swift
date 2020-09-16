//
//  RCBubbleFooterCell.swift

import Foundation

class RCBubbleFooterCell: UITableViewCell {

    var labelBubbleFooter: UILabel?

    // MARK: - Size methods

    class func height(_ indexPath: IndexPath?, messagesView: RCMessagesView?) -> CGFloat {
        return (messagesView?.textBubbleFooter(indexPath) != nil) ? RCMessages.bubbleFooterHeight() : 0
    }

    func bindData(_ indexPath: IndexPath?, messagesView: RCMessagesView?) {
        self.backgroundColor = UIColor.clear

        let rcmessage: RCMessage? = messagesView?.rcmessage(indexPath)
        if labelBubbleFooter == nil {
            let labelBubbleFooter = UILabel()
            labelBubbleFooter.font = RCMessages.bubbleFooterFont()
            labelBubbleFooter.textColor = RCMessages.bubbleFooterColor()
            self.contentView.addSubview(labelBubbleFooter)

            self.labelBubbleFooter = labelBubbleFooter
        }

        self.labelBubbleFooter?.textAlignment = rcmessage?.incoming != false ? .left : .right
        self.labelBubbleFooter?.text = messagesView?.textBubbleFooter(indexPath)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let width: CGFloat = SCREEN_WIDTH - RCMessages.bubbleFooterLeft() - RCMessages.bubbleFooterRight()
        let height: CGFloat = (labelBubbleFooter?.text != nil) ? RCMessages.bubbleFooterHeight() : 0

        self.labelBubbleFooter?.frame = CGRect(x: RCMessages.bubbleFooterLeft(), y: 0, width: width, height: height)
    }
}
