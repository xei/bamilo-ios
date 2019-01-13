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
    
    
    //MARK: - EventTrackerProtocol
    func appOpened(attributes: EventAttributeType) {
        analytics.trackEvent(withName: "app_opened")
    }
    
    func login(attributes: EventAttributeType) {
        if let success = attributes[kEventSuccess] as? Bool, success {
            var params: [String: Any] = [:]
            if let method = attributes[kEventMethod] as? String {
                params = ["login_method": method]
            }
            if let user = attributes[kEventUser] as? User {
                self.syncUser(user: user)
                params["phone"] = user.phone
                params["email"] = user.email
            }
            analytics.trackEvent(withName: "user_logged_in", andValue: params)
        }
    }
    
    func logout(attributes: EventAttributeType) {
        analytics.trackEvent(withName: "user_logged_out")
    }
    
    func editProfile(attributes: EventAttributeType) {
        if let _ = attributes[kEventUser] as? User {
            analytics.trackEvent(withName: "user_profile_edited")
        }
    }
    
    func editAddress(attributes: EventAttributeType) {
        analytics.trackEvent(withName: "user_address_edited")
    }
    
    func addAddress(attributes: EventAttributeType) {
        analytics.trackEvent(withName: "user_address_added")
    }
    
    func removeAddress(attributes: EventAttributeType) {
        analytics.trackEvent(withName: "user_address_removed")
    }
    
    
    func catalogSortChanged(attributes: EventAttributeType) {
        
        let sortKeyMapper: [Catalog.CatalogSortType: String] = [
            .bestRating : "score",
            .popularity : "popularity",
            .newest : "newest",
            .priceUp: "price-asc",
            .priceDown:"price-desc",
            .name: "name",
            .brand: "brand"
        ]
        
        if let sortMethod = attributes[kEventCatalogSortMethod] as? Catalog.CatalogSortType {
            analytics.trackEvent(withName: "product_list_sorted", andValue: [
                "sort_key": sortKeyMapper[sortMethod] ?? ""
            ])
        }
    }
    
    func addToWishList(attributes: EventAttributeType) {
        if let product = attributes[kEventProduct] as? TrackableProductProtocol,
            let price = product.payablePrice,
            let name = product.name {
            
            analytics.trackEvent(withName: "product_added_to_wishlist", andValue: [
                "item_id": product.simpleSku ?? "",
                "price": price,
                "item_name": name
            ])
        }
    }
    
    func removeFromWishList(attributes: EventAttributeType) {
        if let product = attributes[kEventProduct] as? TrackableProductProtocol,
            let price = product.payablePrice,
            let name = product.name {
            analytics.trackEvent(withName: "product_removed_from_wishlist", andValue: [
                "item_id": product.simpleSku ?? "",
                "price": price,
                "item_name": name
            ])
        }
    }
    
    func addToCart(attributes: EventAttributeType) {
        if let product = attributes[kEventProduct] as? TrackableProductProtocol,
            let price = product.payablePrice {
            analytics.trackEvent(withName: "cart_item_added", andValue: [
                "price": price,
                "item_id": product.simpleSku ?? "",
                "item_name": product.name ?? "",
                "item_category_url": product.categoryUrlKey ?? "",
                "item_sku": product.sku ?? "",
                "quantity": 1
            ])
        }
    }
    
    func buyNowTapped(attributes: EventAttributeType) {
        if  let product = attributes[kEventProduct] as? TrackableProductProtocol,
            let price = product.payablePrice {
            analytics.trackEvent(withName: "cart_buy_now", andValue: [
                "price": price,
                "item_id": product.simpleSku ?? "",
                "item_name": product.name ?? "",
                "item_category_url": product.categoryUrlKey ?? "",
                "item_sku": product.sku ?? "",
                "quantity": 1
            ])
        }
    }
    
    func removeFromCart(attributes: EventAttributeType) {
        if let product = attributes[kEventProduct] as? TrackableProductProtocol,
            let price = product.payablePrice, let quantity = attributes[kEventQuantity] as? Int32 {
            analytics.trackEvent(withName: "cart_item_removed", andValue: [
                "price": price,
                "item_id": product.simpleSku ?? "",
                "item_name": product.name ?? "",
                "item_category_url": product.categoryUrlKey ?? "",
                "item_sku": product.sku ?? "",
                "quantity": quantity
            ])
        }
    }
    
    func viewProduct(attributes: EventAttributeType) {
        if let product = attributes[kEventProduct] as? TrackableProductProtocol,
            let price = product.payablePrice,
            let name = product.name {
            analytics.trackEvent(withName: "product_viewed", andValue: [
                "price": price,
                "item_id": product.simpleSku ?? "",
                "item_name": name,
                "item_category_url": product.categoryUrlKey ?? "",
                "item_sku": product.sku ?? "",
                "item_brand_name": product.brand ?? ""
            ])
        }
    }
    
    
    func signup(attributes: EventAttributeType) {
        if let success = attributes[kEventSuccess] as? Bool, success {
            var params: [String: Any] = [:]
            if let method = attributes[kEventMethod] as? String {
                params = ["sign_up_method": method]
            }
            if let user = attributes[kEventUser] as? User {
                params["phone"] = user.phone
                params["email"] = user.email
            }
            analytics.trackEvent(withName: "user_signed_up", andValue: params)
        }
    }
    
    func submitProductReview(attributes: EventAttributeType) {
        if let product = attributes[kEventProduct] as? TrackableProductProtocol {
            analytics.trackEvent(withName: "product_review_added", andValue: [
                "price": product.payablePrice ?? "",
                "item_id": product.simpleSku ?? "",
                "item_name": product.name ?? "",
            ])
        }
    }
    
    func shareProduct(attributes: EventAttributeType) {
        if let product = attributes[kEventProduct] as? TrackableProductProtocol {
            analytics.trackEvent(withName: "product_shared", andValue: [
                "item_sku": product.simpleSku ?? ""
            ])
        }
    }
    
    func shareApp(attributes: EventAttributeType) {
        analytics.trackEvent(withName: "user_friends_invited")
    }
    
    
    func checkoutStart(attributes: EventAttributeType) {
        if let cart = attributes[kEventCart] as? RICart {
            if let cartEntity = cart.cartEntity {
                analytics.trackEvent(withName: "cart_checkout_started", andValue: [
                    "number_of_items": cartEntity.cartCount,
                    "value": cartEntity.cartValue
                ])
            }
        }
    }
    
    func checkoutFinished(attributes: EventAttributeType) {
        if let cart = attributes[kEventCart] as? RICart {
            if let cartEntity = cart.cartEntity {
                analytics.trackEvent(withName: "cart_checkout_completed", andValue: [
                    "number_of_items": cartEntity.cartCount,
                    "value": cartEntity.cartValue,
                    "coupon": cartEntity.couponCode,
                    "transaction_id": cart.orderNr,
                    "payment_method": cart.cartEntity.paymentMethod, //Enum <'cod' or 'ipg' or 'mpg'>
                    "city_name": cart.cartEntity.address.city,
                ])
            }
        }
    }
    
    func purchased(attributes: EventAttributeType) {
        //becasues we have the checkout finish it's not necessary
        if let cart = attributes[kEventCart] as? RICart,
            let success = attributes[kEventSuccess] as? Bool, !success {
            analytics.trackEvent(withName: "cart_payment_failed", andValue: [
                "value": cart.cartEntity.cartValue ?? 0
            ])
        }
    }
    
    func searchbarSearched(attributes: EventAttributeType) {
        if let searchString = attributes[kEventKeywords] as? String {
            analytics.trackEvent(withName: "view_search_results", andValue: [
                "search_term": searchString
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
