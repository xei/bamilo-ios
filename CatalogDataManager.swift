//
//  CatalogDataManager.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 5/2/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

import UIKit
import ObjectMapper

class CatalogDataManager: DataManager {
    
    //TODO: Must be changed when we migrate all data managers
    private static let shared = CatalogDataManager()
    override class func sharedInstance() -> CatalogDataManager {
        return shared;
    }
    
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
            self.requestManager.asyncGET(target, path: urlPath, params: nil, type: .background) { (statusCode, data, errorMessages) in
                self.processResponse(statusCode, of: Catalog.self, for: data, errorMessages: errorMessages, completion: completion)
            }
        }
    }
    
    func getSubCategoriesFilter(target: DataServiceProtocol, categoryUrlKey: String, completion: @escaping DataCompletion) {
        let path = "\(RI_API_GET_CATEGORIES_BY_URLKEY)\(categoryUrlKey)"
        
        self.requestManager.asyncGET(target, path: path, params: nil, type: .foreground) { (statusCode, data, errorMessages) in
            let _data = ResponseData()
            _data.metadata = ((((data?.metadata["data"] as? [[String:Any]])?[0])?["children"]) as? [[String: Any]])?[0]
            self.processResponse(statusCode, of: CatalogCategoryFilterItem.self, for: _data, errorMessages: errorMessages, completion: completion)
        }
    }
    
    override func processResponse(_ response: RIApiResponse, of aClass: AnyClass!, for data: ResponseData!, errorMessages: [Any]!, completion: DataCompletion!) {
            if completion != nil {
                if response == RIApiResponse.success && data != nil {
                    var payload = [String: Any]()
                    if let messages = data.messages {
                        payload["DataMessages"] = messages
                    }
                    
                    if let serviceData = data.metadata as? [String:Any], let mappableClass = aClass as? Mappable.Type {
                        if let responseObj = mappableClass.init(JSON: serviceData) {
                            payload["DataContent"] = responseObj
                        }
                        
                    }
                    
                    self.handlePayload(payload: payload, completion: completion)
                } else {
                    completion(nil, self.getErrorFrom(response, errorMessages: errorMessages))
                }
            }
    }
    
    
    private func handlePayload(payload: [String:Any], completion: @escaping DataCompletion) {
        if payload.count > 1 {
            completion(payload, nil)
        } else if payload["DataContent"] != nil {
            completion(payload["DataContent"], nil)
        } else if payload["DataMessages"] != nil {
            completion(payload["DataMessages"], nil)
        }
    }
}
