//
//  Utility.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 10/24/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

import UIKit

@objc class Utility: NSObject {
    
    static func handleError(error: Any?, viewController: BaseViewController) {
        if !viewController.showNotificationBar(error, isSuccess: false) {
            if let error = error as? [Any], error.count > 0, let errorDictionary = error[0] as? [AnyHashable: Any] {
                viewController.showNotificationBar(fromMessageDictionary: errorDictionary, isSuccess: false)
            } else if let error = error as? [Any], error.count > 0, let errorMessage = error[0] as? String {
                viewController.showNotificationBarMessage(errorMessage, isSuccess: false)
            }
        }
    }
    
    static func openExternalUrlOnBrowser(urlString: String) {
        guard let url = URL(string: urlString) else {
            return
        }
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
}
