//
//  ReviewSurvery.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 2/27/18.
//  Copyright © 2018 Rocket Internet. All rights reserved.
//

import UIKit
import ObjectMapper

class AliasSurvey: NSObject, Mappable {
    var survey: ReviewSurvery?
    
    required init?(map: Map) {}
    func mapping(map: Map) {
        survey <- map["survey"]
    }
}

class UserSurvey: NSObject, Mappable {
    var userID: String?
    var orderNumber: String?
    var surveys: [ReviewSurvery]?
    override init() {}
    required init?(map: Map) {}
    func mapping(map: Map) {
        userID <- map["userId"]
        orderNumber <- map["orderNumber"]
        surveys <- map["surveys"]
    }
}


class ReviewSurvery: NSObject, Mappable {
    var id: Int?
    var alias: String?
    var title: String?
    var pages : [SurveyQuestionPage]?
    var product: Product?
    override init() {}
    required init?(map: Map) {}
    func mapping(map: Map) {
        id <- map["id"]
        alias <- map["alias"]
        title <- map["title"]
        product <- map["product"]
        pages <- map["pages"]
        
        //set product of survey for all of it's questions
        if let product = product {
            pages?.forEach({ (page) in
                page.questions?.forEach({ $0.product = product })
            })
        }
    }
    
    func merge(survey: ReviewSurvery) {
        if let pages = survey.pages {
            self.pages?.append(contentsOf: pages)
        }
    }
}
