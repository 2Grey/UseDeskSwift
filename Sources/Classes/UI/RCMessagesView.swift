//
//  RCMessagesView.swift

import AVFoundation
import Photos
import UITextView_Placeholder

class RCMessagesView: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextViewDelegate {

    @IBOutlet var infoView: UIView!
    @IBOutlet var infoLabel: UILabel!

    @IBOutlet var tableView: UITableView!

    @IBOutlet var viewInput: UIView!
    @IBOutlet var buttonInputAttach: UIButton!
    @IBOutlet var buttonInputSend: UIButton!
    @IBOutlet var textInput: UITextView!
    @IBOutlet var attachCollectionView: UICollectionView!
    @IBOutlet var bottomFillerView: UIView!

    @IBOutlet var infoViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet var textInputHeightConstraint: NSLayoutConstraint!
    @IBOutlet var attachCollectionViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet var bottomFillerViewHeightConstraint: NSLayoutConstraint!

    @IBOutlet var attachButtonWidthConstraint: NSLayoutConstraint!
    @IBOutlet var attachButtonHeightConstraint: NSLayoutConstraint!

    @IBOutlet var sendButtonWidthConstraint: NSLayoutConstraint!
    @IBOutlet var sendButtonHeightConstraint: NSLayoutConstraint!

    weak var usedesk: UseDeskSDK?

    public var sendAssets: [Any] = []

    private var initialized = false
    private var isViewDidLayoutSubviews = false
    private var isViewInputResizeFromAttach = false
    private var timerAudio: Timer?
    private var dateAudioStart: Date?
    private var pointAudioStart = CGPoint.zero
    private var audioRecorder: AVAudioRecorder?

    convenience init() {
        self.init(nibName: "RCMessagesView", bundle: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = RCMessages.shared.chatBackgroundColor
        self.tableView.backgroundColor = RCMessages.shared.chatBackgroundColor

        tableView.register(RCSectionHeaderCell.self, forCellReuseIdentifier: "RCSectionHeaderCell")
        tableView.register(RCBubbleHeaderCell.self, forCellReuseIdentifier: "RCBubbleHeaderCell")
        tableView.register(RCBubbleFooterCell.self, forCellReuseIdentifier: "RCBubbleFooterCell")
        tableView.register(RCSectionFooterCell.self, forCellReuseIdentifier: "RCSectionFooterCell")
        tableView.register(RCStatusCell.self, forCellReuseIdentifier: "RCStatusCell")
        tableView.register(RCTextMessageCell.self, forCellReuseIdentifier: "RCTextMessageCell")
        tableView.register(RCEmojiMessageCell.self, forCellReuseIdentifier: "RCEmojiMessageCell")
        tableView.register(RCPictureMessageCell.self, forCellReuseIdentifier: "RCPictureMessageCell")
        tableView.register(RCVideoMessageCell.self, forCellReuseIdentifier: "RCVideoMessageCell")
        tableView.register(RCAudioMessageCell.self, forCellReuseIdentifier: "RCAudioMessageCell")
        tableView.register(RCLocationMessageCell.self, forCellReuseIdentifier: "RCLocationMessageCell")

        self.bottomFillerViewHeightConstraint.constant = UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 1.0

        attachCollectionView.delegate = self
        attachCollectionView.dataSource = self
        attachCollectionView.register(RCAttachCollectionViewCell.self, forCellWithReuseIdentifier: "RCAttachCollectionViewCell")

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardNotification(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)

        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(self.audioRecorderGesture(_:)))
        gesture.minimumPressDuration = 0
        gesture.cancelsTouchesInView = false

        let tapInfoGesture = UITapGestureRecognizer(target: self, action: #selector(self.infoViewAction(_:)))
        self.infoView.addGestureRecognizer(tapInfoGesture)

        inputPanelInit()

        self.hideInfo(animated: false)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if !isViewDidLayoutSubviews {
            isViewDidLayoutSubviews = true
            self.inputPanelUpdate()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        dismissKeyboard()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if initialized == false {
            initialized = true
            self.scroll(toBottom: true)
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        dismissKeyboard()
    }

    // MARK: - Message methods

    func rcmessage(_ indexPath: IndexPath?) -> RCMessage? {
        return nil
    }

    // MARK: - Avatar methods

    func avatarInitials(_ indexPath: IndexPath?) -> String? {
        return nil
    }

    func avatarImage(_ indexPath: IndexPath?) -> UIImage? {
        return nil
    }

    // MARK: - Info viw methods

    func showInfo(text: String?, animated: Bool) {
        guard let text = text else {
            self.hideInfo(animated: animated)
            return
        }

        self.infoLabel.text = text

        let contentSize = CGSize(width: self.infoView.frame.width - 10.0 * 2.0, height: CGFloat.greatestFiniteMagnitude)
        let preHeight = self.infoLabel.sizeThatFits(contentSize).height

        let height = preHeight + 5.0 * 2.0

        self.infoView.isHidden = false

        self.view.layoutIfNeeded()
        UIView.animate(withDuration: animated ? 0.45 : 0.0, animations: { [weak self] in
            self?.infoViewHeightConstraint.constant = height
            self?.infoView.setNeedsUpdateConstraints()
            self?.view.layoutIfNeeded()
        })
    }

    func hideInfo(animated: Bool) {
        self.view.layoutIfNeeded()

        UIView.animate(withDuration: animated ? 0.45 : 0.0, animations: { [weak self] in
            self?.infoViewHeightConstraint.constant = 0
            self?.infoView.setNeedsUpdateConstraints()
            self?.view.layoutIfNeeded()
        }) { [weak self] _ in
            self?.infoLabel.text = nil
            self?.infoView.isHidden = true
        }
    }

    @objc private func infoViewAction(_ sender: UITapGestureRecognizer) {
        self.hideInfo(animated: true)
    }

    // MARK: - Header, Footer methods

    func textBubbleHeader(_ indexPath: IndexPath?) -> String? {
        return nil
    }

    func textBubbleFooter(_ indexPath: IndexPath?) -> String? {
        return nil
    }

    func textSectionFooter(_ indexPath: IndexPath?) -> String? {
        return nil
    }

    // MARK: - Menu controller methods

    func menuItems(_ indexPath: IndexPath?) -> [Any]? {
        return nil
    }

    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return false
    }

    override var canBecomeFirstResponder: Bool {
        return true
    }

    func dismissKeyboard() {
        view.endEditing(true)
    }

    // MARK: - Input panel methods

    func inputPanelInit() {
        viewInput.backgroundColor = RCMessages.inputViewBackColor()
        bottomFillerView.backgroundColor = RCMessages.inputViewBackColor()
        textInput.backgroundColor = RCMessages.inputTextBackColor()
        textInput.isScrollEnabled = false

        textInput.font = RCMessages.inputFont()
        textInput.textColor = RCMessages.inputTextTextColor()

        textInput.textContainer.lineFragmentPadding = 0
        textInput.textContainerInset = RCMessages.inputInset()

        textInput.layer.borderColor = RCMessages.inputBorderColor()
        textInput.layer.borderWidth = RCMessages.inputBorderWidth()

        textInput.layer.cornerRadius = RCMessages.inputRadius()
        textInput.clipsToBounds = true

        textInput.placeholder = RCMessages.shared.inputPlaceholderText
        textInput.placeholderColor = RCMessages.shared.inputPlaceholderColor
    }

    func inputPanelUpdate() {
        let widthText = self.textInput.frame.size.width
        let sizeText = textInput.sizeThatFits(CGSize(width: widthText, height: CGFloat.greatestFiniteMagnitude))

        let inputTextHeightMax = RCMessages.inputTextHeightMax()

        var heightText = CGFloat(fmaxf(Float(RCMessages.inputTextHeightMin()), Float(sizeText.height)))
        heightText = CGFloat(fminf(Float(inputTextHeightMax), Float(heightText)))

        var heightInput: CGFloat = 0
        if heightText >= inputTextHeightMax {
            heightInput = inputTextHeightMax
            self.textInput.isScrollEnabled = true
        } else {
            heightInput = heightText
            self.textInput.isScrollEnabled = false
        }
        self.viewInput.layoutIfNeeded()

        self.textInputHeightConstraint.constant = heightInput

        self.view.layoutIfNeeded()

        let theme = RCMessages.shared

        // * Attach Button

        switch theme.attachButtonContent {
        case .image(let image):
            buttonInputAttach.setImage(image, for: UIControl.State.normal)
        case .text(let title):
            buttonInputAttach.setTitle(title, for: UIControl.State.normal)
        }

        if let attachButtonTextColor = theme.attachButtonTextColor {
            buttonInputAttach.setTitleColor(theme.attachButtonTextColor, for: UIControl.State.normal)
            buttonInputAttach.setTitleColor(attachButtonTextColor.withAlphaComponent(0.75), for: UIControl.State.highlighted)
            buttonInputAttach.setTitleColor(attachButtonTextColor.withAlphaComponent(0.5), for: UIControl.State.disabled)
        }
        buttonInputAttach.titleLabel?.font = theme.attachButtonFont
        buttonInputAttach.contentMode = theme.attachButtonContentModel

        let attachButtonSize = theme.attachButtonSize
        if attachButtonSize.equalTo(CGSize.zero) == false {
            self.attachButtonWidthConstraint.constant = attachButtonSize.width
            self.attachButtonHeightConstraint.constant = attachButtonSize.height
        }

        // * Send Button

        self.updateSendButtonState()

        switch theme.sendButtonContent {
        case .image(let image):
            buttonInputSend.setImage(image, for: UIControl.State.normal)
        case .text(let title):
            buttonInputSend.setTitle(title, for: UIControl.State.normal)
        }

        if let sendButtonTextColor = theme.sendButtonTextColor {
            buttonInputSend.setTitleColor(theme.sendButtonTextColor, for: UIControl.State.normal)
            buttonInputSend.setTitleColor(sendButtonTextColor.withAlphaComponent(0.75), for: UIControl.State.highlighted)
            buttonInputSend.setTitleColor(sendButtonTextColor.withAlphaComponent(0.5), for: UIControl.State.disabled)
        }
        buttonInputSend.titleLabel?.font = RCMessages.shared.sendButtonFont
        buttonInputSend.contentMode = theme.sendButtonContentModel

        let sendButtonSize = theme.sendButtonSize
        if sendButtonSize.equalTo(CGSize.zero) == false {
            self.sendButtonWidthConstraint.constant = sendButtonSize.width
            self.sendButtonHeightConstraint.constant = sendButtonSize.height
        }
    }

    // MARK: * Send button

    func isSendButtonEnabled() -> Bool {
        return textInput.text.isEmpty == false
    }

    func updateSendButtonState() {
        buttonInputSend.isEnabled = self.isSendButtonEnabled()
    }

    // MARK: * User actions (bubble tap)

    func actionTapBubble(_ indexPath: IndexPath?) {}

    // MARK: * User actions (avatar tap)

    func actionTapAvatar(_ indexPath: IndexPath?) {}

    // MARK: - User actions (input panel)

    @IBAction func actionInputAttach(_ sender: Any) {
        self.dismissKeyboard()
        self.actionAttachMessage()
    }

    @IBAction func actionInputSend(_ sender: Any) {
        self.actionSendMessage(self.textInput.text)
        self.dismissKeyboard()
        self.textInput.text = nil
        self.inputPanelUpdate()
    }

    @objc func buttonFromMessageAction() {}

    func actionAttachMessage() {}

    func actionSendAudio(_ path: String?) {}

    func actionSendMessage(_ text: String?) {}

    // MARK: - UIScrollViewDelegate

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        dismissKeyboard()
    }

    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        return 0
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return RCMessages.sectionHeaderMargin()
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return RCMessages.sectionFooterMargin()
    }

    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = UIColor.clear
    }

    func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        view.tintColor = UIColor.clear
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return RCSectionHeaderCell.height(indexPath, messagesView: self)
        }
        if indexPath.row == 1 {
            return RCBubbleHeaderCell.height(indexPath, messagesView: self)
        }
        if indexPath.row == 2 {
            let rcmessage: RCMessage? = self.rcmessage(indexPath)
            if rcmessage?.type == RCType.status {
                return RCStatusCell.height(indexPath, messagesView: self)
            }
            if rcmessage?.type == RCType.text {
                var heightButtons: CGFloat = 0
                for _ in rcmessage!.rcButtons {
                    heightButtons += 40
                }
                heightButtons += 25
                return RCTextMessageCell.height(indexPath, messagesView: self) + heightButtons
            }
            if rcmessage?.type == RCType.feedback {
                return RCEmojiMessageCell.height(indexPath, messagesView: self)
            }
            if rcmessage?.type == RCType.picture {
                return RCPictureMessageCell.height(indexPath, messagesView: self)
            }
            if rcmessage?.type == RCType.video {
                return RCVideoMessageCell.height(indexPath, messagesView: self)
            }
            if rcmessage?.type == RCType.audio {
                return RCAudioMessageCell.height(indexPath, messagesView: self)
            }
            if rcmessage?.type == RCType.location {
                return RCLocationMessageCell.height(indexPath, messagesView: self)
            }
        }
        if indexPath.row == 3 {
            return RCBubbleFooterCell.height(indexPath, messagesView: self)
        }
        if indexPath.row == 4 {
            return RCSectionFooterCell.height(indexPath, messagesView: self)
        }
        return 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "RCSectionHeaderCell", for: indexPath) as? RCSectionHeaderCell
            cell!.bindData(indexPath, messagesView: self)
            return cell!
        } else if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "RCBubbleHeaderCell", for: indexPath) as! RCBubbleHeaderCell
            cell.bindData(indexPath, messagesView: self)
            return cell
        } else if indexPath.row == 2 {
            let rcmessage: RCMessage? = self.rcmessage(indexPath)
            if rcmessage?.type == RCType.status {
                let cell = tableView.dequeueReusableCell(withIdentifier: "RCStatusCell", for: indexPath) as! RCStatusCell
                cell.bindData(indexPath, messagesView: self)
                return cell
            }
            if rcmessage?.type == RCType.text {
                let cell = tableView.dequeueReusableCell(withIdentifier: "RCTextMessageCell", for: indexPath) as! RCTextMessageCell
                cell.bindData(indexPath, messagesView: self)
                //                for button in cell.buttons {
                //                    button.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.buttonFromMessageAction)))
                //                }
                return cell
            }
            if rcmessage?.type == RCType.feedback {
                let cell = tableView.dequeueReusableCell(withIdentifier: "RCEmojiMessageCell", for: indexPath) as! RCEmojiMessageCell
                if usedesk != nil {
                    cell.usedesk = usedesk!
                }
                cell.bindData(indexPath, messagesView: self)
                return cell
            }
            if rcmessage?.type == RCType.picture {
                let cell = tableView.dequeueReusableCell(withIdentifier: "RCPictureMessageCell", for: indexPath) as! RCPictureMessageCell
                cell.bindData(indexPath, messagesView: self)
                return cell
            }
            if rcmessage!.type == RCType.video {
                let cell = tableView.dequeueReusableCell(withIdentifier: "RCVideoMessageCell", for: indexPath) as! RCVideoMessageCell

                let rcmessage = self.rcmessage(indexPath)
                if rcmessage?.video_path == "" {
                    cell.setData(indexPath, messagesView: self)
                    UDFileManager.downloadFile(indexPath: indexPath, urlPath: rcmessage!.file?.content ?? "", successBlock: { [weak self] indexPath, urlVideo in
                        guard let wSelf = self else { return }
                        if let rcmessage = wSelf.rcmessage(indexPath) {
                            rcmessage.video_path = urlVideo.path
                            rcmessage.picture_image = UDFileManager.videoPreview(filePath: urlVideo.path)
                            cell.addVideo(previewImage: rcmessage.picture_image!)
                        }
                    }, errorBlock: { error in

                    })
                } else {
                    cell.setData(indexPath, messagesView: self)
                    if rcmessage != nil {
                        cell.addVideo(previewImage: rcmessage!.picture_image ?? UDFileManager.videoPreview(filePath: rcmessage!.video_path))
                    }
                }
                return cell
            }
            if rcmessage!.type == RCType.audio {
                let cell = tableView.dequeueReusableCell(withIdentifier: "RCAudioMessageCell", for: indexPath) as! RCAudioMessageCell
                cell.bindData(indexPath, messagesView: self)
                return cell
            }
            if rcmessage!.type == RCType.location {
                let cell = tableView.dequeueReusableCell(withIdentifier: "RCLocationMessageCell", for: indexPath) as! RCLocationMessageCell
                cell.bindData(indexPath, messagesView: self)
                return cell
            }
        } else if indexPath.row == 3 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "RCBubbleFooterCell", for: indexPath) as! RCBubbleFooterCell
            cell.bindData(indexPath, messagesView: self)
            return cell
        } else /* if indexPath.row == 4 */ {
            let cell = tableView.dequeueReusableCell(withIdentifier: "RCSectionFooterCell", for: indexPath) as! RCSectionFooterCell
            cell.bindData(indexPath, messagesView: self)
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "RCSectionFooterCell", for: indexPath) as! RCSectionFooterCell
        cell.bindData(indexPath, messagesView: self)
        return cell
    }

    // MARK: - Table view data source

    func showAttachCollection(assets: [Any]) {
        attachCollectionView.reloadData()
        if !isViewInputResizeFromAttach {
            UIView.animate(withDuration: 0.3) {
                self.attachCollectionViewHeightConstraint.constant = Constants.heightAssetsCollection
                self.attachCollectionView.alpha = 1
                self.view.layoutIfNeeded()
                self.isViewInputResizeFromAttach = true
            }
        }
    }

    func closeAttachCollection() {
        let isClosed = self.attachCollectionViewHeightConstraint.constant == 0.0
        if !isClosed {
            UIView.animate(withDuration: 0.3) {
                self.attachCollectionViewHeightConstraint.constant = 0.0
                self.attachCollectionView.alpha = 0
                self.view.layoutIfNeeded()
                self.isViewInputResizeFromAttach = false
            }
        }
    }

    // MARK: - Helper methods

    func scroll(toBottom animated: Bool) {
        if tableView.numberOfSections > 0 {
            let indexPath = IndexPath(row: 0, section: tableView.numberOfSections - 1)
            tableView.scrollToRow(at: indexPath, at: .top, animated: animated)
        }
    }

    // MARK: - UITextViewDelegate

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        return true
    }

    func textViewDidChange(_ textView: UITextView) {
        self.inputPanelUpdate()
    }

    // MARK: - Audio recorder methods

    @objc func audioRecorderGesture(_ gestureRecognizer: UILongPressGestureRecognizer) {
        switch gestureRecognizer.state {
        case .began:
            pointAudioStart = gestureRecognizer.location(in: view)
            audioRecorderInit()
            audioRecorderStart()
        case .changed:
            break
        case .ended:
            let pointAudioStop: CGPoint? = gestureRecognizer.location(in: view)
            let distanceAudio = sqrtf(powf(Float((pointAudioStop?.x ?? 0.0) - pointAudioStart.x), 2) + Float(pow((pointAudioStop?.y ?? 0.0) - pointAudioStart.y, 2)))
            audioRecorderStop(distanceAudio < 50)
        case .possible, .cancelled, .failed:
            break
        default:
            break
        }
    }

    func audioRecorderInit() {
        let dir = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first
        let path = URL(fileURLWithPath: dir ?? "").appendingPathComponent("audiorecorder.m4a").absoluteString
        do {
            let audioSession = AVAudioSession.sharedInstance()
            if #available(iOS 10.0, *) {
                try audioSession.setCategory(AVAudioSession.Category.playAndRecord)
            } else {
                AVAudioSession.sharedInstance().perform(NSSelectorFromString("setCategory:error:"), with: AVAudioSession.Category.playAndRecord)
            }
        } catch {}

        var settings: [AnyHashable: Any] = [:]
        settings[AVFormatIDKey] = NSNumber(value: kAudioFormatMPEG4AAC)
        settings[AVSampleRateKey] = NSNumber(value: 44100)
        settings[AVNumberOfChannelsKey] = NSNumber(value: 2)

        if let settings = settings as? [String: Any] {
            self.audioRecorder = try? AVAudioRecorder(url: URL(fileURLWithPath: path), settings: settings)
        }

        self.audioRecorder!.isMeteringEnabled = true

        self.audioRecorder!.prepareToRecord()
    }

    func audioRecorderStart() {
        self.audioRecorder?.record()

        self.dateAudioStart = Date()

        self.timerAudio = Timer.scheduledTimer(timeInterval: 0.07, target: self, selector: #selector(self.audioRecorderUpdate), userInfo: nil, repeats: true)

        self.audioRecorderUpdate()
    }

    func audioRecorderStop(_ sending: Bool) {
        self.audioRecorder?.stop()

        self.timerAudio?.invalidate()
        self.timerAudio = nil

        if sending, Date().timeIntervalSince(self.dateAudioStart!) >= 1 {
            self.dismissKeyboard()
            self.actionSendAudio(self.audioRecorder!.url.path)
        } else {
            self.audioRecorder!.deleteRecording()
        }
    }

    @objc func audioRecorderUpdate() {
        //        let interval: TimeInterval = Date().timeIntervalSince(dateAudioStart!)
        //        let millisec = Int(interval * 100) % 100
        //        let seconds = Int(interval) % 60
        //        let minutes = Int(interval) / 60
        // labelInputAudio.text = String(format: "%01d:%02d,%02d", minutes, seconds, millisec)
    }
}

extension RCMessagesView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sendAssets.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RCAttachCollectionViewCell", for: indexPath) as! RCAttachCollectionViewCell
        cell.delegate = self

        if let image = sendAssets[indexPath.row] as? UIImage {
            cell.setingCell(image: image, type: PHAssetMediaType.image, index: indexPath.row)
        } else if let asset = sendAssets[indexPath.row] as? PHAsset {
            let options = PHImageRequestOptions()
            options.isSynchronous = true

            PHCachingImageManager.default().requestImage(for: asset,
                                                         targetSize: CGSize(width: CGFloat(asset.pixelWidth), height: CGFloat(asset.pixelHeight)),
                                                         contentMode: .aspectFit,
                                                         options: options,
                                                         resultHandler: { [weak cell] result, info in
                                                             if let result = result {
                                                                 cell?.setingCell(image: result,
                                                                                  type: asset.mediaType,
                                                                                  videoDuration: asset.duration,
                                                                                  index: indexPath.row)
                                                             }
                                                         })
        }

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: Constants.heightAssetsCollection, height: Constants.heightAssetsCollection)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 4.0
    }
}

extension RCMessagesView: RCAttachCVCellDelegate {
    func deleteFile(index: Int) {
        self.sendAssets.remove(at: index)
        self.attachCollectionView.reloadData()

        if sendAssets.count == 0 {
            self.sendAssets = []
            self.closeAttachCollection()
            self.updateSendButtonState()
        }
    }
}

extension RCMessagesView {

    @objc func keyboardNotification(notification: NSNotification) {
        guard let userInfo = notification.userInfo else { return }

        let endFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
        let endFrameY = endFrame?.origin.y ?? 0

        let duration: TimeInterval = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
        let animationCurveRawNSN = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber
        let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIView.AnimationOptions.curveEaseInOut.rawValue
        let animationCurve = UIView.AnimationOptions(rawValue: animationCurveRaw)

        if endFrameY >= UIScreen.main.bounds.size.height {
            self.bottomFillerViewHeightConstraint.constant = UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 1.0
        } else {
            let height = endFrame?.size.height ?? 0.0
            self.bottomFillerViewHeightConstraint.constant = height

            UIMenuController.shared.menuItems = nil
        }
        self.view.setNeedsLayout()
        self.view.setNeedsUpdateConstraints()

        UIView.animate(withDuration: duration, delay: 0.0, options: animationCurve, animations: {
            self.inputPanelUpdate()
            self.view.layoutIfNeeded()
            self.view.updateConstraintsIfNeeded()
        }, completion: nil)
    }
}
