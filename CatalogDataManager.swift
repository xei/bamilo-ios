//
//  CatalogDataManager.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 5/2/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

import UIKit
import ObjectMapper

class CatalogDataManager: DataManagerSwift {
    static let sharedInstance = CatalogDataManager()
    
    func getCatalog(target:DataServiceProtocol, searchTarget:RITarget? = nil, filtersQueryString:String? = nil, sortingMethod:Catalog.CatalogSortType = .populaity, page:Int = 1, completion: @escaping DataCompletion) {
        var path = "\(RI_API_CATALOG)"
        if let target = searchTarget, let urlForTarget = RITarget.getRelativeUrlStringforTarget(target) {
            path += "\(urlForTarget)/"
        }
        
        if let filters = filtersQueryString {
            path += filters
        }
        
        if let sortUrl = Catalog.urlForSortType(type: sortingMethod) {
            path += "\(sortUrl)/"
        }
        
        path += "maxItems/36/page/\(page)"
        
        if let urlPath = path.addingPercentEncoding( withAllowedCharacters: .urlQueryAllowed) {
            CatalogDataManager.requestManager.async(.get, target: target, path: urlPath, params: nil, type: .background, completion: { (responseType, data, errorMessages) in
                self.processResponse(responseType, aClass: Catalog.self, data: data, errorMessages: errorMessages, completion: completion)
            })
        }
    }
    
    func getSubCategoriesFilter(target: DataServiceProtocol, categoryUrlKey: String, completion: @escaping DataCompletion) {
        let path = "\(RI_API_GET_CATEGORIES_BY_URLKEY)\(categoryUrlKey)"
        
        CatalogDataManager.requestManager.async(.get, target: target, path: path, params: nil, type: .background, completion: { (responseType, data, errorMessages) in
            data?.metadata = ((((data?.metadata?["data"] as? [[String:Any]])?[0])?["children"]) as? [[String: Any]])?[0]
            self.processResponse(responseType, aClass: CatalogCategoryFilterItem.self, data: data, errorMessages: errorMessages, completion: completion)
        })
    }
}
