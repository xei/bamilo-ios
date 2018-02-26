//
//  OrderDataManager.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 5/3/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

import Foundation

class OrderDataManager: DataManagerSwift {
    static let sharedInstance = OrderDataManager()
    
    func getOrders(_ target: DataServiceProtocol, page:Int, perPageCount:Int, completion:@escaping DataClosure) {
        let params = [
            "per_page" : perPageCount,
            "page" : page
        ]
        OrderDataManager.requestManager.async(.post, target: target, path: RI_API_GET_ORDERS, params: params, type: .background) { (responseType, data, errorMessages) in
            self.processResponse(responseType, aClass: OrderList.self, data: data, errorMessages: errorMessages, completion: completion)
        }
    }
    
    func getOrder(_ target: DataServiceProtocol, orderId: String, completion:@escaping DataClosure) {
        OrderDataManager.requestManager.async(.post, target: target, path: RI_API_TRACK_ORDER, params: ["ordernr" :orderId], type: .background) { (responseType, data, errorMessages) in
            self.processResponse(responseType, aClass: OrderItem.self, data: data, errorMessages: errorMessages, completion: completion)
        }
    }
    
    func cancelOrderItems(_ target: DataServiceProtocol, order: CancellingOrder, completion:@escaping DataClosure) {
        OrderDataManager.requestManager.async(.post, target: self, path: RI_API_CANCEL_ORDER, params: order.toJson(), type: .foreground) { (responseType, data, errorMessages) in
            self.processResponse(responseType, aClass: nil, data: data, errorMessages: errorMessages, completion: completion)
        }
    }
}


