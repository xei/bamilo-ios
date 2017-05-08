//
//  CatalogPriceFilterItem.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 5/7/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

import UIKit
import ObjectMapper

class CatalogPriceFilterItem: BaseCatalogFilterItem {
    
    var maxPrice: UInt64!
    var minPrice: UInt64!
    var interval: Int?
    var discountOnly: Bool?
    var lowerValue: UInt64?
    var upperValue: UInt64?
    
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        
        maxPrice <- map["option.max"]
        lowerValue <- map["option.min"]
        upperValue <- map["option.max"]
        interval <- map["option.interval"]
        minPrice <- map["option.min"]
    }
}
