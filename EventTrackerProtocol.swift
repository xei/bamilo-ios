
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
    @objc optional func search(attributes: EventAttributeType)
    @objc optional func purchased(attributes: EventAttributeType)
    @objc optional func addToCart(attributes: EventAttributeType)
    @objc optional func addToWishList(attributes: EventAttributeType)
    @objc optional func appOpend(attributes: EventAttributeType)
    @objc optional func logout(attributes: EventAttributeType)
    @objc optional func login(attributes: EventAttributeType)
    @objc optional func signup(attributes: EventAttributeType)
    @objc optional func catalogViewChanged(attributes: EventAttributeType)
    @objc optional func catalogSortChanged(attributes: EventAttributeType)
    
}
