//
//  HomePageFeaturedStore.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 9/23/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

import UIKit
import ObjectMapper

class HomePageFeaturedStoreItem: NSObject, Mappable {
    
    var title: String?
    var imageUrl: URL?
    var target: String?
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        title <- map["title"]
        imageUrl <- (map["image"], URLTransform())
        target <- map["target"]
    }
}

class HomePageFeaturedStores: HomePageTeaserBox {
    
    var items: [HomePageFeaturedStoreItem]?
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        items <- map["data"]
    }
}
