//
//  AuthenticationDataManager.swift
//  Bamilo
//
//  Created by Narbeh Mirzaei on 6/3/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

import Foundation

class AuthenticationDataManager: DataManagerSwift {
    static let sharedInstance = AuthenticationDataManager()

    func loginUser(_ target:DataServiceProtocol?, username:String, password:String, completion: @escaping DataClosure) {
        
        let params : [String: String] = [
            "login[email]" : username,
            "login[password]" : password
        ]
        AuthenticationDataManager.requestManager.async(.post, target: target, path: RI_API_LOGIN_CUSTOMER, params: params, type: .foreground) { (responseType, data, errorMessages) in
           self.processResponse(responseType, aClass: CustomerEntity.self, data: data, errorMessages: errorMessages, completion: completion)
        }
    }
    
    func signupUser(_ target:DataServiceProtocol?, with fields: inout [String : String], completion: @escaping DataClosure) {
        fields["customer[phone_prefix]"] = "100"
//        let customerPassword = fields["customer[password]"]
        AuthenticationDataManager.requestManager.async(.post, target: target, path: RI_API_REGISTER_CUSTOMER, params: fields, type: .foreground) { (responseType, data, errorMessages) in
            self.processResponse(responseType, aClass: CustomerEntity.self, data: data, errorMessages: errorMessages, completion: completion)
        }
    }
    
    func forgetPassword(_ target:DataServiceProtocol?, with fields:[String : String], completion: @escaping DataClosure) {
        AuthenticationDataManager.requestManager.async(.post, target: target, path:RI_API_FORGET_PASS_CUSTOMER, params: fields, type: .foreground) { (responseType, data, errorMessages) in
            self.processResponse(responseType, aClass: nil, data: data, errorMessages: errorMessages, completion: completion)
        }
    }
    
    func logoutUser(_ target:DataServiceProtocol?, completion: @escaping DataClosure) {
        AuthenticationDataManager.requestManager.async(.post, target: target, path: RI_API_LOGOUT_CUSTOMER, params: nil, type: .foreground) { (responseType, data, errorMessages) in
            self.processResponse(responseType, aClass: nil, data: data, errorMessages: errorMessages) { (data, error) in
                completion(data, error)
            }
        }
    }
    
    func submitEditedProfile(_ target:DataServiceProtocol?, with fields: inout [String : String], completion: @escaping DataClosure) {
        fields["customer[phone_prefix]"] = "100"
        AuthenticationDataManager.requestManager.async(.post, target: target, path: RI_API_EDIT_CUSTOMER, params: fields, type: .foreground) { (responseType, data, errorMessages) in
            self.processResponse(responseType, aClass: nil, data: data, errorMessages: errorMessages, completion: completion)
        }
    }
    
    func getCurrentUser(_ target:DataServiceProtocol?, completion: @escaping DataClosure) {
        AuthenticationDataManager.requestManager.async(.get, target: target, path: RI_API_GET_CUSTOMER, params: nil, type: .foreground) { (responseType, data, errors) in
            self.processResponse(responseType, aClass: CustomerEntity.self, data: data, errorMessages: errors, completion: completion)
        }
    }
    
    func phoneVerification(_ target:DataServiceProtocol?, phone: String, token: String? = nil, completion: @escaping DataClosure) {
        
        var params:[String: String] = [ "phone": phone ]
        if let token = token {
            params["token"] = token
        }
        
        AuthenticationDataManager.requestManager.async(.post, target: target, path: RI_API_PHONE_VERIFY, params: params, type: token != nil ? .container : .foreground) { (responseType, data, errors) in
            self.processResponse(responseType, aClass: nil, data: data, errorMessages: errors, completion: completion)
        }
    }
    
    func getConfigure(_ target:DataServiceProtocol?, completion: @escaping DataClosure) {
        if let version = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
            let params = [
                "versionCode":"\(version)",
                "platform":"ios"
            ]
            AuthenticationDataManager.requestManager.async(.post, target: target, path: RI_API_CONFIGURATION, params: params, type: .background) { (responseType, data, errors) in
                self.processResponse(responseType, aClass: AppConfigurations.self, data: data, errorMessages: errors, completion: completion)
            }
        }
    }
}
