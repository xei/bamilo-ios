//
//  ProductDataManager.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 5/23/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

import UIKit

@objc class ProductDataManager: DataManager {
    
    //TODO: Must be changed when we migrate all data managers
    private static let shared = ProductDataManager()
    override class func sharedInstance() -> ProductDataManager {
        return shared;
    }
    
    
    func whishListTransation(target: DataServiceProtocol, sku: String, add:Bool, completion: @escaping DataCompletion ) {
        if add {
            self.requestManager.asyncPOST(target, path: RI_API_ADD_TO_WISHLIST, params: ["sku": sku], type: .foreground, completion: { (responseStatus, data, errorMessages) in
                self.processResponse(responseStatus, of: nil, for: data, errorMessages: errorMessages, completion: completion)
            })
        } else {
            self.requestManager.asyncDELETE(target, path: RI_API_REMOVE_FOM_WISHLIST, params: ["sku": sku], type: .foreground, completion: { (responseStatus, data, errorMessages) in
                self.processResponse(responseStatus, of: nil, for: data, errorMessages: errorMessages, completion: completion)
            })
        }
    }
}
