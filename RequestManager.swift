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

enum ApiRequestExecutionType: Int {
    case foreground = 0
    case background = 1
    case container  = 2
}

typealias ResponseClosure = (_ responseType: Int, _ data: ApiResponseData?, _ errorMessages: [Any]?) -> Void

class RequestManagerSwift {
    private var baseUrl: String?
    
    static private(set) var sharedManager: SessionManager = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 10
        configuration.timeoutIntervalForResource = 10
        return Alamofire.SessionManager(configuration: configuration)
    }()
    
    init(with baseUrl: String?) {
        self.baseUrl = baseUrl
    }
    
    @discardableResult func async(_ method: HTTPMethod, target: Any?, path: String, params: Parameters?, type: ApiRequestExecutionType, completion: @escaping ResponseClosure) -> URLSessionTask? {
        if let baseUrl = self.baseUrl {
            if(type == .container || type == .foreground) {
                LoadingManager.showLoading(on: target)
            }
            print("------------ Start request for : \(baseUrl)/\(path)")
            if let params = params {
                print(params)
            }
            let requestUrl = "\(baseUrl)/\(path)".addingPercentEncoding( withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
            return RequestManagerSwift.sharedManager.request(requestUrl ?? "\(baseUrl)/\(path)", method: method, parameters: params, encoding: URLEncoding(destination: .methodDependent), headers: self.createHeaders()).responseJSON(completionHandler: { (response) in
                if let url = response.request?.url {
                    print("------------ Start response for : \(url)")
                }
                print(response)
            }).responseObject { (response: DataResponse<ApiResponseData>) in
                switch response.result {
                    case .success:
                        var hasError = false
                        if let apiResponseData = response.result.value {
                            //Check if this request needs athenticated action which the current is not logged in
                            if let errors = apiResponseData.messages?.errors, path != RI_API_LOGOUT_CUSTOMER {
                                hasError = true
                                let hasAuthenticationErrorCode = errors.filter { $0.code == 231 }.count > 0
                                if hasAuthenticationErrorCode {
                                    LoadingManager.hideLoading()
                                    self.autoLoginWith(method, target: type, path: path, params: params, type: type, completion: completion)
                                    return
                                }
                            }
                            
                            if(type == .foreground || hasError) {
                                LoadingManager.hideLoading()
                            }
                            
                            //Continue processing response
                            if(apiResponseData.success) {
                                completion(response.response?.statusCode ?? 0, apiResponseData, self.prepareErrorMessages(messagesList: apiResponseData.messages))
                            } else {
                                hasError = true
                                completion(response.response?.statusCode ?? 0, nil, self.prepareErrorMessages(messagesList: apiResponseData.messages))
                            }
                        }
                    case .failure(let error):
                        print(error)
                        if(type == .container || type == .foreground) {
                            LoadingManager.hideLoading()
                        }
                        if (error.code == NSURLErrorUserAuthenticationRequired), path != RI_API_LOGOUT_CUSTOMER {
                            self.autoLoginWith(method, target: target, path: path, params: params, type: type, completion: completion)
                            return
                        }
                        completion(error.code, nil, nil)
                }
            }.task
        }
        return nil
    }
    
    private func autoLoginWith(_ method: HTTPMethod, target: Any?, path: String, params: Parameters?, type: ApiRequestExecutionType, completion: @escaping ResponseClosure) {
        RICustomer.autoLogin({ (success) in
            if (success) {
                self.async(method, target: target, path: path, params: params, type: type, completion: completion)
            } else {
                Utility.resetUserBehaviours()
                MainTabBarViewController.topNavigationController()?.performProtectedBlock({ (success) in
                    self.async(method, target: target, path: path, params: params, type: type, completion: completion)
                })
            }
        })
    }
    
    //MARK: Private Methods
    private func createHeaders() -> HTTPHeaders {
        return [
            "User-Agent" : "\(AppUtility.getUserAgent()) M_IRAMZ",
            "User-Language" : "fa_IR"
        ]
    }
    
    private func prepareErrorMessages(messagesList: ApiDataMessageList?) -> [Any]? {
        return messagesList?.validations ?? messagesList?.errors?.map { $0.message ?? "" }
    }
}
