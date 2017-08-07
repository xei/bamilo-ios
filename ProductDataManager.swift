//
//  ProductDataManager.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 5/23/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

import Foundation


class ProductDataManager: DataManagerSwift {
    static let sharedInstance = ProductDataManager()
    
    func addToWishList(_ target: DataServiceProtocol, sku: String, completion: @escaping DataClosure) {
        ProductDataManager.requestManager.async(.post, target: target, path:RI_API_ADD_TO_WISHLIST , params: ["sku": sku], type: .foreground, completion: { (responseType, data, errorMessages) in
            self.processResponse(responseType, aClass: nil, data: data, errorMessages: errorMessages, completion: completion)
        })
    }
}
