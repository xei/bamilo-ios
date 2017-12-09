//
//  DataManager.swift
//  Bamilo
//
//  Created by Narbeh Mirzaei on 6/3/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

import ObjectMapper

typealias DataClosure = (_ data: Any?, _ error: NSError?) -> Void

struct DataManagerKeys {
    static let DataMessages = "DataMessages"
    static let DataContent = "DataContent"
}

class DataManagerSwift {
    static private(set) var requestManager: RequestManagerSwift = {
        if let apiBaseUrl = AppUtility.getInfoConfigs(for: AppKeys.APIBaseUrl) as? String,
            let apiVersion = AppUtility.getInfoConfigs(for: AppKeys.APIVersion) as? String {
            return RequestManagerSwift(with: "\(apiBaseUrl)v\(apiVersion)")
        }
        return RequestManagerSwift(with: nil)
    }()
    
    func processResponse(_ responseType: Int, aClass: Any?, data: ApiResponseData?, errorMessages: [Any]?, completion: DataClosure?) {
        if let completion = completion {
            guard let data = data else {
                return completion(nil, self.createError(responseType, errorMessages: errorMessages))
            }
            var payload = [String: Any]()
            if let messages = data.messages {
                payload[DataManagerKeys.DataMessages] = messages
            }
            if let serviceData = data.metadata as [String:Any]? {
                if let mappableClass = aClass as? Mappable.Type, let responseObj = mappableClass.init(JSON: serviceData) {
                    payload[DataManagerKeys.DataContent] = responseObj
                    self.handlePayload(payload: payload, data: data, completion: completion)
                } else if let mappableClassVerbose = aClass as? JSONVerboseModel.Type {
                    RICountry.getConfigurationWithSuccessBlock({ (configuration) in
                        payload[DataManagerKeys.DataContent] = mappableClassVerbose.parseToDataModel(with: [serviceData, configuration!])
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
                } else { // can not be parse as expected, just pass data
                    self.handlePayload(payload: payload, data: data, completion: completion)
                }
            } else {
                self.handlePayload(payload: payload, data: data, completion: completion)
            }
        }
    }
    
    func createError(_ responseType: Int, errorMessages: [Any]?) -> NSError? {
        guard let errorMessages = errorMessages else {
            return NSError(domain:AppValues.Domain, code:responseType, userInfo:nil)
        }
        return NSError(domain:AppValues.Domain, code:responseType, userInfo:[ AppKeys.ErrorMessages : errorMessages ])
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
    
    private func map(statusCode: RIApiResponse) -> Int? {
        switch statusCode {
            case .success:
                return 200
            case .authorizationError:
                return NSURLErrorUserAuthenticationRequired
            case .timeOut:
                return NSURLErrorTimedOut
            case .badUrl:
                return NSURLErrorBadURL
            case .unknownError:
                return NSURLErrorUnknown
            case .apiError:
                return NSURLErrorBadServerResponse
            case .noInternetConnection:
                return NSURLErrorNotConnectedToInternet
            case .maintenancePage:
                return NSURLErrorCannotConnectToHost
            case .kickoutView:
                return NSURLErrorUnsupportedURL
        }
    }
}
