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

@objc class CatalogCategoryFilterItem: CatalogFilterItem {
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        
        multi = false
        //TODO: prefer to find a solution for gathering translation texts
        name = "زیر مجموعه‌ها";
        id <- map["url_key"]
        
        let json = JSON(map.JSON)
        self.options = json["children"].arrayValue.map { (element) -> CatalogFilterOption in
            let filterOption = CatalogFilterOption(JSON: element.dictionaryValue)
            filterOption?.name = element["name"].stringValue
            filterOption?.value = element["url_key"].stringValue
            return filterOption!
        }
    }
}
