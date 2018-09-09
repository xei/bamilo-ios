//
//  SellerList.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 7/14/18.
//  Copyright © 2018 Rocket Internet. All rights reserved.
//

import UIKit
import ObjectMapper

class SellerListItem: NSObject, Mappable {
    
    var seller: Seller?
    var productOffer: NewProduct?
    
    required init?(map: Map) {}
    func mapping(map: Map) {
        seller <- map["seller"]
        productOffer <- map["product_offer"]
    }
}

class SellerList: NSObject, Mappable {
    
    var items: [SellerListItem]?
    required init?(map: Map) {}
    func mapping(map: Map) {
        items <- map["items"]
    }
}
