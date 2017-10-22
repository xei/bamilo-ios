//
//  OrderPackage.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 10/21/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

import UIKit
import ObjectMapper

class OrderPackage: NSObject, Mappable {
    
    var title: String?
    var deliveryTime: String?
    var products: [OrderProductItem]?
    
    override init() {}
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        title <- map["title"]
        deliveryTime <- map["delivery_time"]
        products <- map["products"]
    }
}
