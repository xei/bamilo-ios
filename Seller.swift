//
//  Seller.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 4/25/18.
//  Copyright © 2018 Rocket Internet. All rights reserved.
//

import UIKit
import ObjectMapper
import SwiftyJSON

class ColorLabelValue<T>: Mappable {
    var label: String?
    var color: UIColor?
    var value: T?
    
    required init?(map: Map) {}
    func mapping(map: Map) {
        label <- map["label"]
        color <- map["color"]
        value <- map["value"]
    }
}

class SellerScore: Mappable {
    var isEnable = false
    var maxValue: Double?
    var overall: ColorLabelValue<Double>?
    var fullfilment: ColorLabelValue<Double>?
    var notReturned: ColorLabelValue<Double>?
    var slaReached: ColorLabelValue<Double>?
    
    required init?(map: Map) {}
    func mapping(map: Map) {
        isEnable <- map["isEnabled"]
        maxValue <- map["maxValue"]
        overall <- map["overall"]
        fullfilment <- map["fullfilment"]
        notReturned <- map["notReturned"]
        slaReached <- map["SLAReached"]
    }
}

@objc class Seller: NSObject, Mappable {
    
    var isGlobal = false
    var isNew = false
    var name: String?
    var id: Int?
    var warranty: String?
    var target: RITarget?
    var totalReview: Int?
    var averageReview: Int?
    var deliveryTime: String?
    var score: SellerScore?
    var precenceDuration: ColorLabelValue<String>?
    var orderDeliveryCount: ColorLabelValue<String>?
    
    required init?(map: Map) {}
    func mapping(map: Map) {
        isGlobal <- map["is_global"]
        isNew <- map["isNew"]
        name <- map["name"]
        id <- map["id"]
        warranty <- map["warranty"]
        target <- map["target"]
        totalReview <- map["reviews.total"]
        averageReview <- map["reviews.average"]
        deliveryTime <- map["delivery_time"]
        score <- map["score"]
        orderDeliveryCount <- map["orders_count"]
        precenceDuration <- map["precenceDuration"]
        
        //Mapping filters
        let json = JSON(map.JSON)
        
        if let targetString = json["target"].string {
            target = RITarget.parseTarget(targetString)
        }
    }
    
    
    //is only has been written for objective-c codes! (you can remove this function if it's not necessary anymore)
    static func parseToSeller(dic: [String: Any]) -> Seller? {
        return Seller.self.init(JSON: dic)
    }
}
