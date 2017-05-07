//
//  CatalogDataManager.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 5/2/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

import UIKit

class CatalogDataManager: DataManager {
    
    //TODO: Must be changed when we migrate all data managers
    private static let shared = CatalogDataManager()
    override class func sharedInstance() -> CatalogDataManager {
        return shared;
    }
    
    func getCatalog(target:DataServiceProtocol,  completion: @escaping DataCompletion) {
        let path = "search/find/category/women_clothes/page/1/maxitems/36"
        self.requestManager.asyncGET(target, path: path, params: nil, type: .foreground) { (statusCode, data, errorMessages) in
//            self.processResponse(statusCode, of: Catalog.self, forData: data, errorMessages: errorMessages, completion: completion)
        }
    }
    
    func getSubCategoriesFilter(target: DataServiceProtocol, categoryUrlKey: String, completion: @escaping DataCompletion) {
        let path = "\(RI_API_GET_CATEGORIES_BY_URLKEY)\(categoryUrlKey)"
        
        self.requestManager.asyncGET(target, path: path, params: nil, type: .foreground) { (statusCode, data, errorMessages) in
            let _data = ResponseData()
            _data.metadata = ((((data?.metadata["data"] as? [[String:Any]])?[0])?["children"]) as? [[String: Any]])?[0]
            self.processResponse(statusCode, of: SearchCategoryFilter.self, forData: _data, errorMessages: errorMessages, completion: completion)
        }
    }
    
}
