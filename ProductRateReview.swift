//
//  ProductRateReview.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 7/1/18.
//  Copyright © 2018 Rocket Internet. All rights reserved.
//

import UIKit
import ObjectMapper

class ProductRateReview: NSObject, Mappable {
    
    var product: SimpleProduct?
    var rating : ProductRateSummery?
    var reviews: ProductReview?
    var rateStarRange: CountableClosedRange<Int>?
    
    override init() {}
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        
        product <- map["product"]
        rating <- map["rating"]
        
        var rateStartRange: Int?
        rateStartRange <- map["stars_size.min"]
        
        var rateEndRange: Int?
        rateEndRange <- map["stars_size.max"]
        if let start = rateStartRange, let end = rateEndRange {
            self.rateStarRange = start...end
        }
    }
}


class ProductRateSummery: NSObject, Mappable {
    
    var total: Int = 0
    var stars: [ProductRateStar]?
    
    required init?(map: Map) {}
    func mapping(map: Map) {
        total <- map["total"]
        stars <- map["stars"]
    }
}

class ProductRateStar: Mappable {
    
    var title: String?
    var count: Int?
    
    required init?(map: Map) {}
    func mapping(map: Map) {
        title <- map["title"]
        count <- map["count"]
    }
}


class ProductReview: Mappable {
    
    var comments: [ProductComment]?
    var pagination: Pagination?
    var total: Int = 0
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        comments <- map["comments"]
        pagination <- map["pagination"]
        total <- map["total"]
    }
}

class ProductComment: Mappable {
    var title: String?
    var comment: String?
    var isBoughtByUser = false
    var username: String?
    var date: String?
    var userTotalStars: Int = 0
    var stars: Int?
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        title <- map["title"]
        comment <- map["comment"]
        isBoughtByUser <- map["is_bought_by_user"]
        username <- map["username"]
        date <- map["date"]
        userTotalStars <- map["total_stars_of_user"]
        stars <- map["stars"]
    }
}
