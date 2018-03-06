//
//  ReviewSurveyManager.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 3/3/18.
//  Copyright © 2018 Rocket Internet. All rights reserved.
//

import UIKit

class ReviewSurveyManager: NSObject {
    static func startSurvey(viewController: UIViewController) {
        
        if let reviewStarter = ViewControllerManager.sharedInstance().loadViewController("Review", nibName: "surveyStarterViewController", resetCache: true) {
            viewController.present(reviewStarter, animated: true)
        }
    }
}
