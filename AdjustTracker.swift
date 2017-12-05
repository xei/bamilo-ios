//
//  AdjustTracker.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 12/3/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

import UIKit
import Adjust

class AdjustTracker: BaseTracker, EventTrackerProtocol {
    
    let kLoginEvent = "y3ehk5"
    let kLogoutEvent = "rev85g"
    let kSignupEvent = "6hodya"
    let kAddToCartEvent = "k53qfh"
    let kRemoveFromCartEvent = "5mj3it"
    let kAddToWishListEvent = "ik3rb5"
    let kRemoveFromWishListEvent = "7inzjw"
    let kSearchEvent = "1vupdt"
    let kViewProductEvent = "nnwjjo"
    let kViewCartEvent = "pexi13"
    let kOpenAppEvent = "3qdwyi"
    let kCheckoutFinish = "ca8jou"
    let kCallToOrder = "x1e24b"
    let kRateProduct = "3t4nj8"
    
    //TODO: Must be changed when we migrate all Trackers
    private static var sharedInstance: AdjustTracker? // = AdjustTracker()
    override class func shared() -> AdjustTracker {
        if sharedInstance == nil {
            sharedInstance = AdjustTracker()
            sharedInstance?.setConfig()
        }
        return sharedInstance!
    }
    
    func setConfig() {
        if let ADJUSTID = AppUtility.getInfoConfigs(for: "AdjustTokenID") as? String {
            let adjConfigs = ADJConfig.init(appToken: ADJUSTID, environment: ADJEnvironmentProduction)
            adjConfigs?.logLevel = ADJLogLevelAssert
            Adjust.appDidLaunch(adjConfigs)
        }
    }
    
    //MARK: - EventTrackerProtocol
    func login(attributes: EventAttributeType) {
        self.createAndSendEvent(name: kLoginEvent)
    }
    func logout(attributes: EventAttributeType) {
        self.createAndSendEvent(name: kLogoutEvent)
    }
    func signup(attributes: EventAttributeType) {
        self.createAndSendEvent(name: kSignupEvent)
    }
    func addToCart(attributes: EventAttributeType) {
        self.createAndSendEvent(name: kAddToCartEvent)
    }
    func removeFromCart(attributes: EventAttributeType) {
        self.createAndSendEvent(name: kRemoveFromCartEvent)
    }
    func viewCart(attributes: EventAttributeType) {
        self.createAndSendEvent(name: kViewCartEvent)
    }
    func addToWishList(attributes: EventAttributeType) {
        self.createAndSendEvent(name: kAddToWishListEvent)
    }
    func removeFromWishList(attributes: EventAttributeType) {
        self.createAndSendEvent(name: kRemoveFromWishListEvent)
    }
    func searchbarSearched(attributes: EventAttributeType) {
        self.createAndSendEvent(name: kSearchEvent)
    }
    func viewProduct(attributes: EventAttributeType) {
        self.createAndSendEvent(name: kViewProductEvent)
    }
    func appOpend(attributes: EventAttributeType) {
        self.createAndSendEvent(name: kOpenAppEvent)
    }
    func checkoutFinished(attributes: EventAttributeType) {
        if let event = ADJEvent(eventToken: kCheckoutFinish), let cart = attributes[kEventCart] as? RICart {
            event.setRevenue(cart.cartEntity.cartValue.doubleValue, currency: "RIAL")
            self.sendEventToAdjust(event: event)
        }
    }
    func rateProduct(attributes: EventAttributeType) {
        self.createAndSendEvent(name: kRateProduct)
    }
    
    private func createAndSendEvent(name: String) {
        if let event = ADJEvent(eventToken: name) {
            self.sendEventToAdjust(event: event)
        }
    }
    
    private func sendEventToAdjust(event: ADJEvent) {
        Adjust.trackEvent(event)
    }
}
