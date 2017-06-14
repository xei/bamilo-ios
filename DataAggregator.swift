//
//  DataAggregator.swift
//  Bamilo
//
//  Created by Narbeh Mirzaei on 6/6/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

import Foundation

@objc class DataAggregator: NSObject {
    
//######## MARK: - AuthenticationDataManager
    static func loginUser(_ target:DataServiceProtocol, username:String, password:String, completion: @escaping DataClosure) {
        AuthenticationDataManager.sharedInstance.loginUser(target, username: username, password: password, completion: completion)
    }
    
    static func signupUser(_ target:DataServiceProtocol, with fields: [String : String], completion: @escaping DataClosure) {
        var fields = fields //Hack!
        AuthenticationDataManager.sharedInstance.signupUser(target, with: &fields, completion: completion)
    }
    
    static func forgetPassword(_ target:DataServiceProtocol, with fields:[String : String], completion: @escaping DataClosure) {
        AuthenticationDataManager.sharedInstance.forgetPassword(target, with: fields, completion: completion)
    }
    
    static func logoutUser(_ target:DataServiceProtocol, completion: @escaping DataClosure) {
        AuthenticationDataManager.sharedInstance.logoutUser(target, completion: completion)
    }
    
//######## MARK: - AddressDataManager
    static func getUserAddressList(_ target: DataServiceProtocol, completion: @escaping DataClosure) {
        AddressDataManager.sharedInstance.getUserAddressList(target, completion: completion)
    }
    
    static func setDefaultAddress(_ target: DataServiceProtocol, address: Address, isBilling: Bool, completion: @escaping DataClosure) {
        AddressDataManager.sharedInstance.setDefaultAddress(target, address: address, isBilling: isBilling, completion: completion)
    }
    
    static func addAddress(_ target: DataServiceProtocol, params: [String:String], completion:@escaping DataClosure) {
        AddressDataManager.sharedInstance.addAddress(target, params: params, completion: completion)
    }
    
    static func updateAddress(_ target: DataServiceProtocol, params: [String:String], addressId: String, completion:@escaping DataClosure) {
        AddressDataManager.sharedInstance.updateAddress(target, params: params, id: addressId, completion: completion)
    }
    
    static func getAddress(_ target: DataServiceProtocol, id: String, completion:@escaping DataClosure) {
        AddressDataManager.sharedInstance.getAddress(target, id: id, completion: completion)
    }
    
    static func deleteAddress(_ target: DataServiceProtocol, address: Address, completion: @escaping DataClosure) {
        AddressDataManager.sharedInstance.deleteAddress(target, address: address, completion: completion)
    }
    
    static func getRegions(_ target: DataServiceProtocol, completion:@escaping DataClosure) {
        AddressDataManager.sharedInstance.getRegions(target, completion: completion)
    }
    
    static func getCities(_ target: DataServiceProtocol, regionId:String, completion:@escaping DataClosure) {
        AddressDataManager.sharedInstance.getCities(target, regionId: regionId, completion: completion)
    }
    
    static func getVicinity(_ target: DataServiceProtocol, cityId: String, completion:@escaping DataClosure) {
        AddressDataManager.sharedInstance.getVicinity(target, cityId: cityId, completion: completion)
    }
    
//######## MARK: - CheckoutDataManager
    static func getMultistepAddressList(_ target: DataServiceProtocol, completion:@escaping DataClosure) {
        CheckoutDataManager.sharedInstance.getMultistepAddressList(target, completion: completion)
    }
    
    static func setMultistepAddress(_ target: DataServiceProtocol, shipping:String, billing:String, completion:@escaping DataClosure) {
        CheckoutDataManager.sharedInstance.setMultistepAddress(target, shipping: shipping, billing: billing, completion: completion)
    }
    
    static func getMultistepConfirmation(_ target: DataServiceProtocol, type: RequestExecutionType, completion:@escaping DataClosure) {
        var requestType: ApiRequestExecutionType
        switch type {
            case .background:
                requestType = .background
            break
            
            case .container:
                requestType = .container
            break
            
            default:
                requestType = .foreground
        }
        
        CheckoutDataManager.sharedInstance.getMultistepConfirmation(target, type: requestType, completion: completion)
    }
    
    static func getMultistepShipping(_ target: DataServiceProtocol, completion:@escaping DataClosure) {
        CheckoutDataManager.sharedInstance.getMultistepShipping(target, completion: completion)
    }
    
    static func getMultistepPayment(_ target: DataServiceProtocol, completion:@escaping DataClosure) {
        CheckoutDataManager.sharedInstance.getMultistepPayment(target, completion: completion)
    }
    
    static func setMultistepPayment(_ target: DataServiceProtocol, params:[String: String], completion:@escaping DataClosure) {
        CheckoutDataManager.sharedInstance.setMultistepPayment(target, params: params, completion: completion)
    }
    
    static func setMultistepConfirmation(_ target: DataServiceProtocol, cart:RICart, completion:@escaping DataClosure) {
        CheckoutDataManager.sharedInstance.setMultistepConfirmation(target, cart: cart, completion: completion)
    }
    
    static func applyVoucher(_ target: DataServiceProtocol, voucher:String, completion:@escaping DataClosure) {
        CheckoutDataManager.sharedInstance.applyVoucher(target, voucher: voucher, completion: completion)
    }
    
    static func removeVoucher(_ target: DataServiceProtocol, voucher:String, completion:@escaping DataClosure) {
        CheckoutDataManager.sharedInstance.removeVoucher(target, voucher: voucher, completion: completion)
    }
    
//######## MARK: - CartDataManager
    static func addProductToCart(_ target: DataServiceProtocol, simpleSku: String, completion:@escaping DataClosure) {
        CartDataManager.sharedInstance.addProductToCart(target, simpleSku: simpleSku, completion: completion)
    }
    
    static func getUserCart(_ target: DataServiceProtocol, completion:@escaping DataClosure) {
        CartDataManager.sharedInstance.getUserCart(target, completion: completion)
    }

//######## MARK: - OrderDataManager
    static func getOrders(_ target: DataServiceProtocol, page:Int, perPageCount:Int, completion:@escaping DataClosure) {
        OrderDataManager.sharedInstance.getOrders(target, page: page, perPageCount: perPageCount, completion: completion)
    }
    
    static func getOrder(_ target: DataServiceProtocol, orderId: String, completion:@escaping DataClosure) {
        OrderDataManager.sharedInstance.getOrder(target, orderId: orderId, completion: completion)
    }
    
//######## MARK: - ProductDataManager
    static func wishListTransaction(isAdd: Bool, target: DataServiceProtocol, sku: String, completion: @escaping DataCompletion) {
        ProductDataManager.sharedInstance().wishListTransaction(isAdd: isAdd, target: target, sku: sku, completion: completion)
    }
}
