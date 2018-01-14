//
//  OrderProductItem.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 10/21/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

import UIKit
import ObjectMapper

enum OrderProductItemRefundStatus: String {
    case pending = "pending"
    case success = "success"
}

class OrderProductItemRefund :Mappable {
    var status: OrderProductItemRefundStatus?
    var cardNumber: String?
    var cancellationReason: String?
    var date: String?
    
    required init?(map: Map) {}
    func mapping(map: Map) {
        status <- (map["status"], EnumTransform())
        cardNumber <- map["cardNumber"]
        cancellationReason <- map["cancellation_reason"]
        date <- map["date"]
    }
}

class OrderProductItem: Product {
    
    var simpleSku: String?
    var isCancelable: Bool = false
    var notCancelableReason: String?
    var deliveryTime: String?
    var size: String?
    var quantity: Int?
    var histories: [OrderProductHistory]?
    var seller: String?
    var color: String?
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        simpleSku <- map["simple_sku"]
        isCancelable <- map["isCancelable"]
        notCancelableReason <- map["notCancelableReason"]
        deliveryTime <- map["calculated_delivery_time"]
        quantity <- map["quantity"]
        size <- map["filters.size"]
        color <- map["filters.color"]
        histories <- map["histories"]
        seller <- map["seller"]
    }
    
    func convertToCancelling() -> CancellingOrderProduct {
        let cancellingItem = CancellingOrderProduct()
        cancellingItem.name = name
        cancellingItem.simpleSku = simpleSku
        cancellingItem.size = size
        cancellingItem.quantity = quantity
        cancellingItem.isCancelable = isCancelable
        cancellingItem.seller = seller
        cancellingItem.color = color
        cancellingItem.imageUrl = imageUrl
        return cancellingItem
    }
}
