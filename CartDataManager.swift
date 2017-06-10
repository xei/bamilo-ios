//
//  CartDataManager.swift
//  Bamilo
//
//  Created by Narbeh Mirzaei on 6/6/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

import Foundation

class CartDataManager: DataManagerSwift {
    static let sharedInstance = CartDataManager()
    
    func addProductToCart(_ target: DataServiceProtocol, simpleSku: String, completion:@escaping DataClosure) {
        let params = [
            "quantity" : "1",
            "sku" : simpleSku
        ]
        CartDataManager.requestManager.async(.post, target: target, path: RI_API_ADD_ORDER, params: params, type: .foreground) { (responseType, data, errorMessages) in
            self.processResponse(responseType, aClass: RICart.self, data: data, errorMessages: errorMessages, completion: completion)
        }
    }
    
    func getUserCart(_ target: DataServiceProtocol, completion:@escaping DataClosure) {
        CartDataManager.requestManager.async(.post, target: target, path: RI_API_GET_CART_DATA, params: nil, type: .foreground) { (responseType, data, errorMessages) in
            self.processResponse(responseType, aClass: RICart.self, data: data, errorMessages: errorMessages, completion: completion)
        }
    }
}
