//
//  HomePageTeaserBox.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 9/18/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

import UIKit
import ObjectMapper

enum HomePageTeaserType: String {
    case slider = "main_teasers"
    case featuredStores = "featured_stores"
    case dailyDeals = "daily_deals"
    case tiles = "tile_teaser"
}

class HomePageTeaserBox: NSObject, Mappable {
    
    var type: HomePageTeaserType?
    var hasData: Bool?
    override init() {}
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        type <- (map["type"], EnumTransform<HomePageTeaserType>())
        hasData <- map["has_data"]
    }
}
