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

@objcMembers class Product: NSObject, Mappable {
    
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
    var simples: [SimpleProduct]?
    var presentableSimples: [SimpleProduct]?
    var simpleVariationValues: [String]?
    var variations: [SimpleProduct]?
    var variationName: String?
    var shareURL: String?
    var imageList: [ProductImageItem]?
    var loadedComprehensively: Bool = false
    var seller: Seller?
    var specifications: [productSpecificsTableSection]?
    var shortDescription: String?
    var productDescription: String?
    
    override init() {}
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        sku                   <- map["sku"]
        name                  <- map["name"]
        brand                 <- map["brand"]
        maxSavingPrecentage   <- map["max_saving_percentage"]
        price                 <- map["price"]
        categoryIds           = JSON(map.JSON)["categories"].string?.split(separator: "|").map {String($0)}
        simpleVariationValues = JSON(map.JSON)["variations_available_list"].string?.split(separator: ";").map {String($0).trimmingCharacters(in: .whitespacesAndNewlines)}
        specialPrice          <- map["special_price"]
        imageUrl              <- (map["image"], URLTransform())
        target                <- map["target"]
        category              <- map["category_entity"]
        isInWishList          <- map["is_wishlist"]
        reviewsAverage        <- map["rating_reviews_summary.average"]
        ratingsCount          <- map["rating_reviews_summary.ratings_total"]
        reviewsCount          <- map["rating_reviews_summary.reviews_total"]
        isNew                 <- map["is_new"]
        simples               <- map["simples"]
        
        //clean up the simples property
        if let avaiableVariations = simpleVariationValues, avaiableVariations.count > 0 {
            self.presentableSimples = self.simples?.filter { $0.variationValue != nil && avaiableVariations.contains($0.variationValue!)}
        }
        
        variationName         <- map["variation_name"]
        shareURL              <- map["share_url"]
        imageList             <- map["image_list"]
        seller                <- map["seller_entity"]
        variations            <- map["variations"]
        shortDescription      <- map["summary.short_description"]
        productDescription    <- map["summary.description"]
        specifications        <- map["specifications"]
        
        //check avaiability
        var stockAvaiablity: Bool?
        stockAvaiablity     <- map["has_stock"]
        
        //for parsing another key of this entity (in different endpoints) - inconsistancy :-(
        var isOutOfStock: Bool?
        isOutOfStock <- map["out_of_stock"]
        
        hasStock = stockAvaiablity ?? isOutOfStock?.getReverse() ?? true
    }
    
    
    //TODO: remove this function when there is no objective c code
    func setPrice(price: NSNumber) {
        self.price = price.uint64Value
    }
    
    func getNSNumberPrice() -> NSNumber {
        return NSNumber(value: price ?? 0)
    }
}

class productSpecificsTableSection: Mappable {
    var header: String?
    var body: [ProductSpecificItem]?
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        header  <- map["head_label"]
        body    <- map["body"]
    }
}

class ProductSpecificItem: Mappable {
    var title: String?
    var value: String?
    required init?(map: Map) { }
    
    func mapping(map: Map) {
        title <- map["key"]
        value <- map["value"]
    }
}


class ProductImageItem: NSObject, Mappable {
    
    var normal: URL?
    var zoom: URL?
    required init?(map: Map) {}
    func mapping(map: Map) {
        normal <- (map["url"], URLTransform())
        zoom <- (map["zoom"], URLTransform())
    }
}


