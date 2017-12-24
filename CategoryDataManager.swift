//
//  CategoryDataManager.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 12/20/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

import UIKit

class CategoryDataManager: DataManagerSwift {
    
    static let sharedInstance = CategoryDataManager()
    
    func getWholeTree(_ target: DataServiceProtocol, requestType: ApiRequestExecutionType, completion: @escaping DataClosure) {
        CategoryDataManager.requestManager.async(.get, target: target, path: RI_CATALOG_CATEGORIES, params: nil, type: requestType) { (responseType, data, errors) in
            self.processResponse(responseType, aClass: Categories.self, data: data, errorMessages: errors, completion: completion)
        }
    }
    
    func getExternalLinks(_ target: DataServiceProtocol, requestType: ApiRequestExecutionType, completion: @escaping DataClosure) {
        CategoryDataManager.requestManager.async(.get, target: target, path: RI_API_EXTERNAL_LINKS, params: nil, type: .background) { (responseType, data, errors) in
            self.processResponse(responseType, aClass: ExternalLinks.self, data: data, errorMessages: errors, completion: completion)
        }
    }
    
    func getInternalLinks(_ target: DataServiceProtocol, requestType: ApiRequestExecutionType, completion: @escaping DataClosure) {
        CategoryDataManager.requestManager.async(.get, target: target, path: RI_API_INTERNAL_LINKS, params: nil, type: .background) { (responseType, data, errors) in
            self.processResponse(responseType, aClass: InternalLinks.self, data: data, errorMessages: errors, completion: completion)
        }
    }
}
