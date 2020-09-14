//
//  UDSDKConfig.swift
//  Classes
//
//  Created by Sergey Ryazanov on 03.03.2020.
//

import Foundation

public class UDSDKConfig {

    public let url: String
    public let port: String
    public let apiToken: String
    public let companyId: String
    public let email: String

    public var accountId: String?
    public let isUseBase: Bool

    public var phone: String?
    public var name: String?
    public var nameChat: String?

    public init(url: String, port: String, apiToken: String, companyId: String, email: String, isUseBase: Bool) {
        self.url = url
        self.port = port
        self.apiToken = apiToken
        self.companyId = companyId
        self.email = email
        self.isUseBase = isUseBase
    }

    public var urlWithPort: String {
        return "\(url):\(port)"
    }
}
