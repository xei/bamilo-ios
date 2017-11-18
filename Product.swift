//
//  Product.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 5/7/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

import UIKit
import ObjectMapper
import SwiftyJSON

@objc class Product: NSObject, Mappable {
    
    var sku: String!
    var name: String?
    var brand: String?
    var maxSavingPrecentage: Int?
    var price: UInt64?
    var specialPrice: UInt64?
    var categoryIds: [String]?
    var category: CategoryProduct?
    var imageUrl: URL?
    var target: String?
    var reviewsAverage: Double?
    var ratingsCount: Int?
    var isNew: Bool = false
    var isInWishList: Bool = false
    var reviewsCount: Int?
    var hasStock: Bool = true
    
    override init() {}
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        sku                 <- map["sku"]
        name                <- map["name"]
        brand               <- map["brand"]
        maxSavingPrecentage <- map["max_saving_percentage"]
        price               <- map["price"]
        categoryIds         = JSON(map.JSON)["categories"].string?.split(separator: "|").map {String($0)}
        specialPrice        <- map["special_price"]
        imageUrl            <- (map["image"], URLTransform())
        target              <- map["target"]
        category            <- map["category_entity"]
        isInWishList        <- map["is_wishlist"]
        reviewsAverage      <- map["rating_reviews_summary.average"]
        ratingsCount        <- map["rating_reviews_summary.ratings_total"]
        reviewsCount        <- map["rating_reviews_summary.reviews_total"]
        isNew               <- map["is_new"]
        
        //checkou avaiability
        var stockAvaiablity: Bool?
        stockAvaiablity     <- map["has_stock"]
        hasStock = stockAvaiablity ?? true
    }
}
