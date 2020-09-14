//
//  UseDeskSDKHelp.swift

import Foundation

class UseDeskSDKHelp {
    class func config_CompanyID(_ companyID: String?, email: String, phone: String?, name: String?, url: String?, token: String?) -> [Any]? {
        let payload = ["sdk": "iOS"]
        var dic: [String: Any] = [
            "type": "@@server/chat/INIT",
            "payload": payload,
            "company_id": companyID ?? "",
            "url": url ?? ""
        ]

        if let token = token {
            dic["token"] = token
        }
        return [dic]
    }

    class func dataEmail(_ email: String?, phone: String?, name: String?) -> [Any]? {
        var dic: [String: Any] = [
            "type": "@@server/chat/SET_EMAIL",
            "email": email ?? ""
        ]
        var payload: [String: Any] = [:]
        if let name = name, name.isEmpty == false {
            payload["name"] = name
        }
        if let phone = phone, phone.isEmpty == false {
            payload["phone"] = phone
        }
        if let email = email, email.isEmpty == false {
            payload["email"] = email
        }
        dic["payload"] = payload
        return [dic]
    }

    class func messageText(_ text: String?) -> [Any]? {
        let message = ["text": text ?? ""]

        let dic: [String: Any] = [
            "type": "@@server/chat/SEND_MESSAGE",
            "message": message
        ]
        return [dic]
    }

    class func feedback(_ fb: Bool) -> [Any]? {

        let data = fb ? "LIKE" : "DISLIKE"

        let payload = [
            "data": data,
            "type": "action"
        ]

        let dic: [String: Any] = [
            "type": "@@server/chat/CALLBACK",
            "payload": payload
        ]
        return [dic]
    }

    class func message(_ text: String?, withFileName fileName: String?, fileType: String?, contentBase64: String?) -> [Any]? {
        let file = [
            "name": fileName ?? "",
            "type": fileType ?? "",
            "content": contentBase64 ?? ""
        ]

        let message: [String: Any] = [
            "text": text ?? "",
            "file": file
        ]

        let dic: [String: Any] = [
            "type": "@@server/chat/SEND_MESSAGE",
            "message": message
        ]
        return [dic]
    }

    class func dict(toJson dict: [AnyHashable: Any]?) -> String? {
        var jsonData: Data?
        if let aDict = dict {
            jsonData = try? JSONSerialization.data(withJSONObject: aDict, options: [])
        }
        if jsonData == nil {
            return "{}"
        } else {
            if let aData = jsonData {
                return String(data: aData, encoding: .utf8)
            }
            return nil
        }
    }

    class func image(toNSString image: UIImage) -> String {
        let imageData: Data = image.pngData()!
        return imageData.base64EncodedString(options: .lineLength64Characters)
    }
}
