//
//  FirebaseTracker.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 8/19/18.
//  Copyright © 2018 Rocket Internet. All rights reserved.
//

import UIKit
import Firebase

@objcMembers class FirebaseTracker: BaseTracker, ScreenTrackerProtocol, EventTrackerProtocol {
    
    //TODO: Must be changed when we migrate all Trackers
    private static var sharedInstance: FirebaseTracker? // = AdjustTracker()
    override class func shared() -> FirebaseTracker {
        if sharedInstance == nil {
            sharedInstance = FirebaseTracker()
            sharedInstance?.setConfig()
        }
        return sharedInstance!
    }
    
    private func setConfig() {
        FirebaseApp.configure()
    }
    
    //MARK: - EventTrackerProtocol
    func login(attributes: EventAttributeType) {
        if let success = attributes[kEventSuccess] as? Bool, success {
            var params: [String: Any] = [:]
            if let method = attributes[kEventMethod] as? String {
                params = ["login_method": method]
            }
            if let user = attributes[kEventUser] as? User {
                params["phone"] = user.phone
                params["email"] = user.email
            }
            Analytics.logEvent(AnalyticsEventLogin, parameters: params)
        }
    }
    
    func logout(attributes: EventAttributeType) {
        Analytics.logEvent("logout", parameters: nil)
    }
    
    func editProfile(attributes: EventAttributeType) {
        if let _ = attributes[kEventUser] as? User {
            Analytics.logEvent("edit_profile", parameters: nil)
        }
    }
    
    func editAddress(attributes: EventAttributeType) {
        Analytics.logEvent("edit_address", parameters: nil)
    }
    
    func addAddress(attributes: EventAttributeType) {
        Analytics.logEvent("add_address", parameters: nil)
    }
    
    func removeAddress(attributes: EventAttributeType) {
        Analytics.logEvent("remove_address", parameters: nil)
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
            Analytics.logEvent("sort_product_list", parameters: [
                "sort_key": sortKeyMapper[sortMethod] ?? ""
            ])
        }
    }
    
    func addToWishList(attributes: EventAttributeType) {
        if let product = attributes[kEventProduct] as? TrackableProductProtocol,
            let price = product.payablePrice,
            let name = product.name {
            Analytics.logEvent(AnalyticsEventAddToWishlist, parameters: [
                AnalyticsParameterItemID: product.simpleSku ?? "",
                AnalyticsParameterPrice: price,
                AnalyticsParameterItemName: name
                
            ])
        }
    }
    
    func removeFromWishList(attributes: EventAttributeType) {
        if let product = attributes[kEventProduct] as? TrackableProductProtocol,
            let price = product.payablePrice,
            let name = product.name {
            Analytics.logEvent("remove_from_wishlist", parameters: [
                AnalyticsParameterItemID: product.sku ?? "",
                AnalyticsParameterPrice: price,
                AnalyticsParameterItemName: name])
        }
    }
    
    func addToCart(attributes: EventAttributeType) {
        if let product = attributes[kEventProduct] as? TrackableProductProtocol,
           let price = product.payablePrice {
            Analytics.logEvent(AnalyticsEventAddToCart, parameters: [
                AnalyticsParameterPrice: price,
                AnalyticsParameterItemID: product.simpleSku ?? "",
                AnalyticsParameterItemName: product.name ?? "",
                "item_category_url": product.categoryUrlKey ?? "",
                "item_sku": product.sku ?? "",
                "quantity": 1
            ])
        }
    }
    
    func buyNowTapped(attributes: EventAttributeType) {
        if  let product = attributes[kEventProduct] as? TrackableProductProtocol,
            let price = product.payablePrice {
            Analytics.logEvent("buy_now", parameters: [
                AnalyticsParameterPrice: price,
                AnalyticsParameterItemID: product.simpleSku ?? "",
                AnalyticsParameterItemName: product.name ?? "",
                "item_category_url": product.categoryUrlKey ?? "",
                "item_sku": product.sku ?? "",
                "quantity": 1
            ])
        }
    }
    
    func removeFromCart(attributes: EventAttributeType) {
        if let product = attributes[kEventProduct] as? TrackableProductProtocol,
            let price = product.payablePrice, let quantity = attributes[kEventQuantity] as? Int32 {
            Analytics.logEvent(AnalyticsEventRemoveFromCart, parameters: [
                AnalyticsParameterPrice: price,
                AnalyticsParameterItemID: product.simpleSku ?? "",
                AnalyticsParameterItemName: product.name ?? "",
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
            Analytics.logEvent(AnalyticsEventViewItem, parameters: [
                AnalyticsParameterPrice: price,
                AnalyticsParameterItemID: product.simpleSku ?? "",
                AnalyticsParameterItemName: name,
                "item_category_url": product.categoryUrlKey ?? "",
                "item_sku": product.sku ?? "",
                AnalyticsParameterItemBrand: product.brand ?? ""
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
            Analytics.logEvent(AnalyticsEventSignUp, parameters: params)
        }
    }
    
    func submitProductReview(attributes: EventAttributeType) {
        if let product = attributes[kEventProduct] as? TrackableProductProtocol {
            Analytics.logEvent(AnalyticsEventViewItem, parameters: [
                AnalyticsParameterPrice: product.payablePrice ?? "",
                AnalyticsParameterItemID: product.simpleSku ?? "",
                AnalyticsParameterItemName: product.name ?? "",
            ])
        }
    }
    
    func shareProduct(attributes: EventAttributeType) {
        if let product = attributes[kEventProduct] as? TrackableProductProtocol {
            Analytics.logEvent(AnalyticsEventShare, parameters: [
                AnalyticsParameterItemID: product.sku ?? ""
            ])
        }
    }
    
    func shareApp(attributes: EventAttributeType) {
        Analytics.logEvent("invite_friends", parameters: nil)
    }
    
    
    func checkoutStart(attributes: EventAttributeType) {
        if let cart = attributes[kEventCart] as? RICart {
            if let cartEntity = cart.cartEntity {
                Analytics.logEvent(AnalyticsEventBeginCheckout, parameters: [
                    "number_of_items": cartEntity.cartCount,
                    AnalyticsParameterValue: cartEntity.cartValue
                ])
            }
        }
    }
    
    func checkoutFinished(attributes: EventAttributeType) {
        if let cart = attributes[kEventCart] as? RICart {
            if let cartEntity = cart.cartEntity {
                Analytics.logEvent("ecommerce_purchase", parameters: [
                    "number_of_items": cartEntity.cartCount,
                    AnalyticsParameterValue: cartEntity.cartValue,
                    AnalyticsParameterCoupon: cartEntity.couponCode,
                    AnalyticsParameterTransactionID: cart.orderNr,
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
            Analytics.logEvent("payment_failed", parameters: [
                AnalyticsParameterValue: cart.cartEntity.cartValue ?? 0
            ])
        }
    }
    
    func searchbarSearched(attributes: EventAttributeType) {
        if let searchString = attributes[kEventKeywords] as? String {
            Analytics.logEvent("view_search_results", parameters:[
                AnalyticsParameterSearchTerm: searchString
            ])
        }
    }
    
    func openProductGallery(attributes: EventAttributeType) {
        if let product = attributes[kEventProduct] as? TrackableProductProtocol {
            Analytics.logEvent("view_product_gallery", parameters: [
                AnalyticsParameterItemID: product.sku ?? ""
            ])
        }
    }
    
    func searchFiltered(attributes: EventAttributeType) {
        //        if let filterQuery = attributes[kEventFilterQuery] as? String {
        //            let arrayOfFilterKeysAndValues = filterQuery.components(separatedBy: "/")
        //            let filterKeys = arrayOfFilterKeysAndValues.enumerated().compactMap { $0 % 2 == 0 ? $1 : nil}.joined(separator: ", ")
        //            Analytics.logEvent(AnalyticsEventSearch, parameters: [
        //                "filters": filterKeys
        //            ])
        //        }
    }
    
    func searchSuggestionTapped(attributes: EventAttributeType) {
        //        if let suggestionTitle = attributes[kEventSuggestionTitle] as? String {
        //            Analytics.logEvent("search_suggestion", parameters: [
        //                AnalyticsParameterSearchTerm: suggestionTitle
        //            ])
        //        }
    }
    
    func itemTapped(attributes: EventAttributeType) {
        //        if  let categoryEventName = attributes[kGAEventCategory] as? String,
        //            let labelEventName = attributes[kGAEventLabel] as? String {
        //            Analytics.logEvent("tap_teaser", parameters: [
        //                AnalyticsParameterCampaign: categoryEventName,
        //                AnalyticsParameterItemName: labelEventName,
        //
        //            ])
        //        }
    }
    
    func purchaseBehaviour(attributes: EventAttributeType) {
        //        if let category = attributes[kGAEventCategory] as? String,
        //            let label = attributes[kGAEventLabel] as? String {
        //            Analytics.logEvent("purchase_teaser", parameters: [
        //                AnalyticsParameterCampaign: category,
        //                AnalyticsParameterItemName: label
        //            ])
        //        }
    }
    
    func catalogViewChanged(attributes: EventAttributeType) {
        //        if let listType = attributes[kEventCatalogListViewType] as? String {
        //            Analytics.logEvent("change_catalog_view", parameters: [AnalyticsParameterContentType: listType])
        //        }
    }
    
    func recommendationTapped(attributes: EventAttributeType) {
        //        if let screenName = attributes[kEventScreenName] as? String, let logic = attributes[kEventRecommendationLogic] as? String {
        //            Analytics.logEvent("emarsys_click", parameters: ["screen": screenName, "logic": logic])
        //        }
    }
    
    func search(attributes: EventAttributeType) {
        //        if let target = (attributes[kEventSearchTarget] as? RITarget), target.targetType == .CATALOG_CATEGORY  {
        //            Analytics.logEvent(AnalyticsEventSearch, parameters:
        //                [AnalyticsParameterItemCategory: target.node]
        //            )
        //        }
    }
    
    //MARK: - ScreenTrackerProtocol
    func trackScreenName(screenName: String) {
        Analytics.setScreenName(screenName, screenClass: nil)
    }
    
    func trackLoadTime(screenName: String, interval: NSNumber, label: String) {
        
    }
}
