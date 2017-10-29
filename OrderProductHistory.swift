//
//  OrderProductHistory.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 10/21/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

import UIKit
import ObjectMapper

enum OrderProductHistoryStatusType: String {
    case active = "active"
    case inactive = "inactive"
    case success = "success"
    case fail = "failed"
}


enum OrderProductHistoryStep: String {
    case new = "new"
    case approved = "exportable_success"
    case received = "item_received_success"
    case shipped = "shipped_success"
    case delivered = "delivered_active"
}

class OrderProductHistory: NSObject, Mappable {
    
    var name: String?
    var nameFa: String?
    var step: OrderProductHistoryStep?
    var status: OrderProductHistoryStatusType?
    var progress: UInt?
    var multiplier: UInt = 1
    var date: String?
    
    override init() {}
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        name <- map["name"]
        nameFa <- map["name_fa"]
        step <- (map["key"], EnumTransform<OrderProductHistoryStep>())
        status <- (map["status"], EnumTransform<OrderProductHistoryStatusType>())
        progress <- map["progress"]
        progress = min(progress ?? 0, 100) //validation
        multiplier <- map["widthMultiplier"]
        date <- map["date"]
    }
}
