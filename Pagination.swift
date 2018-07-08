//
//  Pagination.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 7/1/18.
//  Copyright © 2018 Rocket Internet. All rights reserved.
//

import UIKit
import ObjectMapper

class Pagination: NSObject, Mappable {
    var perPage: Int?
    var currentPage: Int = 1
    var totalPage: Int = 0
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        perPage     <- map["per_page"]
        currentPage <- map["current_page"]
        totalPage   <- map["total_pages"]
    }
}
