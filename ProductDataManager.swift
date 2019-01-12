//
//  ProductDataManager.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 5/23/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

import Foundation
import SwiftyJSON

@objc protocol TrackableProductProtocol: class {
    var name: String? { get set }
    var brand: String? { get set }
    var sku: String! { get set }
    var simpleSku: String! { get set }
    var isInWishList: Bool { get set }
    var payablePrice: NSNumber? { get }
    var categoryUrlKey: String? { get }
}

class ProductDataManager: DataManagerSwift {
    
    static let sharedInstance = ProductDataManager()
    func getProductDetailInfo(_ target: DataServiceProtocol, sku: String, completion: @escaping DataClosure) {
        ProductDataManager.requestManager.async(.get, target: target, path: "\(RI_API_PRODUCT_DETAIL)\(sku)", params: nil, type: .foreground) { (responseType, data, errorMessages) in
            self.processResponse(responseType, aClass: NewProduct.self, data: data, errorMessages: errorMessages, completion: completion)
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
    
    func getReviewsList(_ target: DataServiceProtocol, sku: String, pageNumber: Int, type: ApiRequestExecutionType, completion:@escaping DataClosure) {
        ProductDataManager.requestManager.async(.get, target: target, path: "\(RI_API_REVIEW_LIST)\(sku)/page/\(pageNumber)", params: nil, type: type) { (responseType, data, errorMessages) in
            self.processResponse(responseType, aClass: ProductReview.self, data: data, errorMessages: errorMessages, completion: completion)
        }
    }
    
    func getOtherSellers(_ target: DataServiceProtocol, sku: String, cityId: String? = nil, completion:@escaping DataClosure) {
        ProductDataManager.requestManager.async(.get, target: target, path: "\(RI_API_SELLERS_OFFER)\(sku)", params: nil, type: .foreground) { (responseType, data, errorMessages) in
            self.processResponse(responseType, aClass: SellerList.self, data: data, errorMessages: errorMessages, completion: completion)
        }
    }
    
    func getDescriptions(_ target: DataServiceProtocol, sku: String, completion:@escaping DataClosure) {
        ProductDataManager.requestManager.async(.get, target: target, path: "\(RI_API_PRODUCT_DESCRIPTIONS)\(sku)", params: nil, type: .foreground) { (responseType, data, errorMessages) in
            self.processResponse(responseType, aClass: ProductDescriptionWrapper.self, data: data, errorMessages: errorMessages, completion: completion)
        }
    }
    
    func getSpecifications(_ target: DataServiceProtocol, sku: String, completion:@escaping DataClosure) {
        ProductDataManager.requestManager.async(.get, target: target, path: "\(RI_API_SPECIFICATION)\(sku)", params: nil, type: .foreground) { (responseType, data, errorMessages) in
            self.processResponse(responseType, aClass: ProductSpecifics.self, data: data, errorMessages: errorMessages, completion: completion)
        }
    }
    
    func getReturnPolicy(_ target: DataServiceProtocol, returnPolicyKey: String, completion:@escaping DataClosure) {
        ProductDataManager.requestManager.async(.get, target: target, path: "\(RI_API_RETURN_POLICY)\(returnPolicyKey)", params: nil, type: .foreground) { (responseType, data, errorMessages) in
            self.processResponse(responseType, aClass: ProductReturnPolicyContent.self, data: data, errorMessages: errorMessages, completion: completion)
        }
    }
    
    func addReview(_ target: DataServiceProtocol, sku: String, rate: Int, title: String?, comment: String?, completion:@escaping DataClosure) {
        var params: [String: Any] = [
            "sku": sku,
            "rate": rate
            ]
        if let title = title { params["title"] = title }
        if let comment = comment { params["comment"] = comment }
        
        ProductDataManager.requestManager.async(.post, target: target, path: RI_API_ADD_PRODUCT_REVIEW, params: params, type: .foreground) { (responseType, data, errorMessages) in
            self.processResponse(responseType, aClass: nil, data: data, errorMessages: errorMessages, completion: completion)
        }
    }
    
    // ------------ helpers for viewControllers ------------
    func addOrRemoveFromWishList<T: BaseViewController & DataServiceProtocol>(product: TrackableProductProtocol, in viewCtrl: T,add: Bool, callBackHandler: ((_ success: Bool,_ error: Error?)->Void)? = nil) {
        if !CurrentUserManager.isUserLoggedIn() {
            product.isInWishList.toggle()
            callBackHandler?(false, nil)
        }
        
        (viewCtrl.navigationController as? JACenterNavigationController)?.performProtectedBlock({ (userHadSession) in
            //Inform others if it's needed
            NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationKeys.WishListUpdate), object: nil, userInfo: [NotificationKeys.NotificationProduct: product, NotificationKeys.NotificationBool: add])
            if add {
                ProductDataManager.sharedInstance.addToWishList(viewCtrl, sku: product.sku, completion: { (data, error) in
                    
                    TrackerManager.postEvent(
                        selector: EventSelectors.addToWishListSelector(),
                        attributes: EventAttributes.addToWishList(product: product, screenName: viewCtrl.getScreenName(), success: error == nil)
                    )
                    
                    if error != nil {
                        product.isInWishList.toggle()
                        viewCtrl.showNotificationBar(error, isSuccess: false)
                        callBackHandler?(false, nil)
                        return
                    }
                    if product.isInWishList != true {
                        product.isInWishList = true
                        callBackHandler?(true, nil)
                    }
                })
                
            } else {
                DeleteEntityDataManager.sharedInstance().removeFromWishList(viewCtrl, sku: product.sku, completion: { (data, error) in
                
                    if error != nil {
                        product.isInWishList.toggle()
                        viewCtrl.showNotificationBar(error, isSuccess: false)
                        callBackHandler?(false, nil)
                        return
                    }
                    
                    TrackerManager.postEvent(
                        selector: EventSelectors.removeFromWishListSelector(),
                        attributes: EventAttributes.removeFromWishList(product: product, screenName: viewCtrl.getScreenName())
                    )
                    
                    if product.isInWishList != false {
                        product.isInWishList = false
                        callBackHandler?(true, error)
                    }
                })
            }
        })
    }
    
    func addToCart<T: BaseViewController & DataServiceProtocol>(simpleSku: String, product: TrackableProductProtocol, viewCtrl: T, callBackHandler: ((_ success: Bool,_ error: Error?)->Void)? = nil) {
        CartDataManager.sharedInstance.addProductToCart(viewCtrl, simpleSku: simpleSku) { (data, error) in
            if error != nil {
                Utility.handleErrorMessages(error: error, viewController: viewCtrl)
                callBackHandler?(false, error)
                return
            }
            
            //EVENT: ADD TO CART
            product.simpleSku = simpleSku
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
}
