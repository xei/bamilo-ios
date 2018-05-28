//
//  SurveyQuestion.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 2/27/18.
//  Copyright © 2018 Rocket Internet. All rights reserved.
//

import UIKit
import ObjectMapper

//define + operator for dictionaries
func + <K, V>(lhs: [K : V], rhs: [K : V]) -> [K : V] {
    var combined = lhs
    for (k, v) in rhs {
        combined[k] = v
    }
    return combined
}

enum SurveryQuestionType: String {
    case radio = "RADIO"
    case imageSelect = "IMAGE_SELECT"
    case nps = "NPS"
    case checkbox = "CHECKBOX"
    case textbox = "TEXTBOX"
    case essay = "ESSAY"
}

class SurveyQuestion: NSObject, Mappable {
    
    var id              : Int?
    var title           : String?
    var type            : SurveryQuestionType?
    var isRequired      : Bool = false
    var isHidden        : Bool = false
    var options         : [SurveyQuestionOption]?
    var product         : Product?
    var anwerTextMessage: String?
    
    override init() {} //for initializeing without mapping
    required init?(map: Map) { }
    func mapping(map: Map) {
        id <- map["id"]
        title <- map["title"]
        type <- (map["type"], EnumTransform())
        isRequired <- map["required"]
        isHidden <- map["hidden"]
        options <- map["options"]
        product <- map["product"]
    }
    
    func prepareForSubmission(for orderID: String) -> [String:Any] {
        let user = RICustomer.getCurrent()
        var result: [String: Any] = [
            "device": "mobile_app",
            "userId" : user?.customerId.stringValue ?? "",
            "orderNumber": orderID
        ]
        
        if let productSku = self.product?.sku {
            result["sku"] = productSku
        }
        if let type = self.type {
            switch type {
            case .checkbox:
                let selectedOptions = options?.map({ (option) -> [String: String]?  in
                    if let selected = option.isSelected, selected {
                        if let value = option.value, let optionID = option.id {
                            var result = ["\(optionID)": "\(value)"]
                            if let comment = option.optionalComment {
                                result["\(optionID)-other"] = comment
                            }
                            return result
                        }
                    }
                    return nil
                }).compactMap({ $0 }).reduce([:]) { $0 + $1 }
                if let selectedOptions = selectedOptions, let id = self.id {
                    result["responses"] = [["\(id)": selectedOptions]]
                }
            case .imageSelect, .nps, .radio:
                if let selectedOption = options?.filter({ $0.isSelected ?? false }).first, let id = self.id , let value = selectedOption.value {
                    result["responses"] = [["\(id)" : "\(value)"]]
                }
            case .essay, .textbox:
                if let id = self.id , let value = self.anwerTextMessage {
                    result["responses"] = [["\(id)" : value]]
                }
            }
            
        }
        return result
    }
    
    func generateJsonFormData(for orderID: String) -> [String: Any]? {
        var rawDictionary = self.prepareForSubmission(for: orderID)
    
        if let checkMarkResponses = rawDictionary["responses"] as? [[String: [String: String]]], let checkboxResponse = checkMarkResponses.first {
            for (questionId, selectOptions) in checkboxResponse {
                for (optionId, optiondValue) in selectOptions {
                    rawDictionary["responses[0][\(questionId)][\(optionId)]"] = optiondValue
                }
            }
            rawDictionary.removeValue(forKey: "responses")
        }
        return rawDictionary
    }
}

class SurveyQuestionPage: NSObject, Mappable {
    var id       : Int?
    var title    : String?
    var questions: [SurveyQuestion]?
    
    override init() {}
    required init?(map: Map) { }
    func mapping(map: Map) {
        id <- map["id"]
        title <- map["title"]
        questions <- map["questions"]
    }
}
