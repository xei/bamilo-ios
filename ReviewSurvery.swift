//
//  ReviewSurvery.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 2/27/18.
//  Copyright © 2018 Rocket Internet. All rights reserved.
//

import UIKit
import ObjectMapper


class UserSurvey: NSObject, Mappable {
    var userID: String?
    var orderNumber: String?
    var surveys: [ReviewSurvery]?
    
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
    var page : [SurveyQuestionPage]?
    
    required init?(map: Map) {}
    func mapping(map: Map) {
        id <- map["id"]
        alias <- map["alias"]
        title <- map["title"]
        page <- map["page"]
    }
}
