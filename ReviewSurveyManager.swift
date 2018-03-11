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
        if let reviewStarter = ViewControllerManager.sharedInstance().loadViewController("ReviewSurveyStarter", resetCache: true) as? BaseNavigationController, let surveyViewCtrl = reviewStarter.viewControllers.first as? ReviewSurveyViewController {
            viewController.present(reviewStarter, animated: true)
            surveyViewCtrl.surverModel = reviewSurvey
        }
    }
    
    static func runSurveyIfItsNeeded(target: DataServiceProtocol, executionType: ApiRequestExecutionType) {
//        ReviewServiceDataManager.sharedInstance.getAvaiableUserSurvey(target, executionType: executionType) { (data, error) in
//            if let userSurvey = data as? UserSurvey {
                if let topViewController = MainTabBarViewController.topViewController(), let presentingSurvey = self.mockApi().surveys?.first {
                    self.startSurvey(viewController: topViewController, reviewSurvey: presentingSurvey)
                }
//            }
//        }
    }
    
    
    private static func mockApi() -> UserSurvey {
        //mock
        let userSurvey = UserSurvey()
        let review = ReviewSurvery()
        let question = SurveyQuestion()
        let option = SurveyQuestionOption()
        option.title = "what"
        option.id = 123
        option.image = URL(string:"http://www.emoji.com/wordpress/wp-content/uploads/emoji_celebs_146-1.jpg")
        question.title = "what the fuck"
        
        
        let option1 = SurveyQuestionOption()
        option1.title = "what1"
        option1.id = 1233
        option1.image = URL(string:"http://www.emoji.com/wordpress/wp-content/uploads/emoji_celebs_146-1.jpg")
        
        let option2 = SurveyQuestionOption()
        option2.title = "what2"
        option2.id = 1234
        option2.image = URL(string:"http://www.emoji.com/wordpress/wp-content/uploads/emoji_celebs_146-1.jpg")
        
        let option3 = SurveyQuestionOption()
        option3.title = "what3"
        option3.id = 1235
        option3.image = URL(string:"http://www.emoji.com/wordpress/wp-content/uploads/emoji_celebs_146-1.jpg")
        
        let option4 = SurveyQuestionOption()
        option4.title = "what4"
        option4.id = 1236
        option4.image = URL(string:"http://www.emoji.com/wordpress/wp-content/uploads/emoji_celebs_146-1.jpg")
        
        question.options = [option, option1, option2, option3, option4]
        
        question.type = .imageSelect
        
        
        let question1 = SurveyQuestion()
        
        let option11 = SurveyQuestionOption()
        option11.title = "1"
        option11.id = 123
        option11.image = URL(string:"http://www.emoji.com/wordpress/wp-content/uploads/emoji_celebs_146-1.jpg")
        question1.title = "what the fuck"
        
        
        let option12 = SurveyQuestionOption()
        option12.title = "2"
        option12.id = 1233
        option12.image = URL(string:"http://www.emoji.com/wordpress/wp-content/uploads/emoji_celebs_146-1.jpg")
        
        let option13 = SurveyQuestionOption()
        option13.title = "3"
        option13.id = 1234
        option13.image = URL(string:"http://www.emoji.com/wordpress/wp-content/uploads/emoji_celebs_146-1.jpg")
        
        let option14 = SurveyQuestionOption()
        option14.title = "4"
        option14.id = 1235
        option14.image = URL(string:"http://www.emoji.com/wordpress/wp-content/uploads/emoji_celebs_146-1.jpg")
        
        let option15 = SurveyQuestionOption()
        option15.title = "5"
        option15.id = 1236
        option15.image = URL(string:"http://www.emoji.com/wordpress/wp-content/uploads/emoji_celebs_146-1.jpg")
        
        question1.options = [option11, option12, option13, option13, option14, option15]
        
        question1.type = .nps
        
        review.page = [SurveyQuestionPage()]
        review.page?.first?.questions = [question, question1, question, question1, question]
        //end of mock
        userSurvey.surveys = [review]
        userSurvey.orderNumber = "2"
        
        return userSurvey
    }
}
