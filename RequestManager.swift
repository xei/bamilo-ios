//
//  RequestManager.swift
//  Bamilo
//
//  Created by Narbeh Mirzaei on 5/31/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

import Foundation
import Alamofire

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

typealias ResponseClosure = (_ responseType: ApiResponseType, _ data: ResponseData?, _ errorMessages: [String]?) -> Void

class RequestManagerSwift {
    enum RequestExecutionType {
        case foreground
        case background
        case container
    }
    
    private var baseUrl: String?
    
    init(with baseUrl: String) {
        self.baseUrl = baseUrl
    }
    
    func async(_ method: HTTPMethod, target: Any, path: String, params: Parameters?, type: RequestExecutionType, completion: @escaping ResponseClosure) {
        if let baseUrl = self.baseUrl {
            Alamofire.request("\(baseUrl)/\(path)", method: method, parameters: params, encoding: JSONEncoding.default, headers: self.getHeaders()).responseJSON(completionHandler: { (responseObject) -> Void in
                    
                })
        }
    }
    
    //MARK: Private Methods
    private func getHeaders() -> HTTPHeaders {
        return [
            "User-Agent" : "\(AppUtility.getUserAgent()) M_IRAMZ",
            "User-Language" : "fa_IR"
        ]
    }
}
