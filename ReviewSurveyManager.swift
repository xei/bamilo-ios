//
//  ReviewSurveyManager.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 3/3/18.
//  Copyright © 2018 Rocket Internet. All rights reserved.
//

import UIKit

@objcMembers class ReviewSurveyManager: NSObject {
    
    private class func presentSurveyOn(reviewSurvey: ReviewSurvery, orderID: String) {
        //If we are not going to present any deeplink actions
        if DeepLinkManager.hasSomethingToShow() { return }
        ThreadManager.execute {
            if let reviewStarter = ViewControllerManager.sharedInstance().loadViewController("ReviewSurveyStarter", resetCache: true) as? BaseNavigationController, let surveyViewCtrl = reviewStarter.viewControllers.first as? ReviewSurveyViewController {
                surveyViewCtrl.surveryModel = reviewSurvey
                surveyViewCtrl.orderID = orderID
                MainTabBarViewController.sharedInstance()?.present(reviewStarter, animated: true)
            }
        }
    }
    
    class func getJourneySurvey(orderID: String) {
        ReviewServiceDataManager.sharedInstance.getServeryAlias(nil, surveyAlias: .journeySurvey, executionType: .background) { (data, error) in
            if let dataDictionary = data as? [String: Any], let content = dataDictionary[DataManagerKeys.DataContent] as? AliasSurvey, let presentingSurvey = content.survey {
                self.startPresentingSurvey(reviewSurvey: presentingSurvey, orderId: orderID)
            } else if let userSurvey = data as? AliasSurvey, let presentingSurvey = userSurvey.survey {
                self.startPresentingSurvey(reviewSurvey: presentingSurvey, orderId: orderID)
            }
        }
    }
    
    class func runSurveyIfItsNeeded(target: DataServiceProtocol, executionType: ApiRequestExecutionType) {
        ReviewServiceDataManager.sharedInstance.getAvaiableUserSurvey(target, executionType: executionType) { (data, error) in
            if let dataDictionary = data as? [String: Any], let content = dataDictionary[DataManagerKeys.DataContent] as? UserSurvey, let presentingSurvey = content.surveys?.first, let orderID = content.orderNumber {
                self.startPresentingSurvey(reviewSurvey: presentingSurvey, orderId: orderID)
            } else if let userSurvey = data as? UserSurvey, let presentingSurvey = userSurvey.surveys?.first, let orderID = userSurvey.orderNumber {
                self.startPresentingSurvey(reviewSurvey: presentingSurvey, orderId: orderID)
            }
        }
//        if let presentingSurvey = mockApi().surveys?.first, let orderID = mockApi().orderNumber {
//            self.startPresentingSurvey(reviewSurvey: presentingSurvey, orderId: orderID)
//        }
    }
    
    class func startPresentingSurvey(reviewSurvey: ReviewSurvery, orderId: String) {
        Utility.delay(duration: 2) {
            self.presentSurveyOn(reviewSurvey: reviewSurvey, orderID: orderId)
        }
    }
    
    
    
    private class func mockApi() -> UserSurvey {
        //mock
        let userSurvey = UserSurvey()
        let review = ReviewSurvery()
        let question = SurveyQuestion()
        let option = SurveyQuestionOption()
        option.title = "what"
        option.id = 123
        option.image = URL(string:"http://www.emoji.com/wordpress/wp-content/uploads/emoji_celebs_146-1.jpg")
        question.title = "چقدر مایل هستید که بامیلو را به دوستان خود توصیه کنید که از بامیلو خرید کنند؟"
        
        
        let option1 = SurveyQuestionOption()
        option1.title = "بله"
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
        question1.title = "چقدر مایل هستید بامیلو را به دوستان خود توصیه کنید؟"
        
        
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
        
        let question30 = SurveyQuestion()
        question30.title = "چقدر مایل هستید که بامیلو را به دوستان خود توصیه کنید؟"
        question30.type = .radio
        
        let option31 = SurveyQuestionOption()
        option31.title = "نظر من این است که"
        option31.id = 1233
        
        let option32 = SurveyQuestionOption()
        option32.title = "نظر دوم من این است که"
        option32.id = 1243
        
        let option33 = SurveyQuestionOption()
        option33.title = "نظر سوم من این است که "
        option33.id = 125
        
        let option34 = SurveyQuestionOption()
        option34.title = "نظر سوم من این است که "
        option34.id = 1254
        
        let option35 = SurveyQuestionOption()
        option35.title = "نظر سوم من این است که "
        option35.id = 1255
        
        question30.options = [option31, option32, option33, option34, option35]
        question30.id = 12342
        
        let question33 = SurveyQuestion()
        question33.title = "چقدر مایل هستید که بامیلو را به دوستان خود توصیه کنید؟"
        question33.type = .essay
        
        
        review.pages = [SurveyQuestionPage()]
        review.pages?.first?.questions = [question, question33, question1, question30, question1]
        //end of mock
        
        let product = Product()
        product.name = "بسته خرید بسیار ويزه سال ۹۷"
        product.imageUrl = URL(string: "http://media.bamilo.com/p/tm-6682-6582622-1-zoom.jpg")
        
        review.product = product
        
        review.pages?.first?.questions?.forEach({ $0.product = product })
        
        userSurvey.surveys = [review]
        userSurvey.orderNumber = "2"
        
        
        
        return userSurvey
    }
}
