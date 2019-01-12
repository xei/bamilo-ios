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
    
    func search(attributes: EventAttributeType) {
//        if let target = (attributes[kEventSearchTarget] as? RITarget), target.targetType == .CATALOG_CATEGORY  {
//            Analytics.logEvent(AnalyticsEventSearch, parameters:
//                [AnalyticsParameterItemCategory: target.node]
//            )
//        }
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
    
    func searchbarSearched(attributes: EventAttributeType) {
        if let searchString = attributes[kEventKeywords] as? String {
            Analytics.logEvent(AnalyticsEventSearch, parameters:
                [AnalyticsParameterSearchTerm: searchString]
            )
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
    
    func catalogSortChanged(attributes: EventAttributeType) {
        if let sortMethod = attributes[kEventCatalogSortMethod] as? Catalog.CatalogSortType {
            Analytics.logEvent(AnalyticsEventSearch, parameters: [
                "sort": sortMethod
            ])
        }
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
        if let screenName = attributes[kEventScreenName] as? String,
            let product = attributes[kEventProduct] as? TrackableProductProtocol,
            let price = product.payablePrice,
            let name = product.name {
            Analytics.logEvent("remove_from_wishlist", parameters: [
                AnalyticsParameterItemID: product.sku ?? "",
                AnalyticsParameterPrice: price,
                "screen": screenName,
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
    
    func purchased(attributes: EventAttributeType) {
        //becasues we have the checkout finish it's not necessary
        
//        if let cart = attributes[kEventCart] as? RICart,
//            let success = attributes[kEventSuccess] as? Bool, !success {
//            Analytics.logEvent("fail_checkout", parameters: [
//                AnalyticsParameterItemID: cart.orderNr,
//                AnalyticsParameterValue: cart.cartEntity.cartValue ?? 0
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
    
    func checkoutStart(attributes: EventAttributeType) {
        if let cart = attributes[kEventCart] as? RICart {
            let combinedSkus = cart.cartEntity?.cartItems?.map { $0.sku }.compactMap { $0 }.joined(separator: ",")
            if let combinedSku = combinedSkus, let cartValue = cart.cartEntity?.cartValue {
                Analytics.logEvent(AnalyticsEventBeginCheckout, parameters: [
                    AnalyticsParameterItemList: combinedSku,
                    AnalyticsParameterValue: cartValue
                ])
            }
        }
    }
    
    func checkoutFinished(attributes: EventAttributeType) {
        if let cart = attributes[kEventCart] as? RICart {
            var combinedSkus: String?
            if let cartItems = cart.cartEntity?.cartItems,  cartItems.count > 0 {
                combinedSkus = cart.cartEntity?.cartItems?.map { $0.sku }.compactMap { $0 }.joined(separator: ",")
            } else if let packages = cart.cartEntity?.packages, packages.count > 0 {
                combinedSkus = cart.cartEntity?.packages?.map{$0.products}.compactMap{$0}.flatMap{$0}.map { $0.sku }.compactMap { $0 }.joined(separator: ",")
            }
            let combinedSkusFromPackages = cart.cartEntity?.packages?.map{$0.products}.compactMap{$0}.flatMap{$0}.map{$0.sku}.compactMap {$0}.joined(separator: ",")
            if let itemList = combinedSkus ?? combinedSkusFromPackages, let cartValue = cart.cartEntity?.cartValue {
                Analytics.logEvent("finish_checkout", parameters: [
                    AnalyticsParameterItemList: itemList,
                    AnalyticsParameterValue: cartValue
                ])
            }
        }
    }
    
    func searchSuggestionTapped(attributes: EventAttributeType) {
//        if let suggestionTitle = attributes[kEventSuggestionTitle] as? String {
//            Analytics.logEvent("search_suggestion", parameters: [
//                AnalyticsParameterSearchTerm: suggestionTitle
//            ])
//        }
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
    
    
    //MARK: - ScreenTrackerProtocol
    func trackScreenName(screenName: String) {
        Analytics.setScreenName(screenName, screenClass: nil)
    }
    
    func trackLoadTime(screenName: String, interval: NSNumber, label: String) {
        
    }
}
