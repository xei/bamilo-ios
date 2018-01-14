//
//  OrderCancellation.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 1/8/18.
//  Copyright © 2018 Rocket Internet. All rights reserved.
//

import UIKit
import ObjectMapper

class OrderCancellationReason:NSObject, Mappable {
    var id: String?
    var title: String?
    var isSelected: Bool = false
    override init() {}
    required init?(map: Map) {}
    func mapping(map: Map) {
        id <- map["id"]
        title <- map["text"]
    }
}

class OrderCancellationInfo:NSObject, Mappable {
    var enable: Bool = false
    var reasons:[OrderCancellationReason]?
    var noticeMessage: String?
    var refundMessage: String?
    
    override init() {}
    required init?(map: Map) {}
    func mapping(map: Map) {
        enable <- map["isCancellationServiceEnabled"]
        reasons <- map["reasons"]
        noticeMessage <- map["noticeMessage"]
        refundMessage <- map["refundMessage"]
    }
}
