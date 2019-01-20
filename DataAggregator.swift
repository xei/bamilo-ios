//
//  DataAggregator.swift
//  Bamilo
//
//  Created by Narbeh Mirzaei on 6/6/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

import Foundation

@objcMembers class DataAggregator: NSObject {
    
//######## MARK: - AuthenticationDataManager
//    class func loginUser(_ target:DataServiceProtocol?, username:String, password:String, completion: @escaping DataClosure) {
//        AuthenticationDataManager.sharedInstance.loginUser(target, username: username, password: password, completion: completion)
//    }
//    
//    class func signupUser(_ target:DataServiceProtocol?, with fields: [String : String], completion: @escaping DataClosure) {
//        var fields = fields //Hack!
//        AuthenticationDataManager.sharedInstance.signupUser(target, with: &fields, completion: completion)
//    }
//    
//    class func forgetPassword(_ target:DataServiceProtocol?, with fields:[String : String], completion: @escaping DataClosure) {
//        AuthenticationDataManager.sharedInstance.forgetPassword(target, with: fields, completion: completion)
//    }
//    
//    class func logoutUser(_ target:DataServiceProtocol?, completion: @escaping DataClosure) {
//        AuthenticationDataManager.sharedInstance.logoutUser(target, completion: completion)
//    }
    
//######## MARK: - AddressDataManager
    class func getUserAddressList(_ target: DataServiceProtocol, completion: @escaping DataClosure) {
        AddressDataManager.sharedInstance.getUserAddressList(target, requestType: .background, completion: completion)
    }
    
    class func setDefaultAddress(_ target: DataServiceProtocol, address: Address, isBilling: Bool, type: RequestExecutionType = .foreground, completion: @escaping DataClosure) {
        if let requestType = ApiRequestExecutionType(rawValue: Int(type.rawValue)) {
          AddressDataManager.sharedInstance.setDefaultAddress(target, address: address, isBilling: isBilling, type: requestType, completion: completion)
        }
    }
    
    class func addAddress(_ target: DataServiceProtocol, params: [String: Any], completion:@escaping DataClosure) {
        AddressDataManager.sharedInstance.addAddress(target, params: params, completion: completion)
    }
    
    class func updateAddress(_ target: DataServiceProtocol, params: [String:String], addressId: String, completion:@escaping DataClosure) {
        AddressDataManager.sharedInstance.updateAddress(target, params: params, id: addressId, completion: completion)
    }
    
    class func getAddress(_ target: DataServiceProtocol, id: String, completion:@escaping DataClosure) {
        AddressDataManager.sharedInstance.getAddress(target, id: id, requestType: .foreground, completion: completion)
    }
    
//    static func deleteAddress(_ target: DataServiceProtocol, address: Address, completion: @escaping DataClosure) {
//        AddressDataManager.sharedInstance.deleteAddress(target, address: address, completion: completion)
//    }
    
    class func getRegions(_ target: DataServiceProtocol, completion:@escaping DataClosure) {
        AddressDataManager.sharedInstance.getRegions(target, completion: completion)
    }
    
    class func getCities(_ target: DataServiceProtocol, regionId:String, completion:@escaping DataClosure) {
        AddressDataManager.sharedInstance.getCities(target, regionId: regionId, completion: completion)
    }
    
    class func getVicinity(_ target: DataServiceProtocol, cityId: String, completion:@escaping DataClosure) {
        AddressDataManager.sharedInstance.getVicinity(target, cityId: cityId, completion: completion)
    }
    
//######## MARK: - CheckoutDataManager
    class func getMultistepAddressList(_ target: DataServiceProtocol, completion:@escaping DataClosure) {
        CheckoutDataManager.sharedInstance.getMultistepAddressList(target, completion: completion)
    }
    
    class func setMultistepAddress(_ target: DataServiceProtocol, shipping:String, billing:String, completion:@escaping DataClosure) {
        CheckoutDataManager.sharedInstance.setMultistepAddress(target, shipping: shipping, billing: billing, completion: completion)
    }
    
    class func getMultistepConfirmation(_ target: DataServiceProtocol, completion:@escaping DataClosure) {
        CheckoutDataManager.sharedInstance.getMultistepConfirmation(target, type: .background, completion: completion)
    }
    
    class func getMultistepShipping(_ target: DataServiceProtocol, completion:@escaping DataClosure) {
        CheckoutDataManager.sharedInstance.getMultistepShipping(target, completion: completion)
    }
    
    class func getMultistepPayment(_ target: DataServiceProtocol, completion:@escaping DataClosure) {
        CheckoutDataManager.sharedInstance.getMultistepPayment(target, completion: completion)
    }
    
    class func setMultistepPayment(_ target: DataServiceProtocol, params:[String: String], completion:@escaping DataClosure) {
        CheckoutDataManager.sharedInstance.setMultistepPayment(target, params: params, completion: completion)
    }
    
    class func setMultistepConfirmation(_ target: DataServiceProtocol, cart:RICart, completion:@escaping DataClosure) {
        CheckoutDataManager.sharedInstance.setMultistepConfirmation(target, cart: cart, completion: completion)
    }
    
    class func applyVoucher(_ target: DataServiceProtocol, voucher:String, completion:@escaping DataClosure) {
        CheckoutDataManager.sharedInstance.applyVoucher(target, voucher: voucher, completion: completion)
    }
    
    class func removeVoucher(_ target: DataServiceProtocol, voucher:String, completion:@escaping DataClosure) {
        CheckoutDataManager.sharedInstance.removeVoucher(target, voucher: voucher, completion: completion)
    }
    
//######## MARK: - CartDataManager
    class func addProductToCart(_ target: DataServiceProtocol, simpleSku: String, completion:@escaping DataClosure) {
        CartDataManager.sharedInstance.addProductToCart(target, simpleSku: simpleSku, completion: completion)
    }
    
    class func getUserCart(_ target: DataServiceProtocol, completion:@escaping DataClosure) {
        CartDataManager.sharedInstance.getUserCart(target, type: .background, completion: completion)
    }

//######## MARK: - OrderDataManager
    class func getOrders(_ target: DataServiceProtocol, page:Int, perPageCount:Int, completion:@escaping DataClosure) {
        OrderDataManager.sharedInstance.getOrders(target, page: page, perPageCount: perPageCount, completion: completion)
    }
    
//######## MARK: - ProductDataManager
    class func addToWishList(target: DataServiceProtocol, sku: String, completion: @escaping DataCompletion) {
        //ProductDataManager.sharedInstance().wishListTransaction(isAdd: isAdd, target: target, sku: sku, completion: completion)
        ProductDataManager.sharedInstance.addToWishList(target, sku: sku, completion: completion)
    }
//######## MARK: - DeleteEntityDataManager
    class func removeFromWishList(target: DataServiceProtocol, sku: String, completion: @escaping DataCompletion) {
        DeleteEntityDataManager.sharedInstance().removeFromWishList(target, sku: sku, completion: completion)
    }
    
    class func deleteAddress(target: DataServiceProtocol, address: Address, completion: @escaping DataCompletion) {
        DeleteEntityDataManager.sharedInstance().deleteAddress(target, address: address, completion: completion)
    }
    
}
