//
//  AuthenticationDataManager.swift
//  Bamilo
//
//  Created by Narbeh Mirzaei on 6/3/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

import Foundation
import Crashlytics

class AuthenticationDataManager: DataManagerSwift {
    static let sharedInstance = AuthenticationDataManager()

    func loginUser(_ target:DataServiceProtocol?, fields:[String : String], completion: @escaping DataClosure) {
        AuthenticationDataManager.requestManager.async(.post, target: target, path: RI_API_LOGIN_CUSTOMER, params: fields, type: .foreground) { (responseType, data, errorMessages) in
           self.processResponse(responseType, aClass: CustomerEntity.self, data: data, errorMessages: errorMessages, completion: completion)
        }
    }
    
    func signupUser(_ target:DataServiceProtocol?, with fields: inout [String : String], completion: @escaping DataClosure) {
        AuthenticationDataManager.requestManager.async(.post, target: target, path: RI_API_REGISTER_CUSTOMER, params: fields, type: .foreground) { (responseType, data, errorMessages) in
            self.processResponse(responseType, aClass: CustomerEntity.self, data: data, errorMessages: errorMessages, completion: completion)
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
        AuthenticationDataManager.requestManager.async(.post, target: target, path: RI_API_EDIT_CUSTOMER, params: fields, type: .foreground) { (responseType, data, errorMessages) in
            self.processResponse(responseType, aClass: CustomerEntity.self, data: data, errorMessages: errorMessages, completion: completion)
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
    
    func forgetPassReq(_ target:DataServiceProtocol?, params: [String: String], completion: @escaping DataClosure) {
        AuthenticationDataManager.requestManager.async(.post, target: target, path: RI_API_FORGET_PASS_REQUEST, params: params, type: .foreground) { (responseType, data, errors) in
            self.processResponse(responseType, aClass: ForgetPassResponse.self, data: data, errorMessages: errors, completion: completion)
        }
    }
    
    
    func forgetPassReset(_ target:DataServiceProtocol?, params: [String: String], completion: @escaping DataClosure) {
        AuthenticationDataManager.requestManager.async(.post, target: target, path: RI_API_FORGET_PASS_RESET, params: params, type: .foreground) { (responseType, data, errors) in
            self.processResponse(responseType, aClass: nil, data: data, errorMessages: errors, completion: completion)
        }
    }
    
    
    func forgetPassVerify(_ target:DataServiceProtocol?, params: [String: String], completion: @escaping DataClosure) {
        AuthenticationDataManager.requestManager.async(.post, target: target, path: RI_API_FORGET_PASS_VERIFY, params: params, type: .foreground) { (responseType, data, errors) in
            self.processResponse(responseType, aClass: nil, data: data, errorMessages: errors, completion: completion)
        }
    }
    
    
    // helper functions
    
    func signinUser<T: BaseViewController & DataServiceProtocol>(params: [String: String], password: String, in viewCtrl: T, callBackHandler: (( _ user: User,_ pass: String ) -> Void )? = nil) {
        AuthenticationDataManager.sharedInstance.loginUser(viewCtrl, fields: params) { (data, error) in
            if error == nil {
                var parsedCustomer: User?
                if let dictionay = data as? [String: Any], let customerEntity = dictionay[kDataContent] as? CustomerEntity, let customer = customerEntity.entity {
                    parsedCustomer = customer
                }
                if let dataSource = data as? CustomerEntity, let customer = dataSource.entity {
                    parsedCustomer = customer
                }
                if let customer = parsedCustomer {
                    CurrentUserManager.saveUser(user: customer, plainPassword: password)
                    if let identifier = params["login[identifier]"] {
                        self.trackSignIn(user: customer, identifier: identifier)
                    }
                    callBackHandler?(customer, password)
                }
                return
            } else if let error = error {
                viewCtrl.errorHandler?(error, forRequestID: 0)
            }
        }
    }
    
    private func trackSignIn(user: User?, identifier: String) {
        if let userID = user?.userID {
            Crashlytics.sharedInstance().setUserIdentifier("\(userID)")
        }
        if let name = user?.firstName, let lastName = user?.lastName {
            Crashlytics.sharedInstance().setUserName("\(name) \(lastName)")
        }
        if let email = user?.email {
            Crashlytics.sharedInstance().setUserEmail(email)
        }
        let regex = try! NSRegularExpression(pattern: String.phoneRegx(), options: [])
        let isMobile = regex.firstMatch(in: identifier, options: [], range: NSMakeRange(0, identifier.utf16.count)) != nil
        TrackerManager.postEvent(selector: EventSelectors.loginEventSelector(), attributes: EventAttributes.login(loginMethod: isMobile ? "phone" : "email", user: user, success: true))
    }
}
