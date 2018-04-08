//
//  ReviewSurveyManager.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 3/3/18.
//  Copyright © 2018 Rocket Internet. All rights reserved.
//

import UIKit

@objc class ReviewSurveyManager: NSObject {
    
    private static func presentSurveyOn(viewController: UIViewController, reviewSurvey: ReviewSurvery, orderID: String) {
        if let reviewStarter = ViewControllerManager.sharedInstance().loadViewController("ReviewSurveyStarter", resetCache: true) as? BaseNavigationController, let surveyViewCtrl = reviewStarter.viewControllers.first as? ReviewSurveyViewController {
            surveyViewCtrl.surveryModel = reviewSurvey
            surveyViewCtrl.orderID = orderID
            viewController.present(reviewStarter, animated: true)
        }
    }
    
    
    static func getJourneySurvey(orderID: String) {
        ReviewServiceDataManager.sharedInstance.getServeryAlias(nil, surveyAlias: .journeySurvey, executionType: .background) { (data, error) in
            if let dataDictionary = data as? [String: Any], let content = dataDictionary[DataManagerKeys.DataContent] as? AliasSurvey, let presentingSurvey = content.survey {
                self.startPresentingSurvey(reviewSurvey: presentingSurvey, orderId: orderID)
            } else if let userSurvey = data as? AliasSurvey, let presentingSurvey = userSurvey.survey {
                self.startPresentingSurvey(reviewSurvey: presentingSurvey, orderId: orderID)
            }
        }
    }
    
    static func runSurveyIfItsNeeded(target: DataServiceProtocol, executionType: ApiRequestExecutionType) {
        ReviewServiceDataManager.sharedInstance.getAvaiableUserSurvey(target, executionType: executionType) { (data, error) in
            if let dataDictionary = data as? [String: Any], let content = dataDictionary[DataManagerKeys.DataContent] as? UserSurvey, let presentingSurvey = content.surveys?.first, let orderID = content.orderNumber {
                self.startPresentingSurvey(reviewSurvey: presentingSurvey, orderId: orderID)
            } else if let userSurvey = data as? UserSurvey, let presentingSurvey = userSurvey.surveys?.first, let orderID = userSurvey.orderNumber {
                self.startPresentingSurvey(reviewSurvey: presentingSurvey, orderId: orderID)
            }
        }
    }
    
    static func startPresentingSurvey(reviewSurvey: ReviewSurvery, orderId: String) {
        if let topViewController = MainTabBarViewController.topViewController() {
            self.presentSurveyOn(viewController: topViewController, reviewSurvey: reviewSurvey, orderID: orderId)
        }
    }
}
