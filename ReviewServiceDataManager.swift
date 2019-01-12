//
//  ReviewServiceDataManager.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 2/27/18.
//  Copyright © 2018 Rocket Internet. All rights reserved.
//

import UIKit
import Alamofire

enum SurveyType: String {
    case deliveredNPS = "delivered_nps"
    case returnedNPS = "returned_nps"
    case journeySurvey = "journey_survey"
    case productReviewSurvey = "product_review_survey"
}

class ReviewServiceDataManager: DataManagerSwift {
    
    static let sharedInstance = ReviewServiceDataManager()
    func getServeryAlias(_ target: DataServiceProtocol?, surveyAlias: SurveyType, executionType: ApiRequestExecutionType, completion: @escaping DataClosure) {
        ReviewServiceDataManager.requestManager.async(.get, target: target, path: "\(RI_API_SURVEY_ALIAS)\(surveyAlias.rawValue)?device=mobile_app", params: nil, type: executionType) { (responseType, data, errorMessages) in
            self.processResponse(responseType, aClass: AliasSurvey.self, data: data, errorMessages: errorMessages, completion: completion)
        }
    }

    func sendSurveyAlias(_ target: DataServiceProtocol, surveyAlias: String, question: SurveyQuestion?, isLastOne: Bool, for orderNumber: String, requestType: ApiRequestExecutionType, completion: @escaping DataClosure) {
        if let sendingParams = question?.generateJsonFormData(for: orderNumber) {
            ReviewServiceDataManager.requestManager.async(.post, target: target, path: "\(RI_API_SURVEY_ALIAS)\(surveyAlias)\(isLastOne ? "" : "?__method=PATCH")", params: sendingParams, type: requestType) { (responseType, data, errorMessages) in
                self.processResponse(responseType, aClass: nil, data: data, errorMessages: errorMessages, completion: completion)
            }
        }
    }
    
    func getAvaiableUserSurvey(_ target: DataServiceProtocol, executionType: ApiRequestExecutionType = .background, completion: @escaping DataClosure){
        if let customerID = CurrentUserManager.user.userID {
            ReviewServiceDataManager.requestManager.async(.get, target: target, path: "\(RI_API_USER_SURVEY)\(customerID)?device=mobile_app", params: nil, type: executionType) { (responseType, data, errorMessages) in
                self.processResponse(responseType, aClass: UserSurvey.self, data: data, errorMessages: errorMessages, completion: completion)
            }
        }
    }
    
    func ignoreSurvey(_ target: DataServiceProtocol, surveyID: String, executionType: ApiRequestExecutionType = .background, completion: @escaping DataClosure) {
        if let customerID = CurrentUserManager.user.userID {
            let params = ["device": "mobile_app", "status": "ignore", "__method": "PATCH"]
            ReviewServiceDataManager.requestManager.async(.post, target: target, path: "\(RI_API_USER_SURVEY)\(customerID)", params: params, type: executionType) { (responseType, data, errorMessages) in
                self.processResponse(responseType, aClass: nil, data: data, errorMessages: errorMessages, completion: completion)
            }
        }
    }
}
