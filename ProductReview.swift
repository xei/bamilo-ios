//
//  ProductReview.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 7/1/18.
//  Copyright © 2018 Rocket Internet. All rights reserved.
//

import UIKit
import ObjectMapper

class ProductReview: NSObject, Mappable {
    
    var totalCount: Int = 0
    var items: [ProductReviewItem]?
    var pagination: Pagination?
    
    override init() {}
    required init?(map: Map) { }
    
    func mapping(map: Map) {
        totalCount <- map["total"]
        items <- map["items"]
        pagination <- map["pagination"]
    }
}


class ProductReviewItem: NSObject, Mappable {
    
    var id: String?
    var title: String?
    var comment: String?
    var isBoughtByUser = false
    var date: String?
    var username: String?
    var rateScore: Int?
    var dislikeCount: Int = 0
    var likeCount: Int = 0
    
    override init() {}
    required init?(map: Map) {}
    func mapping(map: Map) {
        id <- map["id"]
        title <- map["title"]
        comment <- map["comment"]
        isBoughtByUser <- map["is_bought_by_user"]
        username <- map["username"]
        date <- map["date"]
        rateScore <- map["rate"]
        dislikeCount <- map["dislike"]
        likeCount <- map["like"]
    }
}
