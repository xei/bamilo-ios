//
//  OrderPackage.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 10/21/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

import UIKit
import ObjectMapper

class OrderPackageDelay:NSObject, Mappable {
    var hasDelay: Bool?
    var reason: String?
    override init() {}
    required init?(map: Map) {
    }
    func mapping(map: Map) {
        hasDelay <- map["has_delay"]
        reason <- map["reason"]
    }
}

enum OrderDeliveryType: String {
    case dropship = "dropship"
    case warehouse = "warehouse"
    case Crossdock = "crossdock"
}

class OrderPackageDelivery: NSObject, Mappable {
    var type: OrderDeliveryType?
    var desc: String?
    
    required init?(map: Map) {}
    func mapping(map: Map) {
        type <- (map["type"], EnumTransform())
        desc <- map["description"]
    }
    
}

class OrderPackage: NSObject, Mappable {
    
    var title: String?
    var deliveryTime: String?
    var products: [OrderProductItem]?
    var delay: OrderPackageDelay?
    var delivery: OrderPackageDelivery?
    
    override init() {}
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        title <- map["title"]
        deliveryTime <- map["delivery_time"]
        products <- map["products"]
        delay <- map["delay"]
        delivery <- map["delivery_type"]
    }
}
