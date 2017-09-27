//
//  RequestManager.swift
//  Bamilo
//
//  Created by Narbeh Mirzaei on 5/31/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

import Foundation
import Alamofire
import AlamofireObjectMapper

enum ApiResponseType: Int {
    case success                = 9000
    case authorizationError     = 9001
    case timeOut                = 9002
    case badUrl                 = 9003
    case unknownError           = 9004
    case apiError               = 9005
    case noInternetConnection   = 9006
    case maintenancePage        = 9007
    case kickoutView            = 9008
}

enum ApiRequestExecutionType: Int {
    case foreground = 0
    case background = 1
    case container  = 2
}

typealias ResponseClosure = (_ responseType: ApiResponseType, _ data: ApiResponseData?, _ errorMessages: [Any]?) -> Void

class RequestManagerSwift {
    private var baseUrl: String?
    
    init(with baseUrl: String?) {
        self.baseUrl = baseUrl
    }
    
    func async(_ method: HTTPMethod, target: Any?, path: String, params: Parameters?, type: ApiRequestExecutionType, completion: @escaping ResponseClosure) {
        if let baseUrl = self.baseUrl {
            if(type == .container || type == .foreground) {
                LoadingManager.showLoading(on: target)
            }
            print("------------ Start request for : \(baseUrl)/\(path)")
            if let params = params {
                print(params)
            }
            Alamofire.SessionManager.default.session.configuration.timeoutIntervalForRequest = 10
            
            Alamofire.request("\(baseUrl)/\(path)", method: method, parameters: params, encoding: URLEncoding(destination: .methodDependent), headers: self.createHeaders()).responseJSON(completionHandler: { (response) in
                if let url = response.request?.url {
                    print("------------ Start response for : \(url)")
                }
                print(response)
            }).responseObject { (response: DataResponse<ApiResponseData>) in
                switch response.result {
                    case .success:
                        if let apiResponseData = response.result.value {
                            if(apiResponseData.success) {
                                completion(self.map(statusCode: response.response?.statusCode), apiResponseData, nil)
                            } else {
                                completion(self.map(statusCode: response.response?.statusCode), nil, self.prepareErrorMessages(messagesList: apiResponseData.messages!))
                            }
                        }
                    
                        if(type == .foreground) {
                            LoadingManager.hideLoading()
                        }
                    case .failure(let error):
                        print(error)
                        completion(self.map(statusCode: response.response?.statusCode), nil, [STRING_OOPS])
                        if(type == .container || type == .foreground) {
                            LoadingManager.hideLoading()
                        }
                }
            }
        }
    }
    
    //MARK: Private Methods
    private func createHeaders() -> HTTPHeaders {
        return [
            "User-Agent" : "\(AppUtility.getUserAgent()) M_IRAMZ",
            "User-Language" : "fa_IR"
        ]
    }
    
    private func map(statusCode: Int?) -> ApiResponseType {
        switch statusCode {
            default:
                return .success
        }
    }
    
    private func prepareErrorMessages(messagesList: ApiDataMessageList) -> [Any] {
        return messagesList.validations ?? messagesList.errors?.map { $0.message ?? "" } ?? []
    }
}
