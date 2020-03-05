//
//  UDFileManager.swift
//  UseDesk_SDK_Swift
//

import UIKit
import Alamofire
import Photos

class UDFileManager: NSObject {
    
    class func downloadFile(indexPath: IndexPath, urlPath: String, successBlock: @escaping (IndexPath, URL)->(), errorBlock: (_ error: String) -> Void) {
        if let url = URL(string: urlPath) {
            let destination = DownloadRequest.suggestedDownloadDestination(for: .documentDirectory)
            
            Alamofire.download(url, to: destination).responseData { response in
                if let destinationUrl = response.destinationURL {
                    successBlock(indexPath, destinationUrl)
                }
            }
        }
    }
    
    class func videoPreview(filePath: String) -> UIImage {
        let vidURL = URL(fileURLWithPath: filePath)
        let asset = AVURLAsset(url: vidURL)
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true

        let timestamp = CMTime(seconds: 0, preferredTimescale: 60)

        do {
            let imageRef = try generator.copyCGImage(at: timestamp, actualTime: nil)
            return UIImage(cgImage: imageRef)
        } catch {
            return UIImage()
        }
    }
    
    func timeStringFor(seconds: Int) -> String {
      let formatter = DateComponentsFormatter()
      formatter.allowedUnits = [.second, .minute, .hour]
      formatter.zeroFormattingBehavior = .pad

      return formatter.string(from: TimeInterval(seconds))!
    }

}
