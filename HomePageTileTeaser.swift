//
//  HomePageTileTeaser.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 10/11/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

import UIKit
import ObjectMapper

class HomePageTileTeaserItem:NSObject, Mappable {
    
    var imageUrl: URL?
    var target: String?
    
    override init() {}
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        imageUrl <- (map["image_portrait"], URLTransform())
        target <- map["target"]
    }
}

class HomePageTileTeaser: HomePageTeaserBox {
    
    var items: [HomePageTileTeaserItem]?
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        items <- map["data"]
    }
    
}
