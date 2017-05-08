//
//  CategoryFilterItem.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 5/8/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

import UIKit
import ObjectMapper
import SwiftyJSON

class CatalogCategoryFilterItem: BaseCatalogFilterItem {
    
    var options: [CatalogCategoryFilterOption]?
    
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        
        multi = false
        //TODO: prefer to find a solution for gathering translation texts
        name = "زیر مجموعه‌ها";
        id <- map["url_key"]
        options <- map["children"]
        
    }
}
