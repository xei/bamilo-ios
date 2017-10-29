//
//  OrderProductItem.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 10/21/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

import UIKit
import ObjectMapper

class OrderProductItem: Product {
    
    var deliveryTime: String?
    var size: String?
    var quantity: Int?
    var histories: [OrderProductHistory]?
    var seller: String?
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        
        deliveryTime <- map["calculated_delivery_time"]
        quantity <- map["quantity"]
        size <- map["filters.size"]
        histories <- map["histories"]
        seller <- map["seller"]
    }
}
