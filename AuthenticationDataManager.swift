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

    func loginUser(_ target:DataServiceProtocol, username:String, password:String, completion: @escaping DataClosure) {
        let params : [String: String] = [
            "login[email]" : username,
            "login[password]" : password
        ]
        
        AuthenticationDataManager.requestManager.async(.post, target: target, path: RI_API_LOGIN_CUSTOMER, params: params, type: .foreground) { (responseType, data, errorMessages) in
            if let data = data, responseType == .success {
                RICustomer.parseCustomer(withJson: data.metadata?["customer_entity"] as! [AnyHashable : Any], plainPassword: password, loginMethod: "normal")
                completion(data, nil)
            } else {
                completion(nil, self.createError(responseType, errorMessages: errorMessages))
            }
        }
    }
    
    func signupUser(_ target:DataServiceProtocol, with fields: inout [String : String], completion: @escaping DataClosure) {
        fields["customer[phone_prefix]"] = "100"
        let customerPassword = fields["customer[password]"]
        
        AuthenticationDataManager.requestManager.async(.post, target: target, path: RI_API_REGISTER_CUSTOMER, params: fields, type: .foreground) { (responseType, data, errorMessages) in
            if let data = data, responseType == .success {
                RICustomer.parseCustomer(withJson: data.metadata?["customer_entity"] as! [AnyHashable : Any], plainPassword: customerPassword, loginMethod: "normal")
                completion(data.metadata, nil)
            } else {
                completion(nil, self.createError(responseType, errorMessages: errorMessages))
            }
        }
    }
    
    func forgetPassword(_ target:DataServiceProtocol, with fields:[String : String], completion: @escaping DataClosure) {
        AuthenticationDataManager.requestManager.async(.post, target: target, path:RI_API_FORGET_PASS_CUSTOMER, params: fields, type: .foreground) { (responseType, data, errorMessages) in
            self.processResponse(responseType, aClass: nil, data: data, errorMessages: errorMessages, completion: completion)
        }
    }
    
    func logoutUser(_ target:DataServiceProtocol, completion: @escaping DataClosure) {
        AuthenticationDataManager.requestManager.async(.post, target: target, path: RI_API_LOGOUT_CUSTOMER, params: nil, type: .foreground) { (responseType, data, errorMessages) in
            self.processResponse(responseType, aClass: nil, data: data, errorMessages: errorMessages) { (data, error) in
                RICustomer.cleanFromDB()
                completion(data, error)
            }
        }
    }
}
