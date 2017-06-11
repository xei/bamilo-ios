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
    
    func processResponse(_ responseType: ApiResponseType, aClass: Any?, data: ApiResponseData?, errorMessages: [Any]?, completion: DataClosure?) {
        if let completion = completion {
            guard responseType == .success, let data = data else {
                return completion(nil, self.createError(responseType, errorMessages: errorMessages))
            }
            
            var payload = [String: Any]()
            if let messages = data.messages {
                payload[DataManagerKeys.DataMessages] = messages
            }
            
             /*TEMP:
              When all classes migrated to Swift along with models replace this with
             
              if let serviceData = data.metadata as [String:Any]?, let mappableClass = aClass as? Mappable.Type {
                if let responseObj = mappableClass.init(JSON: serviceData) {
                    payload[DataManagerKeys.DataContent] = responseObj
                }
              }
             */
            if let serviceData = data.metadata as [String:Any]? {
                if let mappableClass = aClass as? Mappable.Type, let responseObj = mappableClass.init(JSON: serviceData) {
                    payload[DataManagerKeys.DataContent] = responseObj
                    
                    self.handlePayload(payload: payload, data: data, completion: completion)
                } else if let mappableClassVerbose = aClass as? JSONVerboseModel.Type {
                    RICountry.getConfigurationWithSuccessBlock({ (configuration) in
                        payload[DataManagerKeys.DataContent] = mappableClassVerbose.parseToDataModel(with: [serviceData, configuration! ])
                        self.handlePayload(payload: payload, data: data, completion: completion)
                    }, andFailureBlock: { (apiResponse, errorMessages) in
                        if let errorMessages = errorMessages, let apiResponseType = self.map(statusCode: apiResponse) {
                            completion(nil, self.createError(apiResponseType, errorMessages:errorMessages))
                        }
                    })
                } else if let mappableClass = aClass as? BaseModel.Type {
                    let dataModel = mappableClass.init()
                    try? dataModel.merge(from: serviceData, useKeyMapping: true, error: ())
                    payload[DataManagerKeys.DataContent] = dataModel
                    
                    self.handlePayload(payload: payload, data: data, completion: completion)
                }
            }
            
            
        }
    }
    
    func createError(_ responseType: ApiResponseType, errorMessages: [Any]?) -> Error? {
        guard let errorMessages = errorMessages else {
            return NSError(domain:AppValues.Domain, code:responseType.rawValue, userInfo:nil)
        }
        
        return NSError(domain:AppValues.Domain, code:responseType.rawValue, userInfo:[ AppKeys.ErrorMessages : errorMessages ])
    }
    
    //MARK: Private Methods
    private func handlePayload(payload: [String:Any], data: ApiResponseData?, completion: @escaping DataClosure) {
        if payload.count > 1 {
            completion(payload, nil)
        } else if payload[DataManagerKeys.DataContent] != nil {
            completion(payload[DataManagerKeys.DataContent], nil)
        } else if payload[DataManagerKeys.DataMessages] != nil {
            completion(payload[DataManagerKeys.DataMessages], nil)
        } else {
            completion(data, nil)
        }
    }
    
    /*
     RIApiResponseSuccess                = 9000,
     RIApiResponseAuthorizationError     = 9001,
     RIApiResponseTimeOut                = 9002,
     RIApiResponseBadUrl                 = 9003,
     RIApiResponseUnknownError           = 9004,
     RIApiResponseAPIError               = 9005,
     RIApiResponseNoInternetConnection   = 9006,
     RIApiResponseMaintenancePage        = 9007,
     RIApiResponseKickoutView            = 9008
     */
    private func map(statusCode: RIApiResponse) -> ApiResponseType? {
        switch statusCode {
            case .success:
                return ApiResponseType.success
            case .authorizationError:
                return ApiResponseType.authorizationError
            case .timeOut:
                return ApiResponseType.timeOut
            case .badUrl:
                return ApiResponseType.badUrl
            case .unknownError:
                return ApiResponseType.unknownError
            case .apiError:
                return ApiResponseType.apiError
            case .noInternetConnection:
                return ApiResponseType.noInternetConnection
            case .maintenancePage:
                return ApiResponseType.maintenancePage
            case .kickoutView:
                return ApiResponseType.kickoutView
        }
    }
}
