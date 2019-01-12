
//
//  EventTrackerProtocol.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 7/5/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

@objc protocol EventTrackerProtocol {
    @objc optional func searchFiltered(attributes: EventAttributeType)
    @objc optional func recommendationTapped(attributes: EventAttributeType)
    @objc optional func searchbarSearched(attributes: EventAttributeType)
    @objc optional func viewProduct(attributes: EventAttributeType)
    @objc optional func rateProduct(attributes: EventAttributeType)
    @objc optional func search(attributes: EventAttributeType)
    @objc optional func purchased(attributes: EventAttributeType)
    @objc optional func purchaseBehaviour(attributes: EventAttributeType)
    @objc optional func itemTapped(attributes: EventAttributeType)
    @objc optional func addToCart(attributes: EventAttributeType)
    @objc optional func removeFromCart(attributes: EventAttributeType)
    @objc optional func viewCart(attributes: EventAttributeType)
    @objc optional func addToWishList(attributes: EventAttributeType)
    @objc optional func removeFromWishList(attributes: EventAttributeType)
    @objc optional func appOpened(attributes: EventAttributeType)
    @objc optional func logout(attributes: EventAttributeType)
    @objc optional func login(attributes: EventAttributeType)
    @objc optional func signup(attributes: EventAttributeType)
    @objc optional func catalogViewChanged(attributes: EventAttributeType)
    @objc optional func catalogSortChanged(attributes: EventAttributeType)
    @objc optional func callToOrderTapped(attributes: EventAttributeType)
    @objc optional func checkoutStart(attributes: EventAttributeType)
    @objc optional func checkoutFinished(attributes: EventAttributeType)
    @objc optional func buyNowTapped(attributes: EventAttributeType)
    @objc optional func shareApp(attributes: EventAttributeType)
    @objc optional func searchSuggestionTapped(attributes: EventAttributeType)
    @objc optional func phoneVerification(attributes: EventAttributeType)
}
