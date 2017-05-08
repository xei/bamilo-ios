//
//  BaseCatalogFilterItem.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 5/7/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

import UIKit
import ObjectMapper

class BaseCatalogFilterItem: Mappable {
    var id: String!
    var name: String?
    var filterSeparator:String?
    var multi: Bool?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        id <- map["id"]
        name <- map["name"]
        filterSeparator <- map["filter_separator"]
        multi <- map["multi"]
    }
}
