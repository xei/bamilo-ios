//
//  DeleteEntityDataManager.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 6/20/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

import UIKit

class DeleteEntityDataManager: DataManager {
    //TODO: Must be changed when we migrate all data managers
    private static let shared = DeleteEntityDataManager()
    override class func sharedInstance() -> DeleteEntityDataManager {
        return shared;
    }
    
    
    
    func removeFromWishList(_ target: DataServiceProtocol, sku: String, completion: @escaping DataCompletion) {
        self.requestManager.asyncDELETE(target, path: RI_API_REMOVE_FOM_WISHLIST, params: ["sku": sku], type: .foreground, completion: { (responseStatus, data, errorMessages) in
            self.processResponse(responseStatus, of: nil, for: data, errorMessages: errorMessages, completion: completion)
        })
    }
    
    
    func deleteAddress(_ target: DataServiceProtocol, address: Address, completion: @escaping DataCompletion) {
        self.requestManager.asyncDELETE(target, path: RI_API_DELETE_ADDRESS_REMOVE, params: ["id": address.uid], type: .container, completion: {(responseStatus, data, errorMessages) in
            self.processResponse(responseStatus, of: nil, for: data, errorMessages: errorMessages, completion: completion)
        })
    }
}
