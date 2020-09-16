//
//  RCSectionHeaderCell.swift

import Foundation

class RCSectionHeaderCell: UITableViewCell {
    var labelSectionHeader: UILabel?

    private var indexPath: IndexPath?
    private weak var messagesView: RCMessagesView?

    func bindData(_ indexPath: IndexPath?, messagesView: RCMessagesView?) {
        self.indexPath = indexPath
        self.messagesView = messagesView

        self.backgroundColor = UIColor.clear

        let rcmessage: RCMessage? = messagesView?.rcmessage(indexPath)
        if rcmessage != nil {
            if self.labelSectionHeader == nil {
                let labelSectionHeader = UILabel()
                labelSectionHeader.font = RCMessages.sectionHeaderFont()
                labelSectionHeader.textColor = RCMessages.sectionHeaderColor()
                contentView.addSubview(labelSectionHeader)
                labelSectionHeader.textAlignment = .center

                self.labelSectionHeader = labelSectionHeader
            }
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        if let rcmessage = messagesView?.rcmessage(indexPath) {
            labelSectionHeader?.text = rcmessage.date?.dateFromHeaderComments
        }

        let width: CGFloat = SCREEN_WIDTH - RCMessages.sectionHeaderLeft() - RCMessages.sectionHeaderRight()
        let height: CGFloat = (labelSectionHeader?.text != nil) ? RCMessages.sectionHeaderHeight : 0
        labelSectionHeader?.frame = CGRect(x: RCMessages.sectionHeaderLeft(), y: 0, width: width, height: height)
    }

    // MARK: - Size methods

    class func height(_ indexPath: IndexPath?, messagesView: RCMessagesView?) -> CGFloat {
        if messagesView?.rcmessage(indexPath) != nil {
            return RCMessages.sectionHeaderHeight
        } else {
            return 0.0
        }
    }
}
