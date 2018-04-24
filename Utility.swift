//
//  Utility.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 10/24/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

import UIKit

@objc class Utility: NSObject {

    @discardableResult static func handleErrorMessages(error: Any?, viewController: BaseViewController) -> Bool {
        if viewController.showNotificationBar(error, isSuccess: false) {
            return true
        } else {
            if let error = error as? [Any], error.count > 0, let errorDictionary = error[0] as? [AnyHashable: Any] {
                viewController.showNotificationBar(fromMessageDictionary: errorDictionary, isSuccess: false)
                return true
            } else if let error = error as? [Any], error.count > 0, let errorMessage = error[0] as? String {
                viewController.showNotificationBarMessage(errorMessage, isSuccess: false)
                return true
            }
        }
        return false
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
    
    static func shareUrl(url: String, message: String, viewController: BaseViewController) {
        let textToShare = message
        if let encodeUrl = url.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed),let myWebsite = NSURL(string: encodeUrl) {
            let objectsToShare: [Any] = [textToShare, myWebsite]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            viewController.present(activityVC, animated: true, completion: nil)
        }
    }
    
    static func timeString(seconds:Int, allowedUnits: NSCalendar.Unit) -> String {
        let hours = seconds / 3600
        let minutes = seconds / 60 % 60
        let seconds = seconds % 60
        let hasHour = allowedUnits.contains(.hour)
        let hasMin = allowedUnits.contains(.minute)
        let hasSec = allowedUnits.contains(.second)
        if !hasHour && !hasMin && !hasSec {
            return ""
        } else if !hasHour && hasMin && hasSec {
            return String(format:"%02i:%02i", minutes, seconds)
        } else if !hasHour && !hasMin && hasSec {
            return String(format:"%02i", seconds)
        }
        return String(format:"%02i:%02i:%02i", hours, minutes, seconds)
    }
    
    static func resetUserBehaviours() {
        //Reset some actions
        EmarsysPredictManager.userLoggedOut()
        RICustomer.cleanFromDB()
        RICart.sharedInstance().cartEntity?.cartItems = []
        RICart.sharedInstance().cartEntity?.cartCount = nil
        LocalSearchSuggestion().clearAllHistories()
    }
    
    static func delay (duration: TimeInterval, completion: @escaping ()->() ) {
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            completion()
        }
    }
}