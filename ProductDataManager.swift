//
//  ProductDataManager.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 5/23/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

import Foundation
import SwiftyJSON

class ProductDataManager: DataManagerSwift {
    
    static let sharedInstance = ProductDataManager()
    func getProductDetailInfo(_ target: DataServiceProtocol, sku: String, completion: @escaping DataClosure) {
        ProductDataManager.requestManager.async(.get, target: target, path: "\(RI_API_PRODUCT_DETAIL)\(sku)", params: nil, type: .foreground) { (responseType, data, errorMessages) in
            self.processResponse(responseType, aClass: Product.self, data: data, errorMessages: errorMessages, completion: completion)
        }
    }
    
    func addToWishList(_ target: DataServiceProtocol, sku: String, completion: @escaping DataClosure) {
        ProductDataManager.requestManager.async(.post, target: target, path:RI_API_ADD_TO_WISHLIST , params: ["sku": sku], type: .background, completion: { (responseType, data, errorMessages) in
            self.processResponse(responseType, aClass: nil, data: data, errorMessages: errorMessages, completion: completion)
        })
    }
    
    func getDeliveryTime(_ target: DataServiceProtocol, sku: String, cityId: String? = nil, completion:@escaping DataClosure) {
        var params: [String: Any] = ["skus": [sku]];
        if let cityId = cityId {
            params["city-id"] = cityId
        }
        ProductDataManager.requestManager.async(.post, target: target, path: RI_API_DELIVERY_TIME, params: params, type: .foreground) { (responseType, data, errorMessages) in

            self.processResponse(responseType, aClass: DeliveryTimes.self, data: data, errorMessages: errorMessages, completion: completion)
        }
    }
    
    func getWishListProducts(_ target: DataServiceProtocol, page:Int, perPageCount:Int, completion:@escaping DataClosure) {
        let params = [
            "per_page" : perPageCount,
            "page" : page
        ]
        ProductDataManager.requestManager.async(.post, target: target, path: RI_API_GET_WISHLIST, params: params, type: .background) { (reseponseType, data, errorMessages) in
            self.processResponse(reseponseType, aClass: WishList.self, data: data, errorMessages: errorMessages, completion: completion)
        }
    }
}
