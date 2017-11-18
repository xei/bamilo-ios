//
//  CategorySuggestion.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 9/13/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

import UIKit
import ObjectMapper

class CategorySuggestion: NSObject, Mappable {
    
    var name: String?
    var target: String?
    
    override init() {
    }
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        name <- map["name"]
        target <- map["target"]
    }
}
