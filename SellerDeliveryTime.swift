//
//  SellerDeliveryTime.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 7/14/18.
//  Copyright © 2018 Rocket Internet. All rights reserved.
//

import UIKit
import ObjectMapper

class SellerDeliveryTime: NSObject, Mappable {
    
    var message: String?
    var timStampValue: Date?
    
    required init?(map: Map) {}
    func mapping(map: Map) {
        message         <- map["message"]
        timStampValue   <- (map["time_stamp"], DateTransform())
    }
}
