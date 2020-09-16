//
//  RCMessageCell.swift

import Foundation

class RCMessageCell: UITableViewCell {

    var viewBubble: UIView!
    var imageAvatar: UIImageView!
    var labelAvatar: UILabel!
    var label: UILabel!
    
    private var indexPath: IndexPath?
    private weak var messagesView: RCMessagesView?
    
    let kHeightName: CGFloat = 15
    
    func bindData(_ indexPath_: IndexPath?, messagesView messagesView_: RCMessagesView?) {
        self.indexPath = indexPath_
        self.messagesView = messagesView_

        self.backgroundColor = UIColor.clear

        let rcmessage: RCMessage? = messagesView?.rcmessage(indexPath)
        if rcmessage != nil {
            if rcmessage!.incoming {
                if label == nil {
                    label = UILabel()
                    contentView.addSubview(label)
                }
            } else {
                if label != nil {
                    label.removeFromSuperview()
                    label = nil
                }
            }
        }

        if self.viewBubble == nil {
            self.viewBubble = UIView()
            self.viewBubble.layer.cornerRadius = RCMessages.bubbleRadius()
            self.contentView.addSubview(self.viewBubble)

            self.bubbleGestureRecognizer()
        }
        
        if self.imageAvatar == nil {
            self.imageAvatar = UIImageView()
            self.imageAvatar.layer.masksToBounds = true
            self.imageAvatar.layer.cornerRadius = RCMessages.avatarDiameter() / 2
            self.imageAvatar.backgroundColor = RCMessages.avatarBackColor()
            self.imageAvatar.isUserInteractionEnabled = true
            self.contentView.addSubview(self.imageAvatar)

            self.avatarGestureRecognizer()
        }
        
        self.imageAvatar.image = messagesView?.avatarImage(indexPath)
        
        if self.labelAvatar == nil {
            self.labelAvatar = UILabel()
            self.labelAvatar.font = RCMessages.avatarFont()
            self.labelAvatar.textColor = RCMessages.avatarTextColor()
            self.labelAvatar.textAlignment = .center
            self.contentView.addSubview(self.labelAvatar)
        }
        
        self.labelAvatar.text = (self.imageAvatar.image == nil) ? self.messagesView?.avatarInitials(self.indexPath) : nil
    }

    func layoutSubviews(_ size: CGSize) {
        super.layoutSubviews()
        
        if let rcmessage = messagesView?.rcmessage(indexPath) {
            let xBubble: CGFloat = rcmessage.incoming != false ? RCMessages.bubbleMarginLeft() : (SCREEN_WIDTH - RCMessages.bubbleMarginRight() - size.width)
            if rcmessage.incoming {
                let widthLabel: CGFloat = size.width < 200 ? 200 : size.width
                self.label.frame = CGRect(x: xBubble, y: 0, width: widthLabel, height: kHeightName)
                self.label.text = rcmessage.name
                self.label.textColor = UIColor(hexString: "828282")
                self.label.font = UIFont.systemFont(ofSize: 11, weight: .regular)
            }
            self.viewBubble.frame = CGRect(x: xBubble, y: rcmessage.incoming ? 18 : 0, width: size.width, height: size.height)
            
            let diameter = RCMessages.avatarDiameter()
            let xAvatar: CGFloat = rcmessage.incoming ? RCMessages.avatarMarginLeft() : (SCREEN_WIDTH - RCMessages.avatarMarginRight() - diameter)
            let yAvatar: CGFloat = rcmessage.incoming ? size.height - diameter + 18 : size.height - diameter

            self.imageAvatar.frame = CGRect(x: xAvatar, y: yAvatar, width: diameter, height: diameter)
            self.labelAvatar.frame = CGRect(x: xAvatar, y: yAvatar, width: diameter, height: diameter)
        }
    }
    
    // MARK: - Gesture recognizer methods

    func bubbleGestureRecognizer() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.actionTapBubble))
        viewBubble.addGestureRecognizer(tapGesture)
        tapGesture.cancelsTouchesInView = false
        
        let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.actionLongBubble(_:)))
        viewBubble.addGestureRecognizer(longGesture)
    }
    
    func avatarGestureRecognizer() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.actionTapAvatar))
        imageAvatar.addGestureRecognizer(tapGesture)
        tapGesture.cancelsTouchesInView = false
    }
    
    // MARK: - User actions

    @objc func actionTapBubble() {
        messagesView?.view.endEditing(true)
        messagesView?.actionTapBubble(indexPath)
    }
    
    @objc func actionTapAvatar() {
        messagesView?.view.endEditing(true)
        messagesView?.actionTapAvatar(indexPath)
    }
    
    @objc func actionLongBubble(_ gestureRecognizer: UILongPressGestureRecognizer?) {
        switch gestureRecognizer?.state {
        case .began?:
            actionMenu()
        case .changed?:
            break
        case .ended?:
            break
        case .possible?:
            break
        case .cancelled?:
            break
        case .failed?:
            break
        default:
            break
        }
    }
    
    func actionMenu() {
        if messagesView?.textInput.isFirstResponder == false {
            let menuController = UIMenuController.shared
            menuController.menuItems = messagesView?.menuItems(indexPath) as? [UIMenuItem]
            menuController.setTargetRect(viewBubble.frame, in: contentView)
            menuController.setMenuVisible(true, animated: true)
        } else {
            messagesView?.textInput.resignFirstResponder()
        }
    }
}
