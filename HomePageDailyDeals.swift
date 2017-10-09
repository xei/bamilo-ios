//
//  HomePageDailyDeals.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 10/7/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

import UIKit
import ObjectMapper

class MoreButtonObject:NSObject, Mappable {
    
    var title: String?
    var target: String?
    var color: UIColor?
    
    required init?(map: Map) {
    }
    
    override init() {}
    
    func mapping(map: Map) {
        title <- map["title"]
        target <- map["target"]
        color <- (map["color"], colorTransformer)
    }
}

class HomePageDailyDeals: HomePageTeaserBox {
    
    var title: String?
    var products: [Product]?
    var moreOption: MoreButtonObject?
    var countDown: Int?
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        products <- map["data.products"]
        title <- map["data.title"]
        moreOption <- map["data.more_option"]
        countDown <- map["data.countdown_intervals"]
    }
    
}
