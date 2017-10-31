//
//  OrderItem.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 10/21/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

import UIKit
import ObjectMapper
import SwiftyJSON

class OrderItem: NSObject, Mappable {
    
    var id: String?
    var cms: String?
    var customerFirstName: String?
    var customerLastName: String?
    var creationDate: String?
    var price: UInt64?
    var paymentMethod: String?
    var deliveryCost: String?
    var productionCount: Int = 0
    
    var packages: [OrderPackage]?
    var billingAddress: Address?
    var shippingAddress: Address?
    
    override init() {}
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        
        id <- map["order_number"]
        cms <- map["cms"]
        customerFirstName <- map["customer.first_name"]
        customerLastName <- map["customer.last_name"]
        creationDate <- map["creation_date"]
        deliveryCost <- map["payment.delivery_cost"]
        price <- map["payment.total_cost"]
        paymentMethod <- map["payment.method"]
        packages <- map["packages"]
        productionCount <- map["total_products_count"]
        
        //Mapping filters
        let json = JSON(map.JSON)
        
        billingAddress = Address.init()
        try? billingAddress?.merge(from: json["billing_address"].dictionaryObject, useKeyMapping: true, error: ())
        
        shippingAddress = Address.init()
        try? shippingAddress?.merge(from: json["shipping_address"].dictionaryObject, useKeyMapping: true, error: ())
    }
}
