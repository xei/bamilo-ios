//
//  CatalogFilterItem.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 5/7/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

import UIKit
import ObjectMapper

class CatalogFilterItem: BaseCatalogFilterItem {
    
    var options: [CatalogFilterOption]?
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        options <- map["option"]
    }
}
