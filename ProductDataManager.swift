//
//  ProductDataManager.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 5/23/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

import UIKit

extension ProductDataManager {
    func wishListTransaction(isAdd: Bool, target: DataServiceProtocol, sku: String, completion: @escaping DataCompletion) {
        if(isAdd) {
            self.addToWishList(target: target, sku: sku, completion: completion)
        } else {
            self.removeFromWishList(target: target, sku: sku, completion: completion)
        }
    }
}

class ProductDataManager: DataManagerSwift {
    static let sharedInstance = ProductDataManager()
    
    fileprivate func addToWishList(target: DataServiceProtocol, sku: String, completion: @escaping DataCompletion) {
        ProductDataManager.requestManager.async(.post, target: target, path:RI_API_ADD_TO_WISHLIST , params: ["sku": sku], type: .foreground, completion: { (responseType, data, errorMessages) in
            self.processResponse(responseType, aClass: nil, data: data, errorMessages: errorMessages, completion: completion)
        })
    }
    
    fileprivate func removeFromWishList(target: DataServiceProtocol, sku: String, completion: @escaping DataCompletion) {
        ProductDataManager.requestManager.async(.delete, target: target, path:RI_API_REMOVE_FOM_WISHLIST, params: ["sku": sku], type: .foreground, completion: { (responseType, data, errorMessages) in
            self.processResponse(responseType, aClass: nil, data: data, errorMessages: errorMessages, completion: completion)
        })
    }
}
