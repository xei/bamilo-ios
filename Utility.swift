//
//  Utility.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 10/24/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

import UIKit
import Adjust

@objcMembers class Utility: NSObject {

    @discardableResult class func handleErrorMessages(error: Any?, viewController: BaseViewController) -> Bool {
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
    
    class func formatScoreValue(score: Double) -> String {
        let isInteger = floor(score) == score
        return "\(isInteger ? "\(Int(score))" : "\(score)")".convertTo(language: .arabic).persianDoubleFormat()
    }
    
    class func openExternalUrlOnBrowser(urlString: String) {
        let validUrlString = urlString.contains("http") ? urlString : "http://\(urlString)"
        guard let url = URL(string: validUrlString) else {
            return
        }
        
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
    
    class func shareUrl(url: String, message: String, viewController: BaseViewController) {
        let textToShare = message
        if let encodeUrl = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),let myWebsite = NSURL(string: encodeUrl) {
            let objectsToShare: [Any] = ["\(textToShare)", myWebsite]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            viewController.present(activityVC, animated: true, completion: nil)
        }
    }
    
    class func timeString(seconds:Int, allowedUnits: NSCalendar.Unit) -> String {
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
    
    class func resetUserBehaviours() {
        //Reset some actions
//        EmarsysPredictManager.userLoggedOut()
        CurrentUserManager.cleanFromDB()
        RICart.sharedInstance().cartEntity?.cartItems = []
        RICart.sharedInstance().cartEntity?.cartCount = nil
        LocalSearchSuggestion().clearAllHistories()
    }
    
    class func delay (duration: TimeInterval, completion: @escaping ()->() ) {
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            completion()
        }
    }
    
    class func createModalBounceAnimator(viewCtrl: UIViewController) -> ZFModalTransitionAnimator? {
        let animator = ZFModalTransitionAnimator(modalViewController: viewCtrl)
        animator?.isDragable = true
        animator?.bounces = true
        animator?.behindViewAlpha = 0.8
        animator?.behindViewScale = 1.0
        animator?.transitionDuration = 0.7
        animator?.direction = .bottom
        viewCtrl.modalPresentationStyle = .overCurrentContext
        return animator
    }
}
