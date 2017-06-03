//
//  DataManager.swift
//  Bamilo
//
//  Created by Narbeh Mirzaei on 6/3/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

import ObjectMapper

typealias DataClosure = (_ data: Any?, _ error: Error?) -> Void

class DataManagerSwift {
    
    struct DataManagerKeys {
        static let DataMessages = "DataMessages"
        static let DataContent = "DataContent"
    }

    static private(set) var requestManager: RequestManagerSwift = {
        if let apiBaseUrl = AppUtility.getInfoConfigs(for: AppKeys.APIBaseUrl) as? String,
            let apiVersion = AppUtility.getInfoConfigs(for: AppKeys.APIVersion) as? String {
            return RequestManagerSwift(with: "\(apiBaseUrl)v\(apiVersion)")
        }
        
        return RequestManagerSwift(with: nil)
    }()
    
    func processResponse(_ responseType: ApiResponseType, aClass: Any?, data: ApiResponseData?, errorMessages: [String]?, completion: DataClosure?) {
        if let completion = completion {
            guard responseType == ApiResponseType.success, let data = data else {
                return completion(nil, self.createError(responseType, errorMessages: errorMessages))
            }
            
            var payload = [String: Any]()
            if let messages = data.messages {
                payload[DataManagerKeys.DataMessages] = messages
            }
            
            if let serviceData = data.metadata as [String:Any]?, let mappableClass = aClass as? Mappable.Type {
                if let responseObj = mappableClass.init(JSON: serviceData) {
                    payload[DataManagerKeys.DataContent] = responseObj
                }
            }
            
            self.handlePayload(payload: payload, completion: completion)
        }
    }
    
    func createError(_ responseType: ApiResponseType, errorMessages: [String]?) -> Error? {
        guard let errorMessages = errorMessages else {
            return NSError(domain:AppValues.Domain, code:responseType.rawValue, userInfo:nil)
        }
        
        return NSError(domain:AppValues.Domain, code:responseType.rawValue, userInfo:[ AppKeys.ErrorMessages : errorMessages ])
    }
    
    //MARK: Private Methods
    private func handlePayload(payload: [String:Any], completion: @escaping DataCompletion) {
        if payload.count > 1 {
            completion(payload, nil)
        } else if payload[DataManagerKeys.DataContent] != nil {
            completion(payload[DataManagerKeys.DataContent], nil)
        } else if payload[DataManagerKeys.DataMessages] != nil {
            completion(payload[DataManagerKeys.DataMessages], nil)
        }
    }
}
