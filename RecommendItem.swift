//
//  RecommendItem.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 11/15/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

import UIKit
import ObjectMapper
import EmarsysPredictSDK

@objcMembers class RecommendItem: NSObject, Mappable {
    
    var name: String?
    var brandName: String?
    var categoryPath: String?
    var imageUrl:String?
    var sku: String?
    var link: String?
    var price: UInt64 = 0
    var dicountedPrice: UInt64 = 0
    var formattedPrice: String {
        get {
            return "\(self.price)".formatPriceWithCurrency()
        }
    }
    var formattedDiscountedPrice: String {
        get {
            return "\(self.dicountedPrice)".formatPriceWithCurrency()
        }
    }
    
    required init?(map: Map) {
    }
    
    convenience init?(item: EMRecommendationItem) {
        self.init(JSON: item.data)
    }
    
    func mapping(map: Map) {
        self.sku <- map["item"]
        self.brandName <- map["brand"]
        self.categoryPath <- map["category"]
        self.link <- map["link"]
        self.imageUrl <- map["image"]
        self.price <- map["msrp"]
        self.dicountedPrice <- map["price"]
        self.name <- map["title"]
    }
    
    func convertToProduct() -> Product {
        let product = Product()
        product.name = self.name
        if let imageUrl  = self.imageUrl {
            product.imageUrl = URL(string: imageUrl)
        }
        product.sku = self.sku
        product.price = self.price
        product.brand = self.brandName
        product.specialPrice = self.dicountedPrice
        return product
    }
}

