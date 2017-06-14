//
//  CatalogPriceFilterItem.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 5/7/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

import UIKit
import ObjectMapper

@objc class CatalogPriceFilterItem: BaseCatalogFilterItem {
    
    var maxPrice: Int64 = 0
    var minPrice: Int64 = 0
    var interval: Int = 0
    var discountOnly: Bool = false
    var lowerValue: Int64 = 0
    var upperValue: Int64 = 0
    
    
    override func mapping(map: Map) {
        super.mapping(map: map)        
        maxPrice <- map["option.max"]
        lowerValue <- map["option.min"]
        upperValue <- map["option.max"]
        interval <- map["option.interval"]
        minPrice <- map["option.min"]
    }
}
