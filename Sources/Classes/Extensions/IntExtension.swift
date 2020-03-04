//
//  IntExtension.swift
//  Alamofire
//

import UIKit

extension Double {
    
    func timeStringFor(seconds : Int) -> String {
      let formatter = DateComponentsFormatter()
      formatter.allowedUnits = [.second, .minute, .hour]
      formatter.zeroFormattingBehavior = .pad

      return formatter.string(from: TimeInterval(seconds))!
    }
}
