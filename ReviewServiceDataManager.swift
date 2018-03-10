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
    
    func getServeryAlias(_ target: DataServiceProtocol, surveyAlias: String, executionType: ApiRequestExecutionType, completion: @escaping DataClosure) {
        ReviewServiceDataManager.requestManager.async(.get, target: target, path: "\(RI_API_SURVEY_ALIAS)\(surveyAlias)", params: nil, type: executionType) { (responseType, data, errorMessages) in
            self.processResponse(responseType, aClass: UserSurvey.self, data: data, errorMessages: errorMessages, completion: completion)
        }
    }
    
    //should be called with .post just only when the survey is going to be finished
    //and  should be called with .patch when the survery is not going to be finished
    func sendSurveyAlis(_ target: DataServiceProtocol, surveyAlias: String, question: SurveyQuestion?,for orderNumber: String, updateMethod: HTTPMethod, requestType: ApiRequestExecutionType, completion: @escaping DataClosure) {
        ReviewServiceDataManager.requestManager.async(updateMethod, target: target, path: "\(RI_API_SURVEY_ALIAS)\(surveyAlias)", params: question?.prepareForSubmission(for: orderNumber), type: requestType) { (responseType, data, errorMessages) in
            self.processResponse(responseType, aClass: nil, data: data, errorMessages: errorMessages, completion: completion)
        }
    }
    
    func getAvaiableUserSurvey(_ target: DataServiceProtocol, executionType: ApiRequestExecutionType = .background, completion: @escaping DataClosure){
        if let customer = RICustomer.getCurrent(), let customerId = customer.customerId {
            ReviewServiceDataManager.requestManager.async(.patch, target: target, path: "\(RI_API_USER_SURVEY)\(customerId)", params: nil, type: executionType) { (responseType, data, errorMessages) in
                self.processResponse(responseType, aClass: UserSurvey.self, data: data, errorMessages: errorMessages, completion: completion)
            }
        }
    }
}
