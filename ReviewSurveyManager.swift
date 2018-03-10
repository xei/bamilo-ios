//
//  ReviewSurveyManager.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 3/3/18.
//  Copyright © 2018 Rocket Internet. All rights reserved.
//

import UIKit

class ReviewSurveyManager: NSObject {
    private static func startSurvey(viewController: UIViewController, reviewSurvey: ReviewSurvery) {
        if let reviewStarter = ViewControllerManager.sharedInstance().loadViewController("ReviewSurveyStarter", resetCache: true) as? ReviewSurveyViewController {
            viewController.present(reviewStarter, animated: true)
            reviewStarter.updateView(by: reviewSurvey)
        }
    }
    
    static func runSurveyIfItsNeeded(target: DataServiceProtocol, executionType: ApiRequestExecutionType) {
        ReviewServiceDataManager.sharedInstance.getAvaiableUserSurvey(target, executionType: executionType) { (data, error) in
            if let userSurvey = data as? UserSurvey {
                if let topViewController = MainTabBarViewController.topViewController(), let presentingSurvey = userSurvey.surveys?.first {
                    self.startSurvey(viewController: topViewController, reviewSurvey: presentingSurvey)
                }
            }
        }
    }
}
