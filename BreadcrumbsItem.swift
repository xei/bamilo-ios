//
//  BreadcrumbsItem.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 5/23/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

import UIKit
import ObjectMapper

class BreadcrumbsItem: NSObject, Mappable {
    
    var title: String?
    var url : String?
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        title <- map["title"]
        url <- map["target"]
    }
}
