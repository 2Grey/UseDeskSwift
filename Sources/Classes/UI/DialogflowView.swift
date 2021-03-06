//
//  DialogflowView.swift

import Foundation
import UIKit
import QBImagePickerController
import SVProgressHUD
import AVKit

class DialogflowView: RCMessagesView, UINavigationControllerDelegate {

    var rcmessages: [RCMessage] = []
    var isFromBase = false

    private var imageVC: UDImageView!

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = usedesk?.config?.nameChat

        if let customBackButtonControl = RCMessages.shared.customBackButtonControl {
            customBackButtonControl.addTarget(self, action: #selector(self.actionDone), for: UIControl.Event.touchUpInside)
            navigationItem.leftBarButtonItem = UIBarButtonItem(customView: customBackButtonControl)
        } else {
            navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .reply, target: self, action: #selector(self.actionDone))
        }

        // Notification
        NotificationCenter.default.addObserver(self, selector: #selector(self.openUrlFromMessageButton(_:)), name: Notification.Name("messageButtonURLOpen"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.sendMessageButton(_:)), name: Notification.Name("messageButtonSend"), object: nil)

        rcmessages = [RCMessage]()

        guard let usedesk = usedesk else {
            reloadhistory()
            return
        }

        usedesk.connectBlock = { [weak self] success, error in
            guard let wSelf = self else { return }
            wSelf.hideInfo(animated: true)
            SVProgressHUD.dismiss()
            wSelf.reloadhistory()
        }

        usedesk.disconnectBlock = { [weak self] data in
            guard let wSelf = self else { return }
            wSelf.showInfo(text: "Соединение потеряно", animated: true)
        }

        usedesk.newMessageBlock = { [weak self] success, message in
            guard let wSelf = self else { return }
            if let aMessage = message {
                wSelf.rcmessages.append(aMessage)
            }
            wSelf.refreshTableView1()
        }

        usedesk.feedbackAnswerMessageBlock = { [weak self] success in
            guard let wSelf = self else { return }

            let alert = UIAlertController(title: "", message: "Спасибо за вашу оценку", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default))
            wSelf.present(alert, animated: true)
        }

        usedesk.errorBlock = { [weak self] errors in
            guard let wSelf = self else { return }

            var hudErrorMessage: String?
            if (errors?.count ?? 0) > 0 {
                let errorMessage = RCMessages.shared.defaultSocketErrorMessage ?? errors?.first as? String
                hudErrorMessage = errorMessage
            }
            SVProgressHUD.showError(withStatus: hudErrorMessage)
        }

        usedesk.feedbackMessageBlock = { [weak self] message in
            guard let wSelf = self else { return }

            if let aMessage = message {
                wSelf.rcmessages.append(aMessage)
            }
            wSelf.refreshTableView1()
        }

        reloadhistory()
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: Notification.Name("messageButtonURLOpen"), object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name("messageButtonSend"), object: nil)
    }

    func reloadhistory() {
        guard let usedesk = self.usedesk else { return }

        rcmessages = []
        for message in usedesk.historyMess {
            rcmessages.append(message)
        }
        refreshTableView1()
    }

    // MARK: - Parent methods

    override func isSendButtonEnabled() -> Bool {
        return super.isSendButtonEnabled() || self.sendAssets.isEmpty == false
    }

    // MARK: - Message methods

    override func rcmessage(_ indexPath: IndexPath?) -> RCMessage? {
        guard let indexPath = indexPath else { return nil }
        return (rcmessages[indexPath.section])
    }

    func addMessage(_ text: String?, incoming: Bool) {
        let rcmessage = RCMessage(text: text, incoming: incoming)
        rcmessages.append(rcmessage)
        refreshTableView1()
    }

    // MARK: - Message Button methods

    @objc func openUrlFromMessageButton(_ notification: NSNotification) {
        guard let urlString = notification.userInfo?["url"] as? String, let url = URL(string: urlString) else { return }
        UIApplication.shared.open(url, options: [:])
    }

    @objc func sendMessageButton(_ notification: NSNotification) {
        guard let text = notification.userInfo?["text"] as? String else { return }
        usedesk?.sendMessage(text)
    }

    // MARK: - Avatar methods

    override func avatarInitials(_ indexPath: IndexPath?) -> String? {
        guard let indexPath = indexPath else { return nil }

        let rcmessage = rcmessages[indexPath.section]
        if rcmessage.outgoing {
            return "you"
        } else {
            return "Ad"
        }
    }

    override func avatarImage(_ indexPath: IndexPath?) -> UIImage? {
        guard let indexPath = indexPath else { return nil }

        let rcmessage = rcmessages[indexPath.section]

        let avatar = rcmessage.avatar
        var image: UIImage?
        do {
            if let avatarURL = URL(string: avatar) {
                let anAvatar1 = try Data(contentsOf: avatarURL)
                image = UIImage(data: anAvatar1)
            } else {
                if rcmessage.outgoing == true {
                    return UIImage.named("avatarClient")
                } else {
                    return UIImage.named("avatarOperator")
                }
            }
        } catch {}
//        if let anAvatar = URL(string: rcmessage.avatar ?? ""), let anAvatar1 = Data(contentsOf: anAvatar) {
//            image = UIImage(data: anAvatar1)
//        }
        return image
    }

    // MARK: - Header, Footer methods

    override func textBubbleHeader(_ indexPath: IndexPath?) -> String? {
        return nil
    }

    override func textBubbleFooter(_ indexPath: IndexPath?) -> String? {
        return nil
    }

    override func textSectionFooter(_ indexPath: IndexPath?) -> String? {
        return nil
    }

    override func menuItems(_ indexPath: IndexPath?) -> [Any]? {
        let menuItemCopy = RCMenuItem(title: "Copy", action: #selector(self.actionMenuCopy(_:)))
        menuItemCopy.indexPath = indexPath
        return [menuItemCopy]
    }

    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return action == #selector(self.actionMenuCopy(_:))
    }

    // MARK: - Refresh methods

    func refreshTableView1() {
        refreshTableView2()
        scroll(toBottom: true)
    }

    func refreshTableView2() {
        tableView.reloadData()
    }

    func displayDialogflowResponse(_ dictionary: [AnyHashable: Any]?, delay: CGFloat) {
        let time = DispatchTime.now() + Double(delay)

        DispatchQueue.main.asyncAfter(deadline: time, execute: { [weak self] in
            guard let wSelf = self else { return }
            wSelf.displayDialogflowResponse(dictionary)
        })
    }

    func displayDialogflowResponse(_ dictionary: [AnyHashable: Any]?) {
        let result = dictionary?["result"] as? [AnyHashable: Any]
        let fulfillment = result?["fulfillment"] as? [AnyHashable: Any]
        let text = fulfillment?["speech"] as? String
        addMessage(text, incoming: true)
    }

    // MARK: - User actions

    @objc func actionDone() {
        for rcmessage in rcmessages where rcmessage.video_path.isEmpty == false {
            try? FileManager().removeItem(atPath: rcmessage.video_path)
        }
        usedesk?.releaseChat()

        if isFromBase {
            navigationController?.popViewController(animated: true)
        } else {
            dismiss(animated: true)
        }
    }

    override func actionSendMessage(_ text: String?) {
        if let text = text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines), text.isEmpty == false {
            usedesk?.sendMessage(text)
        }

        let imageQueue = DispatchQueue(label: "ImageQueue", qos: DispatchQoS.userInitiated, attributes: DispatchQueue.Attributes.concurrent)

        for asset in sendAssets {
            if let phAsset = asset as? PHAsset {
                if phAsset.mediaType == .video {
                    let options = PHVideoRequestOptions()
                    options.version = .original
                    PHCachingImageManager.default().requestAVAsset(forVideo: phAsset, options: options) { [weak self] avasset, _, _ in
                        guard let wSelf = self else { return }
                        if let avassetURL = avasset as? AVURLAsset {
                            if let video = try? Data(contentsOf: avassetURL.url) {
                                imageQueue.async {
                                    let content = "data:video/mp4;base64,\(video.base64EncodedString())"
                                    let fileName = String(format: "%ld", content.hash) + ".mp4"
                                    DispatchQueue.main.async {
                                        wSelf.usedesk?.sendMessage("", withFileName: fileName, fileType: "video/mp4", contentBase64: content)
                                    }
                                }
                            }
                        }
                    }
                } else {
                    let options = PHImageRequestOptions()
                    options.deliveryMode = PHImageRequestOptionsDeliveryMode.highQualityFormat
                    options.isSynchronous = false
                    options.isNetworkAccessAllowed = true

                    let targetSize = CGSize(width: CGFloat(phAsset.pixelWidth), height: CGFloat(phAsset.pixelHeight))
                    PHCachingImageManager.default().requestImage(for: phAsset, targetSize: targetSize, contentMode: .aspectFit, options: options, resultHandler: { [weak self] result, _ in
                        guard let wSelf = self else { return }
                        if let result = result {
                            imageQueue.async {
                                let content = "data:image/png;base64,\(UseDeskSDKHelp.image(toNSString: result))"
                                let fileName = String(format: "%ld", content.hash) + ".png"
                                DispatchQueue.main.async {
                                    wSelf.usedesk?.sendMessage("", withFileName: fileName, fileType: "image/png", contentBase64: content)
                                }
                            }
                        }
                    })
                }
            } else if let uiImage = asset as? UIImage {
                imageQueue.async { [weak self] in
                    let content = "data:image/png;base64,\(UseDeskSDKHelp.image(toNSString: uiImage))"
                    let fileName = String(format: "%ld", content.hash) + ".png"
                    DispatchQueue.main.async {
                        self?.usedesk?.sendMessage("", withFileName: fileName, fileType: "image/png", contentBase64: content)
                    }
                }
            }
        }

        self.sendAssets = []
        self.closeAttachCollection()
    }

    override func actionAttachMessage() {
        if sendAssets.count < Constants.maxCountAssets {
            let alertController = UIAlertController(title: "Прикрепить файл", message: nil, preferredStyle: UIAlertController.Style.alert)
            let cancelAction = UIAlertAction(title: "Отмена", style: .destructive)
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) {
                let takePhotoAction = UIAlertAction(title: "Камера", style: .default) { (_) -> Void in
                    self.takePhoto()
                }
                alertController.addAction(takePhotoAction)
            }
            let selectFromPhotosAction = UIAlertAction(title: "Галерея", style: .default) { (_) -> Void in
                self.selectPhoto()
            }
            alertController.addAction(selectFromPhotosAction)
            alertController.addAction(cancelAction)
            self.present(alertController, animated: true, completion: nil)
        } else {
            let alertController = UIAlertController(title: "Прикреплено максимальное колличество файлов", message: nil, preferredStyle: UIAlertController.Style.alert)
            let okAction = UIAlertAction(title: "Ок", style: .default) { (_) -> Void in }
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }

    func takePhoto() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        picker.sourceType = .camera
        self.present(picker, animated: true)
    }

    func selectPhoto() {
        PHPhotoLibrary.requestAuthorization { [weak self] status in
            if status == .authorized {
                DispatchQueue.main.async { [weak self] in
                    self?.openPhotoSelector()
                }
            } else {
                DispatchQueue.main.async { [weak self] in
                    let alertController = UIAlertController(title: "Ошибка", message: "Доступ к фотогалерее заблокирован", preferredStyle: UIAlertController.Style.alert)
                    alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default))
                    self?.present(alertController, animated: true)
                }
            }
        }
    }

    private func openPhotoSelector() {
        let imagePickerController = QBImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsMultipleSelection = true
        imagePickerController.maximumNumberOfSelection = UInt(Constants.maxCountAssets - sendAssets.count)
        imagePickerController.showsNumberOfSelectedAssets = true
        imagePickerController.mediaType = RCMessages.shared.pickerMediaType
        self.present(imagePickerController, animated: true)
    }

    // MARK: - User actions (menu)

    @objc func actionMenuCopy(_ sender: Any?) {
        let indexPath: IndexPath? = RCMenuItem.indexPath(sender as? UIMenuController)
        let rcmessage: RCMessage? = self.rcmessage(indexPath)
        UIPasteboard.general.string = rcmessage?.text
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return rcmessages.count
    }

    override func actionTapBubble(_ indexPath: IndexPath?) {
        guard let indexPath = indexPath else { return }

        let rcmessage = rcmessages[indexPath.section]

        guard let messageFile = rcmessage.file else { return }

        if messageFile.type == "image" {
            navigationItem.leftBarButtonItem?.isEnabled = false
            navigationItem.leftBarButtonItem?.tintColor = .clear

            if let cell = tableView.cellForRow(at: indexPath) as? RCPictureMessageCell {
                rcmessage.status = RCStatus.openimage
                cell.bindData(indexPath, messagesView: self)
            }

            imageVC = UDImageView(nibName: "UDImageView", bundle: nil)
            self.addChild(self.imageVC)
            self.view.addSubview(self.imageVC.view)
            imageVC.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
            imageVC.delegate = self

            let session = URLSession.shared
            if let url = URL(string: messageFile.content) {
                session.dataTask(with: url, completionHandler: { data, _, error in
                    if error == nil {
                        DispatchQueue.main.async(execute: { [weak self] in
                            guard let wSelf = self else { return }
                            rcmessage.picture_image = UIImage(data: data!)
                            if let pictureImage = rcmessage.picture_image {
                                wSelf.imageVC.showImage(image: pictureImage)
                            }
                            if let cell = wSelf.tableView.cellForRow(at: indexPath) as? RCPictureMessageCell {
                                rcmessage.status = RCStatus.succeed
                                cell.bindData(indexPath, messagesView: wSelf)
                            }
                        })
                    }
                }).resume()
            }
        } else if rcmessage.file!.type == "video" {
            if rcmessage.video_path != "" {
                let videoURL = URL(fileURLWithPath: rcmessage.video_path)
                let player = AVPlayer(url: videoURL)
                let playerViewController = AVPlayerViewController()
                playerViewController.player = player
                self.present(playerViewController, animated: true) {
                    playerViewController.player?.play()
                }
            }
        } else {
            if let content = rcmessage.file?.content, let url = URL(string: content) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }
}

extension DialogflowView: QBImagePickerControllerDelegate {

    func qb_imagePickerController(_ imagePickerController: QBImagePickerController?, didFinishPickingAssets assets: [Any]?) {
        if let assets = assets {
            for asset in assets {
                if let anAsset = asset as? PHAsset {
                    if anAsset.mediaType == .image || anAsset.mediaType == .video {
                        sendAssets.append(anAsset)
                    }
                }
            }
            showAttachCollection(assets: sendAssets)
        }
        self.updateSendButtonState()

        dismiss(animated: true)
    }

    func qb_imagePickerControllerDidCancel(_ imagePickerController: QBImagePickerController?) {
        print("Canceled.")

        dismiss(animated: true)
    }
}

// MARK: - UIImagePickerControllerDelegate

extension DialogflowView: UIImagePickerControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let chosenImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            sendAssets.append(chosenImage)

            self.updateSendButtonState()

            showAttachCollection(assets: sendAssets)
        }
        picker.dismiss(animated: true)
    }
}

// MARK: - UDImageViewDelegate

extension DialogflowView: UDImageViewDelegate {
    func close() {
        imageVC.view.removeFromSuperview()
        navigationItem.leftBarButtonItem?.isEnabled = true
        navigationItem.leftBarButtonItem?.tintColor = nil
    }
}
