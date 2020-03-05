//
//  RCMessages.swift

import Foundation
import AVFoundation
import CoreLocation
import MapKit
import UIKit

let SCREEN_WIDTH = UIScreen.main.bounds.size.width
let SCREEN_HEIGHT = UIScreen.main.bounds.size.height


@objc public enum RCType: Int {
    case unknown = 0
    case status = 1
    case text
    case emoji
    case picture
    case video
    case audio
    case location
    case file
    case feedback
}

@objc public enum RCStatus: Int {
    case unknown = 0
    case loading = 1
    case succeed
    case manual
    case openimage
}

@objc public enum RCAudioStatus: Int {
    case stopped = 1
    case playing
}

public class RCMessages: NSObject {

    public var navBarBackgroundColor: UIColor? = UIColor(red: 208.0 / 255.0, green: 88.0 / 255.0, blue: 93.0 / 255.0, alpha: 1.0)
    public var navBarTextColor: UIColor? = UIColor.white

    // MARK: * Section
    public var sectionHeaderMargin: CGFloat = 8.0
    public var sectionHeaderHeight: CGFloat = 20.0
    public var sectionHeaderLeft: CGFloat = 10.0
    public var sectionHeaderRight: CGFloat = 10.0
    public var sectionHeaderColor: UIColor? = UIColor.lightGray
    public var sectionHeaderFont: UIFont? = UIFont.systemFont(ofSize: 12)

    public var sectionFooterHeight: CGFloat = 15.0
    public var sectionFooterLeft: CGFloat = 10.0
    public var sectionFooterRight: CGFloat = 10.0
    public var sectionFooterColor: UIColor? = UIColor.lightGray
    public var sectionFooterFont: UIFont? = UIFont.systemFont(ofSize: 12)
    public var sectionFooterMargin: CGFloat = 8.0

    // MARK: * Bubble
    public var bubbleHeaderHeight: CGFloat = 15.0
    public var bubbleHeaderLeft: CGFloat = 50.0
    public var bubbleHeaderRight: CGFloat = 50.0
    public var bubbleHeaderColor: UIColor? = UIColor.lightGray
    public var bubbleHeaderFont: UIFont? = UIFont.systemFont(ofSize: 12)

    public var bubbleMarginLeft: CGFloat = 40.0
    public var bubbleMarginRight: CGFloat = 40.0
    public var bubbleRadius: CGFloat = 15.0

    public var bubbleFooterHeight: CGFloat = 15.0
    public var bubbleFooterLeft: CGFloat = 50.0
    public var bubbleFooterRight: CGFloat = 50.0
    public var bubbleFooterColor: UIColor? = UIColor.lightGray
    public var bubbleFooterFont: UIFont? = UIFont.systemFont(ofSize: 12)

    // MARK: * Avatar
    public var avatarDiameter: CGFloat = 30.0
    public var avatarMarginLeft: CGFloat = 4.0
    public var avatarMarginRight: CGFloat = 4.0

    public var avatarBackColor: UIColor? = UIColor(hexString: "d6d6d6ff")
    public var avatarTextColor: UIColor? = UIColor.white
    public var avatarFont: UIFont? = UIFont.systemFont(ofSize: 12)

    // MARK: * Status cell
    public var statusBubbleRadius: CGFloat = 10.0
    public var statusBubbleColor: UIColor? = UIColor(hexString: "00000030")
    public var statusTextColor: UIColor? = UIColor.white
    public var statusFont: UIFont? = UIFont.systemFont(ofSize: 12)

    public var statusInsetLeft: CGFloat = 1.0
    public var statusInsetRight: CGFloat = 10.0
    public var statusInsetTop: CGFloat = 5.0
    public var statusInsetBottom: CGFloat = 5.0

    public var statusInset: UIEdgeInsets {
        UIEdgeInsets(top: statusInsetTop, left: statusInsetLeft, bottom: statusInsetBottom, right: statusInsetRight)
    }

    // MARK: * Text cell
    public var textBubbleWidthMin: CGFloat = 45.0
    public var textBubbleHeightMin: CGFloat = 35.0

    public var textBubbleColorOutgoing: UIColor? = UIColor(hexString: "9999ff")
    public var textBubbleColorIncoming: UIColor? = UIColor(hexString: "e6e5eaff")
    public var textTextColorOutgoing: UIColor? = UIColor.white
    public var textTextColorIncoming: UIColor? = UIColor.black
    public var textFont: UIFont? = UIFont.systemFont(ofSize: 16)

    public var textInsetLeft: CGFloat = 10.0
    public var textInsetRight: CGFloat = 10.0
    public var textInsetTop: CGFloat = 10.0
    public var textInsetBottom: CGFloat = 10.0
    public var textInset: UIEdgeInsets {
        UIEdgeInsets(top: textInsetTop, left: textInsetLeft, bottom: textInsetBottom, right: textInsetRight)
    }

    // MARK: * Emoji cell
    public var emojiBubbleWidthMin: CGFloat = 45.0
    public var emojiBubbleHeightMin: CGFloat = 35.0
    public var emojiBubbleColorOutgoing: UIColor? = UIColor(hexString: "007affff")
    public var emojiBubbleColorIncoming: UIColor? = UIColor(hexString: "e6e5eaff")
    public var emojiFont: UIFont? = UIFont.systemFont(ofSize: 46)

    public var emojiInsetLeft: CGFloat = 30.0
    public var emojiInsetRight: CGFloat = 30.0
    public var emojiInsetTop: CGFloat = 5.0
    public var emojiInsetBottom: CGFloat = 5.0
    public var emojiInset: UIEdgeInsets {
        UIEdgeInsets(top: emojiInsetTop, left: emojiInsetLeft, bottom: emojiInsetBottom, right: emojiInsetRight)
    }

    // MARK: * Picture cell
    public var pictureBubbleWidth: CGFloat = 200.0

    public var pictureBubbleColorOutgoing: UIColor? = UIColor.lightGray
    public var pictureBubbleColorIncoming: UIColor? = UIColor.lightGray
    public var pictureImageManual: UIImage? = UIImage.named("rcmessages_manual")

    // MARK: * Video cell
    public var videoBubbleWidth: CGFloat = 200.0
    public var videoBubbleHeight: CGFloat = 145.0

    public var videoBubbleColorOutgoing: UIColor? = UIColor.lightGray
    public var videoBubbleColorIncoming: UIColor? = UIColor.lightGray
    public var videoImagePlay: UIImage? = UIImage.named("rcmessages_videoplay")
    public var videoImageManual: UIImage? = UIImage.named("rcmessages_videoplay")

    // Audio cell
    public var audioBubbleWidht: CGFloat = 145.0
    public var audioBubbleHeight: CGFloat = 40.0

    public var audioBubbleColorOutgoing: UIColor? = UIColor(hexString: "007affff")
    public var audioBubbleColorIncoming: UIColor? = UIColor(hexString: "e6e5eaff")
    public var audioTextColorOutgoing: UIColor? = UIColor.white
    public var audioTextColorIncoming: UIColor? = UIColor.black

    public var audioImagePlay: UIImage? = UIImage.named("rcmessages_audioplay")
    public var audioImagePause: UIImage? = UIImage.named("rcmessages_audiopause")
    public var audioImageManual: UIImage? = UIImage.named("rcmessages_manual")
    public var audioFont: UIFont? = UIFont.systemFont(ofSize: 16)

    // MARK: * Location cell
    public var locationBubbleWidth: CGFloat = 200.0
    public var locationBubbleHeight: CGFloat = 145.0

    public var locationBubbleColorOutgoing: UIColor? = UIColor.lightGray
    public var locationBubbleColorIncoming: UIColor? = UIColor.lightGray

    // MARK: * Input view

    public var inputViewBackColor: UIColor? = UIColor.groupTableViewBackground
    public var inputTextBackColor: UIColor? = UIColor.white
    public var inputTextTextColor: UIColor? = UIColor.black

    public var inputFont: UIFont? = UIFont.systemFont(ofSize: 17)

    public var inputViewHeightMin: CGFloat = 44.0
    public var inputTextHeightMin: CGFloat = 30.0
    public var inputTextHeightMax: CGFloat = 110.0
    public var inputBorderWidth: CGFloat = 1.0
    public var inputBorderColor: CGColor? = UIColor.lightGray.cgColor

    public var inputRadius: CGFloat = 5.0

    public var inputInsetLeft: CGFloat = 7.0
    public var inputInsetRight: CGFloat = 7.0
    public var inputInsetTop: CGFloat = 5.0
    public var inputInsetBottom: CGFloat = 5.0
    public var inputInset: UIEdgeInsets {
        UIEdgeInsets(top: inputInsetTop, left: inputInsetLeft, bottom: inputInsetBottom, right: inputInsetRight)
    }

    // MARK: - Chat send area
    public var attachButtonImage: UIImage? = UIImage.named("rcmessage_attach")
    public var attachButtonTitle: String?
    public var attachButtonTextColor: UIColor? = UIColor.black
    public var attachButtonFont: UIFont? = UIFont.systemFont(ofSize: 14)

    public var sendButtonImage: UIImage? = UIImage.named("rcmessage_send")
    public var sendButtonTitle: String?
    public var sendButtonTextColor: UIColor? = UIColor.black
    public var sendButtonFont: UIFont? = UIFont.systemFont(ofSize: 14)

    // MARK: - Init

    static let shared = RCMessages()
    
    override init() {
        super.init()
    }


    // MARK: - Static
    // Section
    
    class func sectionHeaderMargin() -> CGFloat {
        return self.shared.sectionHeaderMargin
    }
    
    class var sectionHeaderHeight: CGFloat {
        return shared.sectionHeaderHeight
    }
    
    class func sectionHeaderLeft() -> CGFloat {
        return self.shared.sectionHeaderLeft
    }
    
    class func sectionHeaderRight() -> CGFloat {
        return self.shared.sectionHeaderRight
    }
    
    class func sectionHeaderColor() -> UIColor? {
        return self.shared.sectionHeaderColor
    }
    
    class func sectionHeaderFont() -> UIFont? {
        return self.shared.sectionHeaderFont
    }
    
    class var sectionFooterHeight: CGFloat {
        return self.shared.sectionFooterHeight
    }
    
    class func sectionFooterLeft() -> CGFloat {
        return self.shared.sectionFooterLeft
    }
    
    class func sectionFooterRight() -> CGFloat {
        return self.shared.sectionFooterRight
    }
    
    class func sectionFooterColor() -> UIColor? {
        return self.shared.sectionFooterColor
    }
    
    class func sectionFooterFont() -> UIFont? {
        return self.shared.sectionFooterFont
    }
    
    class func sectionFooterMargin() -> CGFloat {
        return self.shared.sectionFooterMargin
    }
    // Bubble
    
    class func bubbleHeaderHeight() -> CGFloat {
        return self.shared.bubbleHeaderHeight
    }
    
    class func bubbleHeaderLeft() -> CGFloat {
        return self.shared.bubbleHeaderLeft
    }
    
    class func bubbleHeaderRight() -> CGFloat {
        return self.shared.bubbleHeaderRight
    }
    
    class func bubbleHeaderColor() -> UIColor? {
        return self.shared.bubbleHeaderColor
    }
    
    class func bubbleHeaderFont() -> UIFont? {
        return self.shared.bubbleHeaderFont
    }
    
    class func bubbleMarginLeft() -> CGFloat {
        return self.shared.bubbleMarginLeft
    }
    
    class func bubbleMarginRight() -> CGFloat {
        return self.shared.bubbleMarginRight
    }
    
    class func bubbleRadius() -> CGFloat {
        return self.shared.bubbleRadius
    }
    
    class func bubbleFooterHeight() -> CGFloat {
        return self.shared.bubbleFooterHeight
    }
    
    class func bubbleFooterLeft() -> CGFloat {
        return self.shared.bubbleFooterLeft
    }
    
    class func bubbleFooterRight() -> CGFloat {
        return self.shared.bubbleFooterRight
    }
    
    class func bubbleFooterColor() -> UIColor? {
        return self.shared.bubbleFooterColor
    }
    
    class func bubbleFooterFont() -> UIFont? {
        return self.shared.bubbleFooterFont
    }
    // Avatar
    
    class func avatarDiameter() -> CGFloat {
        return self.shared.avatarDiameter
    }
    
    class func avatarMarginLeft() -> CGFloat {
        return self.shared.avatarMarginLeft
    }
    
    class func avatarMarginRight() -> CGFloat {
        return self.shared.avatarMarginRight
    }
    
    class func avatarBackColor() -> UIColor? {
        return self.shared.avatarBackColor
    }
    
    class func avatarTextColor() -> UIColor? {
        return self.shared.avatarTextColor
    }
    
    class func avatarFont() -> UIFont? {
        return self.shared.avatarFont
    }
    
    // Status cell
    class func statusBubbleRadius() -> CGFloat {
        return self.shared.statusBubbleRadius
    }
    
    class func statusBubbleColor() -> UIColor? {
        return self.shared.statusBubbleColor
    }
    
    class func statusTextColor() -> UIColor? {
        return self.shared.statusTextColor
    }
    
    class func statusFont() -> UIFont? {
        return self.shared.statusFont
    }
    
    class func statusInsetLeft() -> CGFloat {
        return self.shared.statusInsetLeft
    }
    
    class func statusInsetRight() -> CGFloat {
        return self.shared.statusInsetRight
    }
    
    class func statusInsetTop() -> CGFloat {
        return self.shared.statusInsetTop
    }
    
    class func statusInsetBottom() -> CGFloat {
        return self.shared.statusInsetBottom
    }
    
    class func statusInset() -> UIEdgeInsets {
        return self.shared.statusInset
    }
    
    // Text cell
    
    class func textBubbleWidthMin() -> CGFloat {
        return self.shared.textBubbleWidthMin
    }
    
    class func textBubbleHeightMin() -> CGFloat {
        return self.shared.textBubbleHeightMin
    }
    
    class func textBubbleColorOutgoing() -> UIColor? {
        return self.shared.textBubbleColorOutgoing
    }
    
    class func textBubbleColorIncoming() -> UIColor? {
        return self.shared.textBubbleColorIncoming
    }
    
    class func textTextColorOutgoing() -> UIColor? {
        return self.shared.textTextColorOutgoing
    }
    
    class func textTextColorIncoming() -> UIColor? {
        return self.shared.textTextColorIncoming
    }
    
    class func textFont() -> UIFont? {
        return self.shared.textFont
    }
    
    class func textInsetLeft() -> CGFloat {
        return self.shared.textInsetLeft
    }
    
    class func textInsetRight() -> CGFloat {
        return self.shared.textInsetRight
    }
    
    class func textInsetTop() -> CGFloat {
        return self.shared.textInsetTop
    }
    
    class func textInsetBottom() -> CGFloat {
        return self.shared.textInsetBottom
    }
    
    class func textInset() -> UIEdgeInsets {
        return self.shared.textInset
    }
    
    // Emoji cell
    class func emojiBubbleWidthMin() -> CGFloat {
        return self.shared.emojiBubbleWidthMin
    }
    
    class func emojiBubbleHeightMin() -> CGFloat {
        return self.shared.emojiBubbleHeightMin
    }
    
    class func emojiBubbleColorOutgoing() -> UIColor? {
        return self.shared.emojiBubbleColorOutgoing
    }
    
    class func emojiBubbleColorIncoming() -> UIColor? {
        return self.shared.emojiBubbleColorIncoming
    }
    
    class func emojiFont() -> UIFont? {
        return self.shared.emojiFont
    }
    
    class func emojiInsetLeft() -> CGFloat {
        return self.shared.emojiInsetLeft
    }
    
    class func emojiInsetRight() -> CGFloat {
        return self.shared.emojiInsetRight
    }
    
    class func emojiInsetTop() -> CGFloat {
        return self.shared.emojiInsetTop
    }
    
    class func emojiInsetBottom() -> CGFloat {
        return self.shared.emojiInsetBottom
    }
    
    class func emojiInset() -> UIEdgeInsets {
        return self.shared.emojiInset
    }
    // Picture cell
    
    class func pictureBubbleWidth() -> CGFloat {
        return self.shared.pictureBubbleWidth
    }
    
    class func pictureBubbleColorOutgoing() -> UIColor? {
        return self.shared.pictureBubbleColorOutgoing
    }
    
    class func pictureBubbleColorIncoming() -> UIColor? {
        return self.shared.pictureBubbleColorIncoming
    }
    
    class func pictureImageManual() -> UIImage? {
        return self.shared.pictureImageManual
    }
    
    // Video cell
    class func videoBubbleWidth() -> CGFloat {
        return self.shared.videoBubbleWidth
    }
    
    class func videoBubbleHeight() -> CGFloat {
        return self.shared.videoBubbleHeight
    }
    
    class func videoBubbleColorOutgoing() -> UIColor? {
        return self.shared.videoBubbleColorOutgoing
    }
    
    class func videoBubbleColorIncoming() -> UIColor? {
        return self.shared.videoBubbleColorIncoming
    }
    
    class func videoImagePlay() -> UIImage? {
        return self.shared.videoImagePlay
    }
    
    class func videoImageManual() -> UIImage? {
        return self.shared.videoImageManual
    }
    
    // Audio cell
    class func audioBubbleWidht() -> CGFloat {
        return self.shared.audioBubbleWidht
    }
    
    class func audioBubbleHeight() -> CGFloat {
        return self.shared.audioBubbleHeight
    }
    
    class func audioBubbleColorOutgoing() -> UIColor? {
        return self.shared.audioBubbleColorOutgoing
    }
    
    class func audioBubbleColorIncoming() -> UIColor? {
        return self.shared.audioBubbleColorIncoming
    }
    
    class func audioTextColorOutgoing() -> UIColor? {
        return self.shared.audioTextColorOutgoing
    }
    
    class func audioTextColorIncoming() -> UIColor? {
        return self.shared.audioTextColorIncoming
    }
    
    class func audioImagePlay() -> UIImage? {
        return self.shared.audioImagePlay
    }
    
    class func audioImagePause() -> UIImage? {
        return self.shared.audioImagePause
    }
    
    class func audioImageManual() -> UIImage? {
        return self.shared.audioImageManual
    }
    
    class func audioFont() -> UIFont? {
        return self.shared.audioFont
    }

    // Location cell
    
    class func locationBubbleWidth() -> CGFloat {
        return self.shared.locationBubbleWidth
    }
    
    class func locationBubbleHeight() -> CGFloat {
        return self.shared.locationBubbleHeight
    }
    
    class func locationBubbleColorOutgoing() -> UIColor? {
        return self.shared.locationBubbleColorOutgoing
    }
    
    class func locationBubbleColorIncoming() -> UIColor? {
        return self.shared.locationBubbleColorIncoming
    }
    
    // Input view
    class func inputViewBackColor() -> UIColor? {
        return self.shared.inputViewBackColor
    }
    
    class func inputTextBackColor() -> UIColor? {
        return self.shared.inputTextBackColor
    }
    
    class func inputTextTextColor() -> UIColor? {
        return self.shared.inputTextTextColor
    }
    
    class func inputFont() -> UIFont? {
        return self.shared.inputFont
    }
    
    class func inputViewHeightMin() -> CGFloat {
        return self.shared.inputViewHeightMin
    }
    
    class func inputTextHeightMin() -> CGFloat {
        return self.shared.inputTextHeightMin
    }
    
    class func inputTextHeightMax() -> CGFloat {
        return self.shared.inputTextHeightMax
    }
    
    class func inputBorderWidth() -> CGFloat {
        return self.shared.inputBorderWidth
    }
    
    class func inputBorderColor() -> CGColor? {
        return self.shared.inputBorderColor
    }
    
    class func inputRadius() -> CGFloat {
        return self.shared.inputRadius
    }
    
    class func inputInsetLeft() -> CGFloat {
        return self.shared.inputInsetLeft
    }
    
    class func inputInsetRight() -> CGFloat {
        return self.shared.inputInsetRight
    }
    
    class func inputInsetTop() -> CGFloat {
        return self.shared.inputInsetTop
    }
    
    class func inputInsetBottom() -> CGFloat {
        return self.shared.inputInsetBottom
    }
    
    class func inputInset() -> UIEdgeInsets {
        return self.shared.inputInset
    }

}
