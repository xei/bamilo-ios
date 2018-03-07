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
    
    var id         : Int?
    var title      : String?
    var type       : SurveryQuestionType?
    var isRequired : Bool = false
    var isHidden   : Bool = false
    var options    : [SurveyQuestionOption]?
    
    override init() {} //for initializeing without mapping
    required init?(map: Map) { }
    func mapping(map: Map) {
        id <- map["id"]
        title <- map["title"]
        type <- (map["type"], EnumTransform())
        isRequired <- map["required"]
        isHidden <- map["hidden"]
        options <- map["options"]
    }
    
    func prepareForSubmission(for orderID: String) -> [String:Any] {
//        let user = RICustomer.getCurrent()
//        var result: [String: Any] = [
//            "device": "mobile_app",
//            "userId" : user?.customerId.stringValue ?? "",
//            "orderNumber": orderID
//        ]
//
//        let selectedOptionsDictionary = options?.map({ (option) -> [String:String]? in
//            if option.isSelected, let id = option.id {
//                if let value = option.value {
//                    return ["\(id)": value]
//                } else if let comment = option.optionalComment {
//                    return ["\(id)": comment]
//                }
//            }
//            return nil
//        }).flatMap({ $0 }).reduce([:]) { $0 + $1 }
//
//        if let options = selectedOptionsDictionary {
//            result["responses"] = [options]
//        }
//        return result
        return ["":""]
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
