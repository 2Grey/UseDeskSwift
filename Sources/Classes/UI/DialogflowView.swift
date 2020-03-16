//
//  DialogflowView.swift

import Foundation
import UIKit
import QBImagePickerController
import MBProgressHUD
import AVKit

class DialogflowView: RCMessagesView, UINavigationControllerDelegate {

    var rcmessages: [RCMessage] = []
    var isFromBase = false
    
    private var hudErrorConnection: MBProgressHUD?
    private var imageVC: UDImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .reply, target: self, action: #selector(self.actionDone))
        navigationItem.title = usedesk?.config?.nameChat

        let hudErrorConnection = MBProgressHUD(view: view)
        hudErrorConnection.removeFromSuperViewOnHide = true
        hudErrorConnection.mode = MBProgressHUDMode.indeterminate
        view.addSubview(hudErrorConnection)

        self.hudErrorConnection = hudErrorConnection

        //Notification
        NotificationCenter.default.addObserver(self, selector: #selector(self.openUrlFromMessageButton(_:)), name: Notification.Name("messageButtonURLOpen"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.sendMessageButton(_:)), name: Notification.Name("messageButtonSend"), object: nil)
        
        rcmessages = [RCMessage]()
        loadEarlierShow(false)
        
        updateTitleDetails()
        
        guard let usedesk = usedesk else {
            reloadhistory()
            return
        }

        usedesk.connectBlock = { [weak self] success, error in
            guard let wSelf = self else {return}
            wSelf.hudErrorConnection?.hide(animated: true)
            wSelf.reloadhistory()
        }
        
        usedesk.newMessageBlock = { [weak self] success, message in
            guard let wSelf = self else {return}
            if let aMessage = message {
                wSelf.rcmessages.append(aMessage)
            }
            wSelf.refreshTableView1()
//            if message?.incoming != false {
//                UDAudio.playMessageIncoming()
//            }
        }
        
        usedesk.feedbackAnswerMessageBlock = { [weak self] success in
            guard let wSelf = self else {return}

            let alert = UIAlertController(title: "", message: "Спасибо за вашу оценку", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default))
            wSelf.present(alert, animated: true)
        }
        
        usedesk.errorBlock = { [weak self] errors in
            guard let wSelf = self else {return}

            if (errors?.count ?? 0) > 0 {
                wSelf.hudErrorConnection?.label.text = (errors?.first as? String)
            }
            wSelf.hudErrorConnection?.show(animated: true)
        }
        
        usedesk.feedbackMessageBlock = { [weak self] message in
            guard let wSelf = self else {return}

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
        if let usedesk = self.usedesk {
            rcmessages = []
            for message in (usedesk.historyMess) {
                rcmessages.append(message)
            }
            refreshTableView1()
        }
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
        if let urlString = notification.userInfo?["url"] as? String, let url = URL(string: urlString) {
            UIApplication.shared.open(url, options: [:])
        }
    }
    
    @objc func sendMessageButton(_ notification: NSNotification) {
        if let text = notification.userInfo?["text"] as? String {
            usedesk?.sendMessage(text)
        }
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
        } catch {
        }
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
        if action == #selector(self.actionMenuCopy(_:)) {
            return true
        }
        return false
    }
    
    // MARK: - Typing indicator methods
    func typingIndicatorShow(_ show: Bool, animated: Bool, delay: CGFloat) {
        let time = DispatchTime.now() + (Double(delay))
        DispatchQueue.main.asyncAfter(deadline: (time), execute: { [weak self] in
            guard let wSelf = self else {return}
            wSelf.typingIndicatorShow(show, animated: animated)
        })
    }
    
    // MARK: - Title details methods
    func updateTitleDetails() {
        labelTitle1.text = "UseDesk"
        labelTitle2.text = "online now"
    }
    
    // MARK: - Refresh methods
    func refreshTableView1() {
        refreshTableView2()
        scroll(toBottom: true)
    }
    
    func refreshTableView2() {
        tableView.reloadData()
    }
    
    func sendDialogflowRequest(_ text: String?) {
        typingIndicatorShow(true, animated: true, delay: 0.5)
        /*AITextRequest *aiRequest = [apiAI textRequest];
         aiRequest.query = @[text];
         [aiRequest setCompletionBlockSuccess:^(AIRequest *request, id response)
         {
         [self typingIndicatorShow:NO animated:YES delay:1.0];
         [self displayDialogflowResponse:response delay:1.1];
         }
         failure:^(AIRequest *request, NSError *error)
         {
         [ProgressHUD showError:@"Dialogflow request error."];
         }];
         [apiAI enqueue:aiRequest];*/
    }
    
    func displayDialogflowResponse(_ dictionary: [AnyHashable: Any]?, delay: CGFloat) {
        let time = DispatchTime.now() + Double(Double(delay) )
        DispatchQueue.main.asyncAfter(deadline: time, execute: { [weak self] in
            guard let wSelf = self else {return}
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
        for rcmessage in rcmessages {
            if rcmessage.video_path != "" {
                do {
                    try? FileManager().removeItem(atPath: rcmessage.video_path)
                }
            }
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
                        guard let wSelf = self else {return}
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
                imageQueue.async {[weak self] in
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
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
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
        PHPhotoLibrary.requestAuthorization {[weak self] (status) in
            if status == .authorized {
                DispatchQueue.main.async {[weak self] in
                    self?.openPhotoSelector()
                }
            } else {
                DispatchQueue.main.async {[weak self] in
                    let alertController = UIAlertController(title: "Ошибка", message: "Доступ к фотогалерее заблокирован", preferredStyle: UIAlertControllerStyle.alert)
                    alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default))
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
        self.present(imagePickerController, animated: true)
    }

    // MARK: - User actions (menu)
    @objc func actionMenuCopy(_ sender: Any?) {
        let indexPath: IndexPath? = RCMenuItem.indexPath((sender as! UIMenuController))
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

        guard let messageFile = rcmessage.file  else { return }

        if messageFile.type == "image" {
            navigationItem.leftBarButtonItem?.isEnabled = false
            navigationItem.leftBarButtonItem?.tintColor = .clear

            if let cell = tableView.cellForRow(at: indexPath) as? RCPictureMessageCell {
                rcmessage.status = RCStatus.openimage
                cell.bindData(indexPath, messagesView: self)
            }

            imageVC = UDImageView(nibName: "UDImageView", bundle: nil)
            self.addChildViewController(self.imageVC)
            self.view.addSubview(self.imageVC.view)
            imageVC.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
            imageVC.delegate = self

            let session = URLSession.shared
            if let url = URL(string: messageFile.content) {
                session.dataTask(with: url, completionHandler: { data, _, error in
                    if error == nil {
                        DispatchQueue.main.async(execute: { [weak self] in
                            guard let wSelf = self else {return}
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
        buttonInputSend.isEnabled = true

        dismiss(animated: true)
    }

    func qb_imagePickerControllerDidCancel(_ imagePickerController: QBImagePickerController?) {
        print("Canceled.")

        dismiss(animated: true)
    }
}

extension DialogflowView: UIImagePickerControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any]) {
        if let chosenImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            sendAssets.append(chosenImage)

            buttonInputSend.isEnabled = true

            showAttachCollection(assets: sendAssets)
        }
        picker.dismiss(animated: true)
    }
}

extension DialogflowView: UDImageViewDelegate {
    func close() {
        imageVC.view.removeFromSuperview()
        navigationItem.leftBarButtonItem?.isEnabled = true
        navigationItem.leftBarButtonItem?.tintColor = nil
    }
    
}
