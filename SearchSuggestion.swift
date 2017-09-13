//
//  SearchSuggestion.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 9/13/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

import UIKit
import ObjectMapper

class SearchSuggestion: NSObject, Mappable {
    
    var products: [Product]?
    var categories: [CategorySuggestion]?
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        products <- map["products"]
        categories <- map["categories"]
    }

}
