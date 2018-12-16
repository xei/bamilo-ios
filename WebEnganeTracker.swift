//
//  WebEnganeTracker.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 10/27/18.
//  Copyright © 2018 Rocket Internet. All rights reserved.
//

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
            analytics.trackEvent(withName: "user_logged_in")
        }
    }
    
    func signup(attributes: EventAttributeType) {
        if let user = attributes[kEventUser] as? User {
            syncUser(user: user)
            analytics.trackEvent(withName: "user_signged_up")
        }
    }
    
    func logout(attributes: EventAttributeType) {
        trackingWeUser.logout()
        analytics.trackEvent(withName: "user_logged_out")
    }
    
    func addToCart(attributes: EventAttributeType) {
        if let screenName = attributes[kEventScreenName] as? String,
            let product = attributes[kEventProduct] as? TrackableProductProtocol {
            let addedToCartAttributes: [String:Any]  = [
                "Price": product.payablePrice?.intValue ?? 0,
                "Quantity": 1,
                "Product": product.name ?? "",
                "Category": product.categoryUrlKey ?? "",
                "Screen": screenName
            ]
            
            analytics.trackEvent(withName: "add_to_cart", andValue: addedToCartAttributes)
        }
    }
    
    func buyNowTapped(attributes: EventAttributeType) {
        if let screenName = attributes[kEventScreenName] as? String,
            let product = attributes[kEventProduct] as? TrackableProductProtocol,
            let price = product.payablePrice {
            let attributes: [String:Any]  = [
                "Price": price.intValue,
                "Quantity": 1,
                "Product": product.name ?? "",
                "Category": product.categoryUrlKey ?? "",
                "Screen": screenName
            ]
            
            analytics.trackEvent(withName: "buy_now", andValue: attributes)
        }
    }
    
    func viewProduct(attributes: EventAttributeType) {
        if let parentScreenName = attributes[kEventScreenName] as? String,
            let product = attributes[kEventProduct] as? TrackableProductProtocol {
            let attributes: [String:Any]  = [
                "Price": product.payablePrice?.intValue ?? 0,
                "Quantity": 1,
                "Product": product.name ?? "",
                "Category": product.categoryUrlKey ?? "",
                "Previous_View_name": parentScreenName
            ]
            
            analytics.trackEvent(withName: "view_product", andValue: attributes)
        }
    }
    
    func removeFromCart(attributes: EventAttributeType) {
        if let product = attributes[kEventProduct] as? TrackableProductProtocol {
            analytics.trackEvent(withName: "remove_from_cart", andValue: ["product_sku": product.sku ?? ""])
        }
    }
    
    func addToWishList(attributes: EventAttributeType) {
        if let screenName = attributes[kEventScreenName] as? String,
            let product = attributes[kEventProduct] as? TrackableProductProtocol,
            let price = product.payablePrice {
            analytics.trackEvent(withName: "add_to_wishlist", andValue: ["product_sku": product.sku ?? "", "screen": screenName, "price": price.intValue])
        }
    }
    
    func removeFromWishList(attributes: EventAttributeType) {
        if let product = attributes[kEventProduct] as? TrackableProductProtocol,
            let price = product.payablePrice {
            analytics.trackEvent(withName: "remove_from_wishlist", andValue: ["product_sku": product.sku ?? "", "price": price.intValue])
        }
    }
    
    func search(attributes: EventAttributeType) {
        if let target = (attributes[kEventSearchTarget] as? RITarget), target.targetType == .CATALOG_CATEGORY  {
            analytics.trackEvent(withName: "category_search", andValue: ["category_url": target.node])
        }
    }
    
    func searchbarSearched(attributes: EventAttributeType) {
        if let searchString = attributes[kEventKeywords] as? String {
            analytics.trackEvent(withName: "searchbar_search", andValue: ["query": searchString])
        }
    }
    
    func checkoutStart(attributes: EventAttributeType) {
        if let cart = attributes[kEventCart] as? RICart {
            analytics.trackEvent(withName: "checkout_start", andValue: [
                "cart_price": cart.cartEntity.cartValue
            ])
        }
    }
    
    func checkoutFinished(attributes: EventAttributeType) {
        if let cart = attributes[kEventCart] as? RICart {
            analytics.trackEvent(withName: "checkout_finsih", andValue: [
                "cart_price": cart.cartEntity.cartValue
            ])
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
