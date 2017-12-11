//
//  CheckoutDataManager.swift
//  Bamilo
//
//  Created by Narbeh Mirzaei on 6/6/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

import Foundation

class CheckoutDataManager: DataManagerSwift {
    static let sharedInstance = CheckoutDataManager()
    
    func getMultistepAddressList(_ target: DataServiceProtocol, completion:@escaping DataClosure) {
        CheckoutDataManager.requestManager.async(.get, target: target, path: RI_API_MULTISTEP_GET_ADDRESSES, params: nil, type: .foreground) { (responseType, data, errorMessages) in
            self.processResponse(responseType, aClass: RICart.self, data: data, errorMessages: errorMessages, completion: completion)
        }
    }
    
    func setMultistepAddress(_ target: DataServiceProtocol, shipping:String, billing:String, completion:@escaping DataClosure) {
        let params = [
            "addresses[shipping_id]" : shipping,
            "addresses[billing_id]" : billing
        ]
        CheckoutDataManager.requestManager.async(.post, target: target, path: RI_API_MULTISTEP_SUBMIT_ADDRESSES, params: params, type: .foreground) { (responseType, data, errorMessages) in
            self.processResponse(responseType, aClass: MultistepEntity.self, data: data, errorMessages: errorMessages, completion: completion)
        }
    }
    
    func getMultistepConfirmation(_ target: DataServiceProtocol, type: ApiRequestExecutionType, completion:@escaping DataClosure) {
        CheckoutDataManager.requestManager.async(.get, target: target, path: RI_API_MULTISTEP_GET_FINISH, params: nil, type: type) { (responseType, data, errorMessages) in
            self.processResponse(responseType, aClass: RICart.self, data: data, errorMessages: errorMessages, completion: completion)
        }
    }
    
    func getMultistepShipping(_ target: DataServiceProtocol, completion:@escaping DataClosure) {
        CheckoutDataManager.requestManager.async(.get, target: target, path: RI_API_MULTISTEP_GET_SHIPPING, params: nil, type: .foreground) { (responseType, data, errorMessages) in
            self.processResponse(responseType, aClass: RICart.self, data: data, errorMessages: errorMessages, completion: completion)
        }
    }
    
    //func setMultistepShipping(_ target: DataServiceProtocol, shippingMethod:String, pickupStation:String, region:String, completion:@escaping DataCompletion) {}
    
    func getMultistepPayment(_ target: DataServiceProtocol, completion:@escaping DataClosure) {
        CheckoutDataManager.requestManager.async(.get, target: target, path: RI_API_MULTISTEP_GET_PAYMENT, params: nil, type: .container) { (responseType, data, errorMessages) in
            self.processResponse(responseType, aClass: RICart.self, data: data, errorMessages: errorMessages, completion: completion)
        }
    }
    
    func setMultistepPayment(_ target: DataServiceProtocol, params:[String: String], completion:@escaping DataClosure) {
        CheckoutDataManager.requestManager.async(.post, target: target, path: RI_API_MULTISTEP_SUBMIT_PAYMENT, params: params, type: .container) { (responseType, data, errorMessages) in
            self.processResponse(responseType, aClass: MultistepEntity.self, data: data, errorMessages: errorMessages, completion: completion)
        }
    }
    
    func setMultistepConfirmation(_ target: DataServiceProtocol, cart:RICart, completion:@escaping DataClosure) {
        let params = [
            "app" : "ios",
            "customer_device": UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad ? "tablet" : "mobile"
        ]
        CheckoutDataManager.requestManager.async(.post, target: target, path: RI_API_MULTISTEP_SUBMIT_FINISH, params: params, type: .foreground) { (responseType, data, errorMessages) in
            if errorMessages != nil || data == nil {
                completion(nil, self.createError(responseType, errorMessages: errorMessages))
            } else {
                completion(RICart.parseCheckoutFinish(data?.metadata, for:cart), nil)
            }
        }
    }
    
    func applyVoucher(_ target: DataServiceProtocol, voucher:String, completion:@escaping DataClosure) {
        let params = [
            "couponcode" : voucher
        ]
        CheckoutDataManager.requestManager.async(.post, target: target, path: RI_API_ADD_VOUCHER_TO_CART, params: params, type: .foreground) { (responseType, data, errorMessages) in
            self.processResponse(responseType, aClass: RICart.self, data: data, errorMessages: errorMessages, completion: completion)
        }
    }
    
    func removeVoucher(_ target: DataServiceProtocol, voucher:String, completion:@escaping DataClosure) {
        let params = [
            "couponcode" : voucher
        ]
        CheckoutDataManager.requestManager.async(.delete, target: target, path: RI_API_REMOVE_VOUCHER_FROM_CART, params: params, type: .foreground) { (responseType, data, errorMessages) in
            self.processResponse(responseType, aClass: RICart.self, data: data, errorMessages: errorMessages, completion: completion)
        }
    }
}
