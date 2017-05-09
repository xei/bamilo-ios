//
//  CatalogFilterOption.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 5/7/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

import UIKit
import ObjectMapper

@objc class CatalogFilterOption: NSObject, Mappable {
    
    var name: String?
    var value: String?
    var average: Int?
    var productsCount: Int?
    
    //for color filter options
    var colorHexValue:String?
    
    //current state of filter option
    var selected: Bool = false
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        name <- map["label"]
        value <- map["val"]
        colorHexValue <- map["hex_value"]
        average <- map["average"]
        productsCount <- map["total_products"]
        selected <- map["seleceted"]
    }
}
