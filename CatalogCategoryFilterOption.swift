//
//  CatalogCategoryFilterOption.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 5/8/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

import UIKit
import ObjectMapper

@objc class CatalogCategoryFilterOption: CatalogFilterOption {
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        value <- map["url_key"]
    }
    
}
