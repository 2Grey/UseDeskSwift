//
//  Bundle+Extension.swift
//  Classes
//
//  Created by Sergey Ryazanov on 05.03.2020.
//

import Foundation

public extension Bundle {

    var thisBundle: Bundle {
        let podBundle = Bundle(for: type(of: self))
        guard let bundleURL = podBundle.url(forResource: "UseDesk_SDK_Swift", withExtension: "bundle") else {
            return podBundle
        }
        return Bundle(url: bundleURL) ?? Bundle.main
    }
}
