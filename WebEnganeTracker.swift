//
//  WebEnganeTracker.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 10/27/18.
//  Copyright © 2018 Rocket Internet. All rights reserved.
//
// ----- this tracker's parameteres are related to 'TRACKING PROTOCOL API V1.0' -----

import UIKit

class WebEnganeTracker: BaseTracker, EventTrackerProtocol, ScreenTrackerProtocol {
    
    private let analytics: WEGAnalytics = WebEngage.sharedInstance().analytics
    private let trackingWeUser: WEGUser = WebEngage.sharedInstance().user
    
    //TODO: Must be changed when we migrate all Trackers
    private static var sharedInstance: WebEnganeTracker? // = AdjustTracker()
    override class func shared() -> WebEnganeTracker {
        if sharedInstance == nil {
            sharedInstance = WebEnganeTracker()
        }
        return sharedInstance!
    }
    
    func login(attributes: EventAttributeType) {
        if let user = attributes[kEventUser] as? User {
            syncUser(user: user)
            analytics.trackEvent(withName: "User_Login")
        }
    }
    
    func signup(attributes: EventAttributeType) {
        if let user = attributes[kEventUser] as? User {
            syncUser(user: user)
            analytics.trackEvent(withName: "User_Register")
        }
    }
    
    func logout(attributes: EventAttributeType) {
        trackingWeUser.logout()
        analytics.trackEvent(withName: "User_Logout")
    }
    
    func addToCart(attributes: EventAttributeType) {
        if let product = attributes[kEventProduct] as? TrackableProductProtocol {
            let addedToCartAttributes: [String:Any]  = [
                "Price": product.payablePrice?.intValue ?? 0,
                "Quantity": 1,
                "Product_ID": product.sku ?? "",
                "Product_Name": product.name ?? "",
                "Category_URL": product.categoryUrlKey ?? "",
            ]
            analytics.trackEvent(withName: "Purchase_Add_To_Cart", andValue: addedToCartAttributes)
        }
    }
    
    func buyNowTapped(attributes: EventAttributeType) {
        if let product = attributes[kEventProduct] as? TrackableProductProtocol,
            let price = product.payablePrice {
            let buyNowAttributes: [String:Any]  = [
                "Price": price.intValue,
                "Quantity": 1,
                "Product_ID": product.sku ?? "",
                "Product_Name": product.name ?? "",
                "Category_URL": product.categoryUrlKey ?? "",
            ]
            
            analytics.trackEvent(withName: "Purchase_Buy_Now_Click", andValue: buyNowAttributes)
        }
    }
    
    func viewProduct(attributes: EventAttributeType) {
        if let parentScreenName = attributes[kEventScreenName] as? String,
            let product = attributes[kEventProduct] as? TrackableProductProtocol {
            let viewProductAttributes: [String:Any]  = [
                "Price": product.payablePrice?.intValue ?? 0,
                "Quantity": 1,
                "Product_ID": product.sku ?? "",
                "Product_Name": product.name ?? "",
                "Category_URL": product.categoryUrlKey ?? "",
                "Previous_View_name": parentScreenName
            ]
            
            analytics.trackEvent(withName: "Product_View", andValue: viewProductAttributes)
        }
    }
    
    func removeFromCart(attributes: EventAttributeType) {
        if let product = attributes[kEventProduct] as? TrackableProductProtocol {
            analytics.trackEvent(withName: "Purchase_Remove_From_Cart", andValue: [
                "Price": product.payablePrice?.intValue ?? 0,
                "Product_ID": product.sku ?? "",
                "Product_Name": product.name ?? "",
            ])
        }
    }
    
    func addToWishList(attributes: EventAttributeType) {
//        if let screenName = attributes[kEventScreenName] as? String,
//            let product = attributes[kEventProduct] as? TrackableProductProtocol,
//            let price = product.payablePrice {
//            analytics.trackEvent(withName: "add_to_wishlist", andValue: [
//                "product_sku": product.sku ?? "",
//                "screen": screenName,
//                "price": price.intValue
//            ])
//        }
    }
    
    func removeFromWishList(attributes: EventAttributeType) {
//        if let product = attributes[kEventProduct] as? TrackableProductProtocol,
//            let price = product.payablePrice {
//            analytics.trackEvent(withName: "remove_from_wishlist", andValue: ["product_sku": product.sku ?? "",
//                                                                              "price": price.intValue])
//        }
    }
    
    func search(attributes: EventAttributeType) {
//        if let target = (attributes[kEventSearchTarget] as? RITarget), target.targetType == .CATALOG_CATEGORY  {
//            analytics.trackEvent(withName: "category_search", andValue: ["category_url": target.node])
//        }
    }
    
    func searchbarSearched(attributes: EventAttributeType) {
//        if let searchString = attributes[kEventKeywords] as? String {
//            analytics.trackEvent(withName: "searchbar_search", andValue: ["query": searchString])
//        }
    }
    
    func checkoutStart(attributes: EventAttributeType) {
        if let cart = attributes[kEventCart] as? RICart {
            let numberOfProducts = cart.cartEntity?.cartCount?.intValue ?? 0
            let cartValue = cart.cartEntity?.cartValue?.intValue ?? 0
            
            analytics.trackEvent(withName: "Purchase_Chekout_Start", andValue: [
                "Cart_Value": cartValue,
                "No_Of_Products": numberOfProducts
            ])
        }
    }
    
    func checkoutFinished(attributes: EventAttributeType) {
        if let cart = attributes[kEventCart] as? RICart {
            let cartValue = cart.cartEntity?.cartValue?.intValue ?? 0
            let numberOfProducts = cart.cartEntity?.cartCount?.intValue ?? 0
            analytics.trackEvent(withName: "Purchase_Checkout_Complete", andValue: [
                "Cart_Value": cartValue,
                "No_Of_Products": numberOfProducts,
            ])
        }
    }
    
    func purchased(attributes: EventAttributeType) {
        if let cart = attributes[kEventCart] as? RICart,
            let success = attributes[kEventSuccess] as? Bool, !success {
            let orderNumber = cart.orderNr ?? ""
            let cartValue = cart.cartEntity?.cartValue?.intValue ?? 0
            let cityName = cart.cartEntity?.address?.city ?? "NotSet"
            let numberOfProducts = cart.cartEntity?.cartCount?.intValue ?? 0
            let paymentMethod = cart.cartEntity?.paymentMethod ?? ""
            let purchasedAttribute: [String :Any] = [
                "Order_Number": orderNumber,
                "Total_Value": cartValue,
                "City_Name": cityName,
                "No_Of_Products": numberOfProducts,
                "Payment_Method": paymentMethod
            ]
            analytics.trackEvent(withName: "Purchase_Payment_Failure", andValue: purchasedAttribute)
        }
    }
    
    func trackScreenName(screenName: String) {
        analytics.navigatingToScreen(withName: screenName)
    }
    
    private func syncUser(user: User) {
        if let userID = user.userID { trackingWeUser.login("\(userID)") }
        if let email = user.email { trackingWeUser.setEmail(email) }
        if let fn = user.firstName { trackingWeUser.setFirstName(fn) }
        if let ln = user.lastName { trackingWeUser.setLastName(ln) }
        if let phone = user.phone { trackingWeUser.setPhone(phone) }
        if let gender = user.gender { trackingWeUser.setGender(gender.rawValue) }
    }
}
