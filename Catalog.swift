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

@objcMembers class Catalog: NSObject, Mappable {
    
    var title:String?
    var filters: [BaseCatalogFilterItem]?
    var products: [Product] = []
    var totalProductsCount: Int?
    var sortType: CatalogSortType?
    var priceFilterIndex: Int = 0
    var breadcrumbs: [BreadcrumbsItem]?
    var subCatFilters: [CatalogCategoryFilterOption]?
    
    var breadcrumbsFullPath: String? {
        get {
            return self.breadcrumbs?.map({ (item) -> String in
                return item.title ?? ""
            }).filter { $0.count > 0 }.joined(separator: " > ")
        }
    }
    
    enum CatalogSortType: String {
        case bestRating = "BEST_RATING"
        case popularity = "POPULARITY"
        case newest = "NEW_IN"
        case priceUp = "PRICE_UP"
        case priceDown = "PRICE_DOWN"
        case name = "NAME"
        case brand = "BRAND"
    }
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        title <- map["title"]
        sortType <- (map["sort"], EnumTransform<CatalogSortType>())
        products <- map["results"]
        totalProductsCount <- map["total_products"]
        breadcrumbs <- map["breadcrumb"]
        subCatFilters <- map["sub_categories"]
        
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
    
    func copyFilters() -> [BaseCatalogFilterItem]? {
        return  self.filters?.map({ (filterItem) -> BaseCatalogFilterItem in
            if let priceFilter = filterItem as? CatalogPriceFilterItem {
                let newpriceFilter = CatalogPriceFilterItem(JSON: priceFilter.toJSON())
                return newpriceFilter!
            } else if let filter = filterItem as? CatalogFilterItem {
                let newfilterItem = CatalogFilterItem(JSON: filter.toJSON())
                return newfilterItem!
            } else {
                //Never should comes here
                return BaseCatalogFilterItem(JSON: [:])!
            }
        })
    }
    
    class func urlForSortType(type: CatalogSortType) -> String? {
        var urlComponent:String?
        switch (type) {
        case .bestRating:
            urlComponent = "sort/rating/dir/desc";
        case .newest:
            urlComponent = "sort/newest/dir/desc";
        case .priceUp:
            urlComponent = "sort/price/dir/asc";
        case .priceDown:
            urlComponent = "sort/price/dir/desc";
        case .name:
            urlComponent = "sort/name/dir/asc";
        case .brand:
            urlComponent = "sort/brand/dir/asc";
        case .popularity:
            urlComponent = "sort/popularity";
        }
        
        return urlComponent;
    }
}
