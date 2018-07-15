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
    
    
    
    // ------------ helpers for viewControllers ------------
    func addOrRemoveFromWishList<T: BaseViewController & DataServiceProtocol>(product: Product, in viewCtrl: T,add: Bool, callBackHandler: ((_ success: Bool,_ error: Error?)->Void)? = nil) {
        if !RICustomer.checkIfUserIsLogged() {
            product.isInWishList.toggle()
            callBackHandler?(false, nil)
        }
        
        (viewCtrl.navigationController as? JACenterNavigationController)?.performProtectedBlock({ (userHadSession) in
            let translatedProduct = RIProduct()
            translatedProduct.sku = product.sku
            if let price = product.price {
                translatedProduct.price = NSNumber(value: price)
            }
            if add {
                ProductDataManager.sharedInstance.addToWishList(viewCtrl, sku: product.sku, completion: { (data, error) in
                    if error != nil {
                        product.isInWishList.toggle()
                        callBackHandler?(true, nil)
                        return
                    }
                    if product.isInWishList != true {
                        product.isInWishList.toggle()
                        callBackHandler?(false, error)
                    }
                    viewCtrl.showNotificationBar(error, isSuccess: false)
                })
                
                TrackerManager.postEvent(
                    selector: EventSelectors.addToWishListSelector(),
                    attributes: EventAttributes.addToWishList(product: translatedProduct, screenName: viewCtrl.getScreenName(), success: true)
                )
                
            } else {
                DeleteEntityDataManager.sharedInstance().removeFromWishList(viewCtrl, sku: product.sku, completion: { (data, error) in
                    if error != nil {
                        product.isInWishList.toggle()
                        callBackHandler?(true, nil)
                        TrackerManager.postEvent(
                            selector: EventSelectors.removeFromWishListSelector(),
                            attributes: EventAttributes.removeFromWishList(product: translatedProduct, screenName: viewCtrl.getScreenName())
                        )
                        return
                    }
                    
                    if product.isInWishList != false {
                        product.isInWishList.toggle()
                        callBackHandler?(false, error)
                    }
                    viewCtrl.showNotificationBar(error, isSuccess: false)
                })
            }
            
            //Inform others if it's needed
            NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationKeys.WishListUpdate), object: nil, userInfo: [NotificationKeys.NotificationProduct: product, NotificationKeys.NotificationBool: add])
        })
    }
    
    func addToCart<T: BaseViewController & DataServiceProtocol>(simpleSku: String, product: Product, viewCtrl: T, callBackHandler: ((_ success: Bool,_ error: Error?)->Void)? = nil) {
        CartDataManager.sharedInstance.addProductToCart(viewCtrl, simpleSku: simpleSku) { (data, error) in
            if error != nil {
                Utility.handleErrorMessages(error: error, viewController: viewCtrl)
                callBackHandler?(false, error)
                return
            }
            
            //EVENT: ADD TO CART
            TrackerManager.postEvent(selector: EventSelectors.addToCartEventSelector(), attributes: EventAttributes.addToCart(product: product, screenName: viewCtrl.getScreenName(), success: true))
            
            if let receivedData = data as? [String: Any], let messages = receivedData[DataManagerKeys.DataMessages] {
                viewCtrl.showMessage(viewCtrl.extractSuccessMessages(messages), showMessage: true)
            }
            
            if let receivedData = data as? [String: Any], let cart = receivedData[DataManagerKeys.DataContent] as? RICart {
                NotificationCenter.default.post(name: NSNotification.Name(NotificationKeys.UpdateCart), object: nil, userInfo: [NotificationKeys.NotificationCart : cart])
            }
            callBackHandler?(true, nil)
        }
    }
    
    
    func getOtherSellers(_ target: DataServiceProtocol, sku: String, cityId: String? = nil, completion:@escaping DataClosure) {
        
    }
    
}
