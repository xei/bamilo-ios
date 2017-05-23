//
//  Category.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 5/7/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

import UIKit
import ObjectMapper

class Category: Mappable {
    var urlKey:String?
    var name:String?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        urlKey <- map["url_key"]
        name   <- map["name"]
    }
}
