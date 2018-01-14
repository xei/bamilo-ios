//
//  OrderPackage.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 10/21/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

import UIKit
import ObjectMapper

class OrderPackageDelay: Mappable {
    var hasDelay: Bool?
    var reason: String?
    required init?(map: Map) {
    }
    func mapping(map: Map) {
        hasDelay <- map["has_delay"]
        reason <- map["reason"]
    }
}

class OrderPackage: NSObject, Mappable {
    
    var title: String?
    var deliveryTime: String?
    var products: [OrderProductItem]?
    var delay: OrderPackageDelay?
    
    override init() {}
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        title <- map["title"]
        deliveryTime <- map["delivery_time"]
        products <- map["products"]
        delay <- map["delay"]
    }
}
