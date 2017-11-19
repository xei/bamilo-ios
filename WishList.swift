
//
//  WishList.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 11/18/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

import UIKit
import ObjectMapper

class WishList: NSObject, Mappable {
    
    var currentPage: UInt = 1
    var lastPage: UInt?
    lazy var products: [Product] = [Product]()
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        currentPage <- map["current_page"]
        lastPage <- map["per_page"]
        products <- map["products"]
    }
}
