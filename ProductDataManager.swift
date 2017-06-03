//
//  ProductDataManager.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 5/23/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

import UIKit

class ProductDataManager: DataManagerSwift {

    override class func sharedInstance() -> ProductDataManager {
        return ProductDataManager()
    }
    
    func addToWishList(target: DataServiceProtocol, sku: String, completion: @escaping DataCompletion) {
        self.requestManager.async(.post, target: target, path:RI_API_ADD_TO_WISHLIST , params: ["sku": sku], type: .foreground, completion: { (responseType, data, errorMessages) in
            self.processResponse(responseType, aClass: nil, data: data, errorMessages: errorMessages, completion: completion)
        })
    }
    
    func removeFromWishList(target: DataServiceProtocol, sku: String, completion: @escaping DataCompletion) {
        self.requestManager.async(.delete, target: target, path:RI_API_REMOVE_FOM_WISHLIST, params: ["sku": sku], type: .foreground, completion: { (responseType, data, errorMessages) in
            self.processResponse(responseType, aClass: nil, data: data, errorMessages: errorMessages, completion: completion)
        })
    }
}
