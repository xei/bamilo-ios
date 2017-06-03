//
//  OrderDataManager.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 5/3/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

import Foundation

class OrderDataManager: DataManager {
    
    //TODO: Must be changed when we migrate all data managers
    private static let shared = OrderDataManager()
    override class func sharedInstance() -> OrderDataManager {
        return shared
    }
    
    func getOrders(_ target: DataServiceProtocol, page:Int, perPageCount:Int, completion:@escaping DataCompletion) {
        let params = [
            "per_page" : perPageCount,
            "page" : page
        ]
        self.requestManager.asyncPOST(target, path: RI_API_GET_ORDERS, params: params, type: .foreground) { (statusCode, data, errorMessages) in
            self.processResponse(statusCode, of: OrderList.self, for: data, errorMessages: errorMessages, completion: completion)
        }
    }
    
    func getOrder(_ target: DataServiceProtocol, orderId: String, completion:@escaping DataCompletion) {
        self.requestManager.asyncPOST(target, path: "\(RI_API_TRACK_ORDER)\(orderId)", params: nil, type: .foreground) { (statusCode, data, errorMessages) in
            self.processResponse(statusCode, of: Order.self, for: data, errorMessages: errorMessages, completion: completion)
        }
    }
}


