//
//  CatalogCategoryFilterOption.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 5/8/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

import UIKit
import ObjectMapper

@objcMembers class CatalogCategoryFilterOption: CatalogFilterOption {
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        name <- map["name"]
        productsCount <- map["total_products"]
        value <- map["url_slug"]
    }
    
}
