//
//  UseDeskSDK.swift

import Foundation
import SocketIO
import SVProgressHUD
import Alamofire
import UserNotifications

public typealias UDSStartBlock = (Bool, String?) -> Void
public typealias UDSBaseBlock = (Bool, [BaseCollection]?, String?) -> Void
public typealias UDSArticleBlock = (Bool, Article?, String?) -> Void
public typealias UDSArticleSearchBlock = (Bool, SearchArticle?, String?) -> Void
public typealias UDSConnectBlock = (Bool, String?) -> Void
public typealias UDSDisconnectBlock = ([Any]?) -> Void
public typealias UDSNewMessageBlock = (Bool, RCMessage?) -> Void
public typealias UDSErrorBlock = ([Any]?) -> Void
public typealias UDSFeedbackMessageBlock = (RCMessage?) -> Void
public typealias UDSFeedbackAnswerMessageBlock = (Bool) -> Void
public typealias UDCloseBlock = () -> Void

@objcMembers
public class UseDeskSDK: NSObject {
    @objc public var newMessageBlock: UDSNewMessageBlock?
    @objc public var connectBlock: UDSConnectBlock?
    @objc public var disconnectBlock: UDSDisconnectBlock?
    @objc public var errorBlock: UDSErrorBlock?
    @objc public var closeBlock: UDCloseBlock?
    @objc public var feedbackMessageBlock: UDSFeedbackMessageBlock?
    @objc public var feedbackAnswerMessageBlock: UDSFeedbackAnswerMessageBlock?
    @objc public var historyMess: [RCMessage] = []

    public private(set) var config: UDSDKConfig?

    var manager: SocketManager?
    var socket: SocketIOClient?

    var token: String?

    // MARK: - UI/UX

    @objc public func configureUI(configurator: (_ messages: RCMessages) -> Void) {
        configurator(RCMessages.shared)
    }

    // MARK: - Start

    @objc public func start(with config: UDSDKConfig, on viewController: UIViewController, startBlock: @escaping UDSStartBlock) {
        self.config = config

        SVProgressHUD.show(withStatus: "Загрузка")

        if let nameChat = config.nameChat, nameChat.isEmpty == false {
            self.config?.nameChat = nameChat
        } else {
            self.config?.nameChat = "Онлайн-чат"
        }

        if config.isUseBase, config.accountId != nil {
            let baseView = UDBaseView()
            baseView.usedesk = self
            baseView.url = config.urlWithPort

            let navController = UDNavigationController(rootViewController: baseView)
            navController.setTitleTextAttributes()
            navController.modalPresentationStyle = .fullScreen
            navController.onDissmis = { [weak self] in
                self?.closeBlock?()
            }

            viewController.present(navController, animated: true)
            SVProgressHUD.dismiss()
        } else {
            if config.isUseBase, config.accountId == nil {
                startBlock(false, "You did not specify account_id")
            } else {

                self.startWithoutGUICompanyID(with: config) { [weak self] success, error in
                    guard let wSelf = self else { return }

                    if success {
                        let dialogflowVC = DialogflowView()
                        dialogflowVC.usedesk = wSelf

                        let navController = UDNavigationController(rootViewController: dialogflowVC)
                        navController.setTitleTextAttributes()
                        navController.modalPresentationStyle = .fullScreen
                        navController.onDissmis = { [weak self] in
                            self?.closeBlock?()
                        }

                        viewController.present(navController, animated: true)
                        SVProgressHUD.dismiss()
                    } else {
                        if error == "noOperators" {
                            let offlineVC = UDOfflineForm(nibName: "UDOfflineForm", bundle: nil)
                            offlineVC.url = config.urlWithPort
                            offlineVC.usedesk = wSelf
                            let navController = UDNavigationController(rootViewController: offlineVC)
                            navController.modalPresentationStyle = .fullScreen
                            navController.onDissmis = { [weak self] in
                                self?.closeBlock?()
                            }

                            viewController.present(navController, animated: true)
                            SVProgressHUD.dismiss()
                        }
                    }
                }
            }
        }
    }

    @objc public func startWithoutGUICompanyID(with config: UDSDKConfig, startBlock: @escaping UDSStartBlock) {
        self.config = config

        if let nameChat = config.nameChat, nameChat.isEmpty == false {
            self.config?.nameChat = nameChat
        } else {
            self.config?.nameChat = "Онлайн-чат"
        }

        let socketConfig = ["log": true]

        guard let urlAddress = URL(string: config.url) else { return }

        self.manager = SocketManager(socketURL: urlAddress, config: socketConfig)
        self.socket = manager?.defaultSocket
        socket?.connect()

        socket?.on("connect", callback: { [weak self, weak config] data, ack in
            guard let wConfig = config else { return }
            guard let wSelf = self else { return }

            print("socket connected")

            let token = wSelf.loadToken(for: wConfig.email)
            let arrConfStart = UseDeskSDKHelp.config_CompanyID(wConfig.companyId, email: wConfig.email, phone: wConfig.phone, name: wConfig.name, url: wConfig.url, token: token)
            wSelf.socket?.emit("dispatch", with: arrConfStart!)
        })

        socket?.on("error", callback: { [weak self] data, ack in
            guard let wSelf = self else { return }
            
            let socketStatus = wSelf.socket?.status ?? SocketIOStatus.notConnected
            if socketStatus == SocketIOStatus.connected || socketStatus == SocketIOStatus.connecting {
                wSelf.errorBlock?(data)
            }
        })

        socket?.on("disconnect", callback: { [weak self, weak config] data, ack in
            guard let wConfig = config else { return }
            guard let wSelf = self else { return }

            print("socket disconnect")

            wSelf.disconnectBlock?(data)

            let token = wSelf.loadToken(for: wConfig.email)
            let arrConfStart = UseDeskSDKHelp.config_CompanyID(wConfig.companyId, email: wConfig.email, phone: wConfig.phone, name: wConfig.name, url: wConfig.url, token: token)
            wSelf.socket?.emit("dispatch", with: arrConfStart!)
        })

        socket?.on("dispatch", callback: { [weak self] data, ack in
            guard let wSelf = self else { return }
            guard data.count > 0 else { return }

            wSelf.action_INITED(data)

            let no_operators = wSelf.action_INITED_no_operators(data)

            if no_operators {
                startBlock(false, "noOperators")
            } else {

                let auth_success = wSelf.action_ADD_INIT(data)

                if auth_success {
                    startBlock(auth_success, "")
                } else {
                    startBlock(auth_success, "false inited")
                }

                if auth_success {
                    wSelf.connectBlock?(true, nil)
                }

                wSelf.action_Feedback_Answer(data)

                wSelf.action_ADD_MESSAGE(data)
            }
        })
    }

    @objc public func releaseChat() {
        socket = manager?.defaultSocket
        socket?.disconnect()
    }

    // MARK: - Send

    @objc public func sendMessage(_ text: String?) {
        let mess = UseDeskSDKHelp.messageText(text)
        socket?.emit("dispatch", with: mess!)
    }

    @objc public func sendMessage(_ text: String?, withFileName fileName: String?, fileType: String?, contentBase64: String?) {
        let mess = UseDeskSDKHelp.message(text, withFileName: fileName, fileType: fileType, contentBase64: contentBase64)
        socket?.emit("dispatch", with: mess!)
    }

    @objc public func sendMessageFeedBack(_ status: Bool) {
        socket?.emit("dispatch", with: UseDeskSDKHelp.feedback(status)!)
    }

    func sendOfflineForm(withMessage message: String?, callback resultBlock: @escaping UDSStartBlock) {
        var param: [String: String] = [:]

        if let companyId = self.config?.companyId { param["company_id"] = companyId }
        if let name = self.config?.name { param["name"] = name }
        if let email = self.config?.email { param["email"] = email }
        if let message = message { param["message"] = message }

        DispatchQueue.global(qos: .default).async(execute: {
            let urlStr = "https://secure.usedesk.ru/widget.js/post"
            request(urlStr, method: .post, parameters: param as Parameters).responseJSON { responseJSON in
                switch responseJSON.result {
                case .success:
                    resultBlock(true, nil)
                case .failure(let error):
                    resultBlock(false, error.localizedDescription)
                }
            }
        })
    }

    // MARK: * Article

    @objc public func getArticle(articleID: Int, connectionStatus baseBlock: @escaping UDSArticleBlock) {
        guard let config = self.config else {
            baseBlock(false, nil, "UseDeskSDK config isn't set")
            return
        }

        if config.isUseBase, let accountId = config.accountId, accountId.isEmpty == false {
            DispatchQueue.global(qos: .default).async(execute: {
                request("https://api.usedesk.ru/support/\(accountId)/articles/\(articleID)?api_token=\(config.apiToken)").responseJSON { responseJSON in
                    switch responseJSON.result {
                    case .success(let value):
                        guard let article = Article.get(from: value) else {
                            baseBlock(false, nil, "error parsing")
                            return
                        }
                        baseBlock(true, article, "")
                    case .failure(let error):
                        baseBlock(false, nil, error.localizedDescription)
                    }
                }
            })
        } else {
            if config.isUseBase, config.accountId == nil || config.accountId?.isEmpty == true {
                baseBlock(false, nil, "You did not specify account_id")
            } else {
                baseBlock(false, nil, "You specify isUseBase = false")
            }
        }
    }

    @objc public func addViewsArticle(articleID: Int, count: Int, connectionStatus connectBlock: @escaping UDSConnectBlock) {
        guard let config = self.config else {
            connectBlock(false, "UseDeskSDK config isn't set")
            return
        }

        if config.isUseBase, let accountId = config.accountId, accountId.isEmpty == false {
            DispatchQueue.global(qos: .default).async(execute: {
                request("https://api.usedesk.ru/support/\(accountId)/articles/\(articleID)/add-views?api_token=\(config.apiToken)&count=\(count)").responseJSON { responseJSON in
                    switch responseJSON.result {
                    case .success:
                        connectBlock(true, "")
                    case .failure(let error):
                        connectBlock(false, error.localizedDescription)
                    }
                }
            })
        } else {
            if config.isUseBase, config.accountId == nil || config.accountId?.isEmpty == true {
                connectBlock(false, "You did not specify account_id")
            } else {
                connectBlock(false, "You specify isUseBase = false")
            }
        }
    }

    @objc public func getSearchArticles(collection_ids: [Int],
                                        category_ids: [Int],
                                        article_ids: [Int],
                                        count: Int = 20,
                                        page: Int = 1,
                                        query: String,
                                        type: TypeArticle = .all,
                                        sort: SortArticle = .id,
                                        order: OrderArticle = .asc,
                                        connectionStatus searchBlock: @escaping UDSArticleSearchBlock)
    {
        guard let config = self.config else {
            searchBlock(false, nil, "UseDeskSDK config isn't set")
            return
        }

        if config.isUseBase, let accountId = config.accountId, accountId.isEmpty == false {
            var url = "https://api.usedesk.ru/support/\(accountId)/articles/list?api_token=\(config.apiToken)"
            var urlForEncode = "&query=\(query)&count=\(count)&page=\(page)"

            switch type {
            case .close:
                urlForEncode += "&type=public"
            case .open:
                urlForEncode += "&type=private"
            default:
                break
            }

            switch sort {
            case .id:
                urlForEncode += "&sort=id"
            case .category_id:
                urlForEncode += "&sort=category_id"
            case .created_at:
                urlForEncode += "&sort=created_at"
            case .open:
                urlForEncode += "&sort=public"
            case .title:
                urlForEncode += "&sort=title"
            default:
                break
            }

            switch order {
            case .asc:
                urlForEncode += "&order=asc"
            case .desc:
                urlForEncode += "&order=desc"
            default:
                break
            }

            if collection_ids.count > 0 {
                var idsStrings = ""
                urlForEncode += "&collection_ids="
                for id in collection_ids {
                    if idsStrings == "" {
                        idsStrings += "\(id)"
                    } else {
                        idsStrings += ",\(id)"
                    }
                }
                urlForEncode += idsStrings
            }
            if category_ids.count > 0 {
                var idsStrings = ""
                urlForEncode += "&category_ids="
                for id in category_ids {
                    if idsStrings == "" {
                        idsStrings += "\(id)"
                    } else {
                        idsStrings += ",\(id)"
                    }
                }
                urlForEncode += idsStrings
            }
            if article_ids.count > 0 {
                var idsStrings = ""
                urlForEncode += "&article_ids="
                for id in article_ids {
                    if idsStrings == "" {
                        idsStrings += "\(id)"
                    } else {
                        idsStrings += ",\(id)"
                    }
                }
                urlForEncode += idsStrings
            }

            let escapedUrl = urlForEncode.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
            url += escapedUrl ?? ""

            DispatchQueue.global(qos: .default).async(execute: {
                request(url).responseJSON { responseJSON in
                    switch responseJSON.result {
                    case .success(let value):
                        guard let articles = SearchArticle(from: value) else {
                            searchBlock(false, nil, "error parsing")
                            return
                        }
                        searchBlock(true, articles, "")
                    case .failure(let error):
                        searchBlock(false, nil, error.localizedDescription)
                    }
                }
            })
        } else {
            if config.isUseBase, config.accountId == nil || config.accountId?.isEmpty == true {
                searchBlock(false, nil, "You did not specify account_id")
            } else {
                searchBlock(false, nil, "You specify isUseBase = false")
            }
        }
    }

    // MARK: * Collections

    @objc public func getCollections(connectionStatus baseBlock: @escaping UDSBaseBlock) {
        guard let config = self.config else {
            baseBlock(false, nil, "UseDeskSDK config isn't set")
            return
        }

        if config.isUseBase, let accountId = config.accountId, accountId.isEmpty == false {
            DispatchQueue.global(qos: .default).async(execute: {
                request("https://api.usedesk.ru/support/\(accountId)/list?api_token=\(config.apiToken)").responseJSON { responseJSON in
                    switch responseJSON.result {
                    case .success(let value):
                        guard let collections = BaseCollection.getArray(from: value) else {
                            baseBlock(false, nil, "error parsing")
                            return
                        }
                        baseBlock(true, collections, "")
                    case .failure(let error):
                        baseBlock(false, nil, error.localizedDescription)
                    }
                }
            })
        } else {
            if config.isUseBase, config.accountId == nil || config.accountId?.isEmpty == true {
                baseBlock(false, nil, "You did not specify account_id")
            } else {
                baseBlock(false, nil, "You specify isUseBase = false")
            }
        }
    }

    // MARK: * Parse

    func parseMessageDic(_ mess: [AnyHashable: Any]?) -> RCMessage? {
        let m = RCMessage(text: "", incoming: false)

        let createdAt = mess?["createdAt"] as! String
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ru")
        dateFormatter.timeZone = TimeZone(identifier: "Europe/Moscow")
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        if dateFormatter.date(from: createdAt) == nil {
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        }
        m.date = dateFormatter.date(from: createdAt)!

        m.messageId = Int(mess?["id"] as! Int)
        m.incoming = (mess?["type"] as! String == "operator_to_client" || mess?["type"] as! String == "bot_to_client") ? true : false
        m.outgoing = !m.incoming
        m.text = mess?["text"] as! String

        if m.incoming {
            let stringsFromButtons = parseMessageFromButtons(text: m.text)
            for stringFromButton in stringsFromButtons {
                let rsButton = buttonFromString(stringButton: stringFromButton)
                if let rsButton = rsButton {
                    m.rcButtons.append(rsButton)
                }
                m.text = m.text.replacingOccurrences(of: stringFromButton, with: "")
            }
            for index in 0..<m.rcButtons.count {
                let invertIndex = (m.rcButtons.count - 1) - index
                if m.rcButtons[invertIndex].visible {
                    m.text = m.rcButtons[invertIndex].title + " " + m.text
                }
            }
            m.name = mess?["name"] as! String
        }

        let payload = mess?["payload"] // as? [AnyHashable : Any]

        if payload != nil, payload is [AnyHashable: Any] {
            let payload1 = mess?["payload"] as! [AnyHashable: Any]
            let avatar = payload1["avatar"]
            if avatar != nil {
                m.avatar = payload1["avatar"] as! String
            }
        }

        let fileDic = mess?["file"] as? [AnyHashable: Any]
        if fileDic != nil {
            let file = RCFile()
            file.content = fileDic?["content"] as! String
            file.name = fileDic?["name"] as! String
            file.type = fileDic?["type"] as! String
            m.file = file
            m.status = RCStatus.loading
            if (file.type == "image/png") || file.name.contains(".png") {
                m.type = RCType.picture
                do {
                    if URL(string: file.content) != nil {
                        let aContent = URL(string: file.content)
                        let aContent1 = try Data(contentsOf: aContent!)
                        m.picture_image = UIImage(data: aContent1)
                    }
                } catch {}
            } else if file.type.contains("video/") || file.name.contains(".mp4") {
                m.type = RCType.video
                file.type = "video"
            }

            m.picture_width = Int(0.6 * SCREEN_WIDTH)
            m.picture_height = Int(0.6 * SCREEN_WIDTH)
        }

        if let payload = payload as? [AnyHashable: Any], payload["csi"] != nil {
            m.feedback = true
            m.type = RCType.feedback
        }

        return m
    }

    func parseMessageFromButtons(text: String) -> [String] {
        var isAddingButton: Bool = false
        var characterArrayFromRCButton = [Character]()
        var stringsFromRCButton = [String]()
        if text.count > 2 {
            for index in 0..<text.count - 1 {
                let indexString = text.index(text.startIndex, offsetBy: index)
                let secondIndexString = text.index(text.startIndex, offsetBy: index + 1)
                if isAddingButton {
                    characterArrayFromRCButton.append(text[indexString])
                    if text[indexString] == "}", text[secondIndexString] == "}" {
                        characterArrayFromRCButton.append(text[secondIndexString])
                        isAddingButton = false
                        stringsFromRCButton.append(String(characterArrayFromRCButton))
                        characterArrayFromRCButton = []
                    }
                } else {
                    if text[indexString] == "{", text[secondIndexString] == "{" {
                        characterArrayFromRCButton.append(text[indexString])
                        isAddingButton = true
                    }
                }
            }
        }
        return stringsFromRCButton
    }

    // MARK: * Action

    func action_INITED(_ data: [Any]?) {
        guard let dicServer = data?.first as? [AnyHashable: Any] else { return }

        if let token = dicServer["token"] as? String {
            self.token = token
            save(self.config?.email, token: token)
        }

        if let setup = dicServer["setup"] as? [AnyHashable: Any] {
            historyMess = [RCMessage]()

            if let messages = setup["messages"] as? [Any] {
                for message in messages {
                    if let m = parseMessageDic(message as? [AnyHashable: Any]) {
                        historyMess.append(m)
                    }
                }
            }
            if let deskHelp = UseDeskSDKHelp.dataEmail(self.config?.email, phone: self.config?.phone, name: self.config?.name) {
                socket?.emit("dispatch", with: deskHelp)
            } else {
                print("[\(#file)] - (\(#function)): Error creating UseDeskSDKHelp.dataEmail")
            }
        }
    }

    func action_INITED_no_operators(_ data: [Any]?) -> Bool {
        guard let dicServer = data?.first as? [AnyHashable: Any] else { return false }

        if let token = dicServer["token"] as? String {
            self.token = token
        }

        if let setup = dicServer["setup"] as? [AnyHashable: Any] {
            let noOperators = setup["noOperators"]
            return noOperators != nil
        }

        return false
    }

    func action_ADD_INIT(_ data: [Any]?) -> Bool {
        guard let dicServer = data?.first as? [AnyHashable: Any] else { return false }
        guard let type = dicServer["type"] as? String else { return false }

        return type == "@@chat/current/INITED"
    }

    func action_Feedback_Answer(_ data: [Any]?) {
        guard let dicServer = data?.first as? [AnyHashable: Any] else { return }
        guard let type = dicServer["type"] as? String, type == "@@chat/current/CALLBACK_ANSWER" else { return }

        if let answer = dicServer["answer"] as? [AnyHashable: Any], let status = answer["status"] as? Bool {
            feedbackAnswerMessageBlock?(status)
        }
    }

    func action_ADD_MESSAGE(_ data: [Any]?) {
        guard let dicServer = data?.first as? [AnyHashable: Any] else { return }
        guard let type = dicServer["type"] as? String else { return }

        if !(type == "@@chat/current/ADD_MESSAGE") {
            // return
        }

        if type == "bot_to_client" {}

        if let message = dicServer["message"] as? [AnyHashable: Any] {
            if message["chat"] is NSNull { return }

            let mess = parseMessageDic(message) as RCMessage?

            if mess?.feedback != nil {
                feedbackMessageBlock?(mess)
            } else {
                newMessageBlock?(true, mess)
            }
        }
    }

    func save(_ email: String?, token: String?) {
        UserDefaults.standard.set(token, forKey: email ?? "")
        UserDefaults.standard.synchronize()
    }

    func loadToken(for email: String?) -> String? {
        return UserDefaults.standard.string(forKey: email ?? "")
    }

    // MARK: - HUD

    public func cancel(on viewController: UIViewController) {
        self.releaseChat()
        SVProgressHUD.dismiss()
    }

    // MARK: - Helpers

    func buttonFromString(stringButton: String) -> RCMessageButton? {
        var stringsParameters: [String] = []
        var charactersFromParameter: [Character] = []
        var index = 9
        var isNameExists = true

        while index < stringButton.count - 2, isNameExists {
            let indexString = stringButton.index(stringButton.startIndex, offsetBy: index)
            if stringButton[indexString] != ";" {
                charactersFromParameter.append(stringButton[indexString])
                index += 1
            } else {
                // если первый параметр(имя) будет равно "" то не создавать кнопку
                if stringsParameters.isEmpty, charactersFromParameter.isEmpty {
                    isNameExists = false
                } else {
                    stringsParameters.append(String(charactersFromParameter))
                    charactersFromParameter = []
                    index += 1
                }
            }
        }

        if isNameExists, stringsParameters.count == 3 {
            stringsParameters.append(String(charactersFromParameter))

            let rcButton = RCMessageButton()
            rcButton.title = stringsParameters[0]
            rcButton.url = stringsParameters[1]
            if stringsParameters[3] == "show" {
                rcButton.visible = true
            } else {
                rcButton.visible = false
            }
            return rcButton
        } else {
            return nil
        }
    }
}
