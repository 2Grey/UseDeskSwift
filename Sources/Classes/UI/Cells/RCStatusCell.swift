//
//  RCStatusCell.swift

import Foundation

class RCStatusCell: UITableViewCell {

    var viewBubble: UIView?
    var textView: UITextView?

    private var indexPath: IndexPath?
    private weak var messagesView: RCMessagesView?

    func bindData(_ indexPath_: IndexPath?, messagesView messagesView_: RCMessagesView?) {
        self.indexPath = indexPath_
        self.messagesView = messagesView_

        self.backgroundColor = UIColor.clear
        let rcmessage: RCMessage? = self.messagesView?.rcmessage(indexPath)

        if self.viewBubble == nil {
            let viewBubble = UIView()
            viewBubble.backgroundColor = RCMessages.statusBubbleColor()
            viewBubble.layer.cornerRadius = RCMessages.statusBubbleRadius()
            self.contentView.addSubview(viewBubble)

            self.viewBubble = viewBubble
            self.bubbleGestureRecognizer()
        }

        if self.textView == nil {
            let textView = UITextView()
            textView.font = RCMessages.statusFont()
            textView.textColor = RCMessages.statusTextColor()
            textView.isEditable = false
            textView.isSelectable = false
            textView.isScrollEnabled = false
            textView.isUserInteractionEnabled = false
            textView.backgroundColor = UIColor.clear
            textView.textContainer.lineFragmentPadding = 0
            textView.textContainerInset = RCMessages.statusInset()

            self.viewBubble?.addSubview(textView)
            self.textView = textView
        }

        textView?.text = rcmessage?.text
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let size: CGSize = RCStatusCell.size(self.indexPath, messagesView: self.messagesView)

        let yBubble = RCMessages.sectionHeaderMargin()
        let xBubble: CGFloat = (SCREEN_WIDTH - size.width) / 2
        self.viewBubble?.frame = CGRect(x: xBubble, y: yBubble, width: size.width, height: size.height)

        self.textView?.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
    }

    // MARK: - Size methods

    class func height(_ indexPath: IndexPath?, messagesView: RCMessagesView?) -> CGFloat {
        let size: CGSize = self.size(indexPath, messagesView: messagesView)
        return size.height
    }

    class func size(_ indexPath: IndexPath?, messagesView: RCMessagesView?) -> CGSize {
        guard let rcmessage = messagesView?.rcmessage(indexPath) else {
            return CGSize.zero
        }

        let maxwidth: CGFloat = (0.95 * SCREEN_WIDTH) - RCMessages.statusInsetLeft() - RCMessages.statusInsetRight()
        let rect: CGRect = rcmessage.text.boundingRect(with: CGSize(width: maxwidth, height: CGFloat.greatestFiniteMagnitude),
                                                        options: .usesLineFragmentOrigin,
                                                        attributes: [ NSAttributedString.Key.font: RCMessages.statusFont() as Any ],
                                                        context: nil)

        let width: CGFloat = rect.size.width + RCMessages.statusInsetLeft() + RCMessages.statusInsetRight()
        var height: CGFloat = rect.size.height + RCMessages.statusInsetTop() + RCMessages.statusInsetBottom()
        if rcmessage.incoming {
            height += 18
        }
        return CGSize(width: width, height: height)
    }

    // MARK: - Gesture recognizer methods

    func bubbleGestureRecognizer() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.actionTapBubble))
        viewBubble?.addGestureRecognizer(tapGesture)
        tapGesture.cancelsTouchesInView = false
    }

    // MARK: - User actions

    @objc func actionTapBubble() {
        messagesView?.view.endEditing(true)
        messagesView?.actionTapBubble(indexPath)
    }
}
