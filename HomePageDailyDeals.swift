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
        color <- (map["text_color"], colorTransformer)
    }
}

class HomePageDailyDeals: HomePageTeaserBox {
    
    var backgroundColor: UIColor?
    var title: String?
    var titleColor: UIColor?
    var products: [Product]?
    var moreOption: MoreButtonObject?
    var ramainingSeconds: Int?
    var counterColor: UIColor?
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        backgroundColor <- (map["data.background_color"], colorTransformer)
        products <- map["data.body.products"]
        title <- map["data.header.title"]
        titleColor <- (map["data.header.text_color"], colorTransformer)
        moreOption <- map["data.header.more_option"]
        ramainingSeconds <- map["data.header.counter.remaining_seconds"]
        counterColor <- (map["data.header.counter.text_color"], colorTransformer)
    }
    
}
