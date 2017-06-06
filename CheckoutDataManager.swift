//
//  CheckoutDataManager.swift
//  Bamilo
//
//  Created by Narbeh Mirzaei on 6/6/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

import Foundation

class CheckoutDataManager: DataManager {
    
    //TODO: Must be changed when we migrate all data managers
    private static let shared = CheckoutDataManager()
    override class func sharedInstance() -> CheckoutDataManager {
        return shared
    }
    
    func getMultistepAddressList(_ target: DataServiceProtocol, completion:@escaping DataCompletion) {
        self.requestManager.asyncGET(target, path: RI_API_MULTISTEP_GET_ADDRESSES, params: nil, type: .foreground) { (statusCode, data, errorMessages) in
            self.processResponse(statusCode, of: RICart.self, for: data, errorMessages: errorMessages, completion: completion)
        }
    }
    
    func setMultistepAddress(_ target: DataServiceProtocol, shipping:String, billing:String, completion:@escaping DataCompletion) {
        let params = [
            "addresses[shipping_id]" : shipping,
            "addresses[billing_id]" : billing
        ]
        self.requestManager.asyncPOST(target, path: RI_API_MULTISTEP_SUBMIT_ADDRESSES, params: params, type: .foreground) { (statusCode, data, errorMessages) in
            self.processResponse(statusCode, of: MultistepEntity.self, for: data, errorMessages: errorMessages, completion: completion)
        }
    }
    
    func getMultistepConfirmation(_ target: DataServiceProtocol, type: RequestExecutionType, completion:@escaping DataCompletion) {
        self.requestManager.asyncGET(target, path: RI_API_MULTISTEP_GET_FINISH, params: nil, type: type) { (statusCode, data, errorMessages) in
            self.processResponse(statusCode, of: RICart.self, for: data, errorMessages: errorMessages, completion: completion)
        }
    }
    
    func getMultistepShipping(_ target: DataServiceProtocol, completion:@escaping DataCompletion) {
        self.requestManager.asyncGET(target, path: RI_API_MULTISTEP_GET_SHIPPING, params: nil, type: .foreground) { (statusCode, data, errorMessages) in
            self.processResponse(statusCode, of: RICart.self, for: data, errorMessages: errorMessages, completion: completion)
        }
    }
    
    //func setMultistepShipping(_ target: DataServiceProtocol, shippingMethod:String, pickupStation:String, region:String, completion:@escaping DataCompletion) {}
    
    func getMultistepPayment(_ target: DataServiceProtocol, completion:@escaping DataCompletion) {
        self.requestManager.asyncGET(target, path: RI_API_MULTISTEP_GET_PAYMENT, params: nil, type: .container) { (statusCode, data, errorMessages) in
            self.processResponse(statusCode, of: RICart.self, for: data, errorMessages: errorMessages, completion: completion)
        }
    }
    
    func setMultistepPayment(_ target: DataServiceProtocol, params:[String: String], completion:@escaping DataCompletion) {
        self.requestManager.asyncPOST(target, path: RI_API_MULTISTEP_SUBMIT_PAYMENT, params: params, type: .container) { (statusCode, data, errorMessages) in
            self.processResponse(statusCode, of: MultistepEntity.self, for: data, errorMessages: errorMessages, completion: completion)
        }
    }
    
    func setMultistepConfirmation(_ target: DataServiceProtocol, cart:RICart, completion:@escaping DataCompletion) {
        let params = [
            "app" : "ios",
            "customer_device": UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad ? "tablet" : "mobile"
        ]
        self.requestManager.asyncPOST(target, path: RI_API_MULTISTEP_SUBMIT_FINISH, params: params, type: .foreground) { (statusCode, data, errorMessages) in
            if errorMessages != nil {
                completion(nil, self.getErrorFrom(statusCode, errorMessages: errorMessages))
            } else {
                completion(RICart.parseCheckoutFinish(data?.metadata, for:cart), nil)
            }
        }
    }
    
    func applyVoucher(_ target: DataServiceProtocol, voucher:String, completion:@escaping DataCompletion) {
        let params = [
            "couponcode" : voucher
        ]
        self.requestManager.asyncPOST(target, path: RI_API_ADD_VOUCHER_TO_CART, params: params, type: .foreground) { (statusCode, data, errorMessages) in
            self.processResponse(statusCode, of: RICart.self, for: data, errorMessages: errorMessages, completion: completion)
        }
    }
    
    func removeVoucher(_ target: DataServiceProtocol, voucher:String, completion:@escaping DataCompletion) {
        let params = [
            "couponcode" : voucher
        ]
        self.requestManager.asyncDELETE(target, path: RI_API_REMOVE_VOUCHER_FROM_CART, params: params, type: .foreground) { (statusCode, data, errorMessages) in
            self.processResponse(statusCode, of: RICart.self, for: data, errorMessages: errorMessages, completion: completion)
        }
    }
}
