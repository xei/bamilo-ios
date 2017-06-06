//
//  CartDataManager.swift
//  Bamilo
//
//  Created by Narbeh Mirzaei on 6/6/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

import Foundation

class CartDataManager: DataManager {
    
    //TODO: Must be changed when we migrate all data managers
    private static let shared = CartDataManager()
    override class func sharedInstance() -> CartDataManager {
        return shared
    }
    
    func addProductToCart(_ target: DataServiceProtocol, simpleSku: String, completion:@escaping DataCompletion) {
        let params = [
            "quantity" : "1",
            "sku" : simpleSku
        ]
        self.requestManager.asyncPOST(target, path: RI_API_ADD_ORDER, params: params, type: .foreground) { (statusCode, data, errorMessages) in
            self.processResponse(statusCode, of: RICart.self, for: data, errorMessages: errorMessages, completion: completion)
        }
    }
    
    func getUserCart(_ target: DataServiceProtocol, completion:@escaping DataCompletion) {
        self.requestManager.asyncPOST(target, path: RI_API_GET_CART_DATA, params: nil, type: .foreground) { (statusCode, data, errorMessages) in
            self.processResponse(statusCode, of: RICart.self, for: data, errorMessages: errorMessages, completion: completion)
        }
    }
}
