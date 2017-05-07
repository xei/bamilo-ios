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

class Catalog: Mappable {
    
    var title:String?
    var filters: [BaseSearchFilterItem]?
    var products: [Product]?
    var totalProductsCount: Int?
    var sortType: CatalogSortType?
    var priceFilterIndex: Int?
    
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
        filters = json["filters"].array?.map{ (element) -> BaseSearchFilterItem in
            if element["id"] == "price" {
                let priceFilter = SearchPriceFilter()
                do {
                    try priceFilter.merge(from: element.dictionaryObject, useKeyMapping: true, error: ())
                } catch {
                    print("parsing Catalog error")
                }
                priceFilterIndex = searchIndex
                return priceFilter
            } else {
                let filterItem = SearchFilterItem()
                do {
                    try filterItem.merge(from: element.dictionaryObject, useKeyMapping: true, error: ())
                } catch {
                    print("parsing Catalog error")
                }
                searchIndex += 1
                return filterItem
            }
        }
    }
}
