//
//  CategorySuggestion.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 9/13/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

import UIKit
import ObjectMapper
import SwiftyJSON

class CategorySuggestion: NSObject, Mappable {
    
    var name: String?
    var target: RITarget?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        
        let json = JSON(map.JSON)
        
        name <- map["name"]
        target = RITarget.parseTarget(json["target"].string)
    }
}
