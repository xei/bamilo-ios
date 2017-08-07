//
//  CatalogPriceFilterItem.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 5/7/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

import UIKit
import ObjectMapper
import SwiftyJSON

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
        minPrice <- map["option.min"]
        var optionalSelectedLowerValue: Int64?
        var optionalSelectedUpperValue: Int64?
        optionalSelectedLowerValue <- map["selected.lowerValue"]
        optionalSelectedUpperValue <- map["selected.upperValue"]
        lowerValue = optionalSelectedLowerValue ?? minPrice
        upperValue = optionalSelectedUpperValue ?? maxPrice
        interval <- map["option.interval"]
        discountOnly <- map["special_price.selected"]
    }
    
    func toJSON() -> [String : Any] {
        return [
            "filter_separator": self.filterSeparator ?? "-",
            "id": self.id,
            "multi": self.multi,
            "name": self.name,
            "option" : ["interval": self.interval, "max": self.maxPrice, "min": self.minPrice],
            "selected": ["lowerValue": self.lowerValue, "upperValue": self.upperValue],
            "special_price": ["selected": self.discountOnly]
        ] as [String : Any]
    }
}
