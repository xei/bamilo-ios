//
//  Catalog.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 5/7/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

import UIKit
import ObjectMapper
import SwiftyJSON

@objc class Catalog: NSObject, Mappable {
    
    var title:String?
    var filters: [BaseCatalogFilterItem]?
    var products: [Product]?
    var totalProductsCount: Int?
    var sortType: CatalogSortType?
    var priceFilterIndex: Int = 0
    
    enum CatalogSortType: String {
        case name = "NAME"
        case priceUp = "PRICE_UP"
        case priceDown = "PRICE_DOWN"
        case bestRating = "BEST_RATING"
        case brand = "BRAND"
        case newest = "NEW_IN"
    }
    
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        title <- map["title"]
        sortType <- (map["brand"], EnumTransform<CatalogSortType>())
        products <- map["results"]
        totalProductsCount <- map["total_products"]
        
        //Mapping filters
        let json = JSON(map.JSON)
        var searchIndex = 0;
        
        filters = json["filters"].array?.map{ (element) -> BaseCatalogFilterItem in
            if element["id"] == "price" {
                let priceFilter = CatalogPriceFilterItem(JSON: element.dictionaryObject!)
                priceFilterIndex = searchIndex
                return priceFilter!
            } else {
                let filterItem = CatalogFilterItem(JSON: element.dictionaryObject!)
                searchIndex += 1
                return filterItem!
            }
        }
    }
    
//    static func url(for)
}
