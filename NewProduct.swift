//
//  NewProduct.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 7/15/18.
//  Copyright © 2018 Rocket Internet. All rights reserved.
//

import UIKit
import ObjectMapper

//this model should be replaced with Product object when whole the product entities
// have been migrated in all endpoints e.g. catalog, Homepage, ....

class NewProduct: NSObject, Mappable, TrackableProductProtocol {

    var sku: String!
    var simpleSku: String?
    var name: String?
    var brand: String?
    var price: ProductPrice?
    var image: URL?
    var imageList: [ProductImageItem]?
    var ratings: ProductRate?
    var reviews: ProductReview?
    var isNew: Bool = false
    var isInWishList: Bool = false
    var hasStock: Bool = true
    var shareURL: String?
    var loadedComprehensively: Bool = false
    var seller: Seller?
    var otherSellerCount: Int?
    var specifications: [ProductSpecificsTableSection]?
    var descriptionHTML: String?
    var variations: [ProdoctVariationItem]?
    var isSelected = false //for products of variations
    var returnPolicy: ProductReturnPolicy?
    var sizeVariaionProducts: [NewProduct]?
    var OtherVariaionProducts: [NewProduct]?
    var breadCrumbs: [BreadcrumbsItem]?
    
    //MARK: - TrackableProductProtocol
    var payablePrice: NSNumber? {
        get {
            if let price = price?.value { return NSNumber(value: price) }
            return nil
        }
    }
    
    required init?(map: Map) {}
    func mapping(map: Map) {
        sku <- map["sku"]
        simpleSku <- map["simple_sku"]
        name <- map["title"]
        brand <- map["brand"]
        price <- map["price"]
        image <- (map["image"], URLTransform())
        imageList <- map["image_list"]
        shareURL <- map["share_url"]
        isNew <- map["is_new"]
        isInWishList <- map["is_wishlist"]
        ratings <- map["rating"]
        reviews <- map["reviews"]
        hasStock <- map["has_stock"]
        seller <- map["seller"]
        
        otherSellerCount <- map["other_seller_count"]
        variations <- map["variations"]
        returnPolicy <- map["return_policy"]
        breadCrumbs <- map["breadcrumbs"]
        
        //extra calculation to prevent multiple calculations
        sizeVariaionProducts = variations?.filter { $0.type == .size }.first?.products
        OtherVariaionProducts = variations?.filter { $0.type != .size }.map { $0.products }.compactMap { $0 }.flatMap { $0 }
    }
}

enum ProdoctVariationItemType: String {
    case size
    case color
    case other
}

class ProductReturnPolicy:NSObject, Mappable {
    var title: String?
    var icon: URL?
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        title <- map["title"]
        icon <- (map["icon"], URLTransform())
    }
}

class ProdoctVariationItem: NSObject, Mappable {
    var type: ProdoctVariationItemType?
    var title: String?
    var products: [ NewProduct ]?
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        type <- (map["type"], EnumTransform())
        title <- map["title"]
        products <- map["products"]
    }
}

class ProductPrice: NSObject, Mappable {
    var value: UInt64?
    var oldPrice: UInt64?
    var discountBenefit: UInt64?
    var discountPercentage: Int?
    var currency: String?
    
    required init?(map: Map) {}
    func mapping(map: Map) {
        value <- map["price"]
        oldPrice <- map["old_price"]
        discountBenefit <- map["discount_benefit"]
        discountPercentage <- map["discount_percentage"]
        currency <- map["currency"]
    }
}


class ProductImageItem: NSObject, Mappable {
    
    var medium: URL?
    var large: URL?
    required init?(map: Map) {}
    func mapping(map: Map) {
        medium <- (map["medium"], URLTransform())
        large <- (map["large"], URLTransform())
    }
}

class ProductSpecificsTableSection: Mappable {
    var header: String?
    var body: [ProductSpecificItem]?
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        header  <- map["header"]
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

class ProductDescriptionWrapper: Mappable {
    var description: String?
    
    required init?(map: Map) {}
    func mapping(map: Map) {
        description <- map["description"]
    }
}

class ProductSpecifics: Mappable {
    var items: [ProductSpecificsTableSection]?
    required init?(map: Map) {}
    func mapping(map: Map) {
        items <- map["specifications"]
    }
}
