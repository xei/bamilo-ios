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
            
            let requestUrl = "\(baseUrl)/\(path)".addingPercentEncoding( withAllowedCharacters: NSCharacterSet.urlQueryAllowed) ?? ""
            return RequestManagerSwift.sharedManager.request(requestUrl, method: method, parameters: params, encoding: URLEncoding(destination: .methodDependent), headers: self.createHeaders()).responseJSON(completionHandler: { (response) in
                if let url = response.request?.url {
                    print("------------ Start response for : \(url)")
                }
                print(response)
            }).responseObject { (response: DataResponse<ApiResponseData>) in
                switch response.result {
                    case .success:
                        if let apiResponseData = response.result.value {
                            if(apiResponseData.success) {
                                completion(response.response?.statusCode ?? 0, apiResponseData, self.prepareErrorMessages(messagesList: apiResponseData.messages))
                            } else {
                                completion(response.response?.statusCode ?? 0, nil, self.prepareErrorMessages(messagesList: apiResponseData.messages))
                            }
                        }
                        if(type == .foreground) {
                            LoadingManager.hideLoading()
                        }
                    case .failure(let error):
                        print(error)
                        completion(error.code, nil, nil)
                        if(type == .container || type == .foreground) {
                            LoadingManager.hideLoading()
                        }
                }
            }.task
        }
        return nil
    }
    
    //MARK: Private Methods
    private func createHeaders() -> HTTPHeaders {
        return [
            "User-Agent" : "\(AppUtility.getUserAgent()) M_IRAMZ",
            "User-Language" : "fa_IR"
        ]
    }
    
//    private func handleGenericError(viewController: UIViewController, error: Error) {
//        switch (error.code) {
//        case NSURLErrorCannotConnectToHost,
//             NSURLErrorNotConnectedToInternet,
//             NSURLErrorNetworkConnectionLost,
//             NSURLErrorTimedOut,
//             NSURLErrorDNSLookupFailed,
//             NSURLErrorCannotFindHost:
//            //Internet connection error
//            if viewController.isKind(of: BaseViewControl) {
//
//            } else {
//
//            }
//            break
//        case NSURLErrorTimedOut:
//            break
//        default:
//            break
//        }
//    }
    
    private func prepareErrorMessages(messagesList: ApiDataMessageList?) -> [Any] {
        return messagesList?.validations ?? messagesList?.errors?.map { $0.message ?? "" } ?? []
    }
}
