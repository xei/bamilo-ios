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

@objcMembers class Product: NSObject, Mappable, TrackableProductProtocol {
    
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
    var ratings: ProductRate?
    var reviews: ProductReview?
    var isNew: Bool = false
    var isInWishList: Bool = false
    var hasStock: Bool = true
    var simples: [SimpleProduct]?
    var presentableSimples: [SimpleProduct]?
    var simpleVariationValues: [String]?
    var variations: [SimpleProduct]?
    var variationName: String?
    var shareURL: String?
    var loadedComprehensively: Bool = false
    var seller: Seller?
    var specifications: [ProductSpecificsTableSection]?
    var shortDescription: String?
    var productDescription: String?
    
    //MARK: -  TrackableProductProtocol
    var payablePrice: NSNumber? {
        get {
            if let specialPrice = specialPrice, let price = price, price != specialPrice {
                return NSNumber(value: specialPrice)
            }
            if let price = price { return NSNumber(value: price) }
            return nil
        }
    }
    
    override init() {}
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        sku                   <- map["sku"]
        name                  <- map["name"]
        brand                 <- map["brand"]
        maxSavingPrecentage   <- map["max_saving_percentage"]
        price                 <- map["price"]
        
        ratings               <- map["rating"]
        reviews               <- map["reviews"]
        
        //get rating/review counts from other places in json
        //TODO: this code should be removed when the api has been revised in all endpoints for product entity
        if ratings == nil {
            ratings = ProductRate()
        }
        if reviews == nil {
            reviews = ProductReview()
        }
        var ratingsAverage: Double?
        ratingsAverage <- map["rating_reviews_summary.average"]
        var ratingsCount: Int?
        ratingsCount <- map["rating_reviews_summary.ratings_total"]
        var reviewsCount: Int?
        reviewsCount <- map["rating_reviews_summary.reviews_total"]
        ratings?.totalCount = ratingsCount
        ratings?.average = ratingsAverage
        reviews?.totalCount = reviewsCount ?? 0
        //END of TODO
        
        categoryIds           = JSON(map.JSON)["categories"].string?.split(separator: "|").map {String($0)}
        specialPrice          <- map["special_price"]
        imageUrl              <- (map["image"], URLTransform())
        target                <- map["target"]
        category              <- map["category_entity"]
        isInWishList          <- map["is_wishlist"]
        
        isNew                 <- map["is_new"]
        simples               <- map["simples"]
        
        
        //TODO: remove this part of code when all product entities has been changed
        //clean up the simples property
        simpleVariationValues = JSON(map.JSON)["variations_available_list"].string?.split(separator: ";").map {String($0).trimmingCharacters(in: .whitespacesAndNewlines)}
        if let avaiableVariations = simpleVariationValues, avaiableVariations.count > 0 {
            self.presentableSimples = self.simples?.filter { $0.variationValue != nil && avaiableVariations.contains($0.variationValue!)}
        }
        
        variationName         <- map["variation_name"]
        shareURL              <- map["share_url"]
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
