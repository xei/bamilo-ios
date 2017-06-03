//
//  AuthenticationDataManager.swift
//  Bamilo
//
//  Created by Narbeh Mirzaei on 6/3/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

import Foundation

@objc class AuthenticationDataManager: DataManager {
    //TODO: Must be changed when we migrate all data managers
    private static let shared = AuthenticationDataManager()
    override class func sharedInstance() -> AuthenticationDataManager {
        return shared
    }
    
    func loginUser(_ target:DataServiceProtocol, username:String, password:String, completion: @escaping DataCompletion) {
        let params : [String: String] = [
            "login[email]" : username,
            "login[password]" : password
        ]
        
        self.requestManager.asyncPOST(target, path: RI_API_LOGIN_CUSTOMER, params: params, type: .foreground) { (responseStatus, data, errorMessages) in
            if let data = data, responseStatus == RIApiResponse.success {
                RICustomer.parseCustomer(withJson: data.metadata["customer_entity"] as! [AnyHashable : Any], plainPassword: password, loginMethod: "normal")
                completion(data, nil)
            } else {
                completion(nil, self.getErrorFrom(responseStatus, errorMessages: errorMessages))
            }
        }
    }
    
    func signupUser(_ target:DataServiceProtocol, with fields: [String : String], completion: @escaping DataCompletion) {
        var fields = fields //TODO: Hack! @Objc cannot convert inout. When moved completely to Swift, remove this and put "with fields: inout [String: String]" in method signature instead
        fields["customer[phone_prefix]"] = "100"
        let customerPassword = fields["customer[password]"]
        
        self.requestManager.asyncPOST(target, path: RI_API_REGISTER_CUSTOMER, params: fields, type: .foreground) { (responseStatus, data, errorMessages) in
            if let data = data, responseStatus == RIApiResponse.success {
                RICustomer.parseCustomer(withJson: data.metadata["customer_entity"] as! [AnyHashable : Any], plainPassword: customerPassword, loginMethod: "normal")
                completion(data.metadata, nil)
            } else {
                completion(nil, self.getErrorFrom(responseStatus, errorMessages: errorMessages))
            }
        }
    }
    
    func forgetPassword(_ target:DataServiceProtocol, with fields:[String : String], completion: @escaping DataCompletion) {
        self.requestManager.asyncPOST(target, path:RI_API_FORGET_PASS_CUSTOMER, params: fields, type: .foreground) { (responseStatus, data, errorMessages) in
            if let data = data, responseStatus == RIApiResponse.success {
                completion(data, nil)
            } else {
                completion(nil, self.getErrorFrom(responseStatus, errorMessages: errorMessages))
            }
        }
    }
    
    func logoutUser(_ target:DataServiceProtocol, completion: @escaping DataCompletion) {
        self.requestManager.asyncPOST(target, path: RI_API_LOGOUT_CUSTOMER, params: nil, type: .foreground) { (responseStatus, data, errorMessages) in
            if let data = data, responseStatus == RIApiResponse.success {
                completion(data, nil)
            } else {
                completion(nil, self.getErrorFrom(responseStatus, errorMessages: errorMessages))
            }
            
            RICustomer.cleanFromDB()
        }
    }
}
