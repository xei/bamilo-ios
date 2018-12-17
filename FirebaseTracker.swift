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
        if let success = attributes[kEventSuccess] {
            Analytics.logEvent(AnalyticsEventLogin, parameters: [AnalyticsParameterSuccess: success])
        }
    }
    
    func logout(attributes: EventAttributeType) {
        Analytics.logEvent("logout", parameters: nil)
    }
    
    func search(attributes: EventAttributeType) {
        if let target = (attributes[kEventSearchTarget] as? RITarget), target.targetType == .CATALOG_CATEGORY  {
            Analytics.logEvent(AnalyticsEventSearch, parameters:
                [AnalyticsParameterItemCategory: target.node]
            )
        }
    }
    
    func searchbarSearched(attributes: EventAttributeType) {
        if let searchString = attributes[kEventKeywords] as? String {
            Analytics.logEvent(AnalyticsEventSearch, parameters:
                [AnalyticsParameterSearchTerm: searchString]
            )
        }
    }
    
    func searchFiltered(attributes: EventAttributeType) {
        if let filterQuery = attributes[kEventFilterQuery] as? String {
            let arrayOfFilterKeysAndValues = filterQuery.components(separatedBy: "/")
            let filterKeys = arrayOfFilterKeysAndValues.enumerated().compactMap { $0 % 2 == 0 ? $1 : nil}.joined(separator: ", ")
            Analytics.logEvent(AnalyticsEventSearch, parameters: [
                "filters": filterKeys
            ])
        }
    }
    
    func catalogSortChanged(attributes: EventAttributeType) {
        if let sortMethod = attributes[kEventCatalogSortMethod] as? Catalog.CatalogSortType {
            Analytics.logEvent(AnalyticsEventSearch, parameters: [
                "sort": sortMethod
            ])
        }
    }
    
    func catalogViewChanged(attributes: EventAttributeType) {
        if let listType = attributes[kEventCatalogListViewType] as? String {
            Analytics.logEvent("change_catalog_view", parameters: [AnalyticsParameterContentType: listType])
        }
    }
    
    func recommendationTapped(attributes: EventAttributeType) {
        if let screenName = attributes[kEventScreenName] as? String, let logic = attributes[kEventRecommendationLogic] as? String {
            Analytics.logEvent("emarsys_click", parameters: ["screen": screenName, "logic": logic])
        }
    }
    
    func addToWishList(attributes: EventAttributeType) {
        if let screenName = attributes[kEventScreenName] as? String,
            let product = attributes[kEventProduct] as? TrackableProductProtocol,
            let price = product.payablePrice,
            let name = product.name {
            Analytics.logEvent(AnalyticsEventAddToWishlist, parameters: [
                AnalyticsParameterItemID: product.sku ?? "",
                AnalyticsParameterPrice: price,
                "screen": screenName,
                AnalyticsParameterItemName: name])
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
        if let screenName = attributes[kEventScreenName] as? String,
           let product = attributes[kEventProduct] as? TrackableProductProtocol,
           let price = product.payablePrice {
            Analytics.logEvent(AnalyticsEventAddToCart, parameters: [
                AnalyticsParameterPrice: price,
                AnalyticsParameterItemID: product.sku ?? "",
                "screen": screenName
            ])
        }
    }
    
    func buyNowTapped(attributes: EventAttributeType) {
        if let screenName = attributes[kEventScreenName] as? String,
            let product = attributes[kEventProduct] as? TrackableProductProtocol,
            let price = product.payablePrice {
            Analytics.logEvent("buy_now", parameters: [
                AnalyticsParameterPrice: price,
                AnalyticsParameterItemID: product.sku ?? "",
                "screen": screenName
                ])
        }
    }
    
    func removeFromCart(attributes: EventAttributeType) {
        if let product = attributes[kEventProduct] as? TrackableProductProtocol,
            let price = product.payablePrice {
            Analytics.logEvent(AnalyticsEventRemoveFromCart, parameters: [
                AnalyticsParameterPrice: price,
                AnalyticsParameterItemID: product.sku ?? ""
            ])
        }
    }
    
    func viewProduct(attributes: EventAttributeType) {
        if let product = attributes[kEventProduct] as? TrackableProductProtocol,
            let price = product.payablePrice,
            let name = product.name {
            Analytics.logEvent(AnalyticsEventViewItem, parameters: [
                AnalyticsParameterPrice: price,
                AnalyticsParameterItemID: product.sku ?? "",
                AnalyticsParameterItemName: name,
                AnalyticsParameterItemBrand: product.brand ?? ""
            ])
        }
    }
    
    func itemTapped(attributes: EventAttributeType) {
        if  let categoryEventName = attributes[kGAEventCategory] as? String,
            let labelEventName = attributes[kGAEventLabel] as? String {
            Analytics.logEvent("tap_teaser", parameters: [
                AnalyticsParameterCampaign: categoryEventName,
                AnalyticsParameterItemName: labelEventName,
                
            ])
        }
    }
    
    func purchased(attributes: EventAttributeType) {
        //becasues we have the checkout finish it's not necessary
        
        if let cart = attributes[kEventCart] as? RICart,
            let success = attributes[kEventSuccess] as? Bool, !success {
            Analytics.logEvent("fail_checkout", parameters: [
                AnalyticsParameterItemID: cart.orderNr,
                AnalyticsParameterValue: cart.cartEntity.cartValue ?? 0
            ])
        }
    }
    
    func purchaseBehaviour(attributes: EventAttributeType) {
        if let category = attributes[kGAEventCategory] as? String,
            let label = attributes[kGAEventLabel] as? String {
            Analytics.logEvent("purchase_teaser", parameters: [
                AnalyticsParameterCampaign: category,
                AnalyticsParameterItemName: label
            ])
        }
    }
    
    func signup(attributes: EventAttributeType) {
        if let signUpMethod = attributes[kEventMethod] as? String, let success = attributes[kEventSuccess] as? Bool {
            Analytics.logEvent(AnalyticsEventSignUp, parameters: [
                AnalyticsParameterSignUpMethod: signUpMethod,
                AnalyticsParameterSuccess: success
            ])
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
        if let suggestionTitle = attributes[kEventSuggestionTitle] as? String {
            Analytics.logEvent("search_suggestion", parameters: [
                AnalyticsParameterSearchTerm: suggestionTitle
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
