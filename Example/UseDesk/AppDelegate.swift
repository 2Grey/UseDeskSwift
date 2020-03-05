//
//  AppDelegate.swift
//  UseDesk_Example

import UIKit
import UseDesk_SDK_Swift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        window = UIWindow(frame: UIScreen.main.bounds)

        let startViewController = UDStartViewController(nibName: "UDStartViewController", bundle: nil)
        window?.rootViewController = UINavigationController(rootViewController: startViewController)
        window?.makeKeyAndVisible()

        return true
    }
}
