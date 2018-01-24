//
//  SimpleProduct.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 11/19/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

import UIKit
import ObjectMapper

class SimpleProduct: NSObject, Mappable {
    
    var sku: String!
    var price: UInt64?
    var specialPrice: UInt64?
    var quantity: UInt = 0
    var variationValue: String?
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        sku <- map["sku"]
        price <- map["price"]
        specialPrice <- map["special_price"]
        variationValue <- map["variation_value"]
        quantity <- map["quantity"]
    }
}
