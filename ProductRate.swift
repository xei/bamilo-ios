//
//  ProductRate.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 7/1/18.
//  Copyright © 2018 Rocket Internet. All rights reserved.
//

import UIKit
import ObjectMapper

class ProductRate: NSObject, Mappable {
    
    var totalCount: Int?
    var average: Double?
    var maxValue: Double?
    var starsStatistics: [ProductRateStarStatistic]?
    
    override init() {}
    required init?(map: Map) { }
    func mapping(map: Map) {
        totalCount <- map["total"]
        average <- map["average"]
        maxValue <- map["max"]
        starsStatistics <- map["stars"]
    }
}


class ProductRateStarStatistic: NSObject, Mappable {
    
    var starNumber: Int?
    var count: Int?
    
    required init?(map: Map) {}
    override init() {}
    
    func mapping(map: Map) {
        starNumber <- map["title"]
        count <- map["count"]
    }
}
