//
//  DeliveryTime.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 8/6/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

import UIKit
import ObjectMapper
import SwiftyJSON

class DeliveryTime: NSObject, Mappable {
    
    var sku: String!
    var deliveryTimeZone1: String?
    var deliveryTimeZone2: String?
    var deliveryTime: Date?
    var deliveryTimeMessage: String?
    
    required init?(map: Map) {
        if map.JSON["sku"] == nil {
            return nil;
        }
    }
    
    func mapping(map: Map) {
        sku <- map["sku"]
        deliveryTimeZone1 <- map["delivery_zone_one"]
        deliveryTimeZone2 <- map["delivery_zone_two"]
        deliveryTime <- (map["delivery_time"], DateTransform())
        if deliveryTimeZone1 == nil || deliveryTimeZone2 == nil {
            deliveryTimeMessage <- map["delivery_message"]
        }
    }
}


class DeliveryTimes: NSObject, Mappable {
    var array: [DeliveryTime]?
    
    required init?(map: Map) {
    }

    func mapping(map: Map) {
        array <- map["data"]
    }
}
