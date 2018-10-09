//
//  EventAtrributes.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 7/5/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

public typealias EventAttributeType = [String:Any]


@objcMembers class EventAttributes: NSObject {
    
    private class func getCommonAttributes() -> EventAttributeType {
        var attributes = [
            kEventAppVersion: AppManager.sharedInstance().getAppFullFormattedVersion(),
            kEventPlatform: "ios",
            kEventConnection: DeviceStatusManager.getConnectionType(),
            kEventDate:  Date()
        ] as [String: Any]
        if let userGender = RICustomer.getGender() {
            attributes[kEventUserGender] = userGender
        }
        return attributes
    }
    
    class func login(loginMethod: String, user: RICustomer?, success: Bool) -> EventAttributeType {
        var attributes = self.getCommonAttributes()
        attributes[kEventMethod] = loginMethod
        if let user = user { attributes[kEventUser] = user }
        attributes[kEventSuccess] = success
        return attributes
    }
    
    class func logout(success: Bool) -> EventAttributeType {
        var attributes = self.getCommonAttributes()
        attributes[kEventSuccess] = success
        return attributes
    }
    
    class func signup(method: String, user: RICustomer?,success: Bool) -> EventAttributeType {
        var attributes = self.getCommonAttributes()
        attributes[kEventMethod] = method
        attributes[kEventUser] = user
        attributes[kEventSuccess] = success
        return attributes
    }
    
    class func openApp(source: OpenAppEventSourceType) -> EventAttributeType {
        var attributes = self.getCommonAttributes()
        switch source {
        case .deeplink:
            attributes[kEventSource] = "deeplink"
        case .direct:
            attributes[kEventSource] = "direct"
        case .pushNotification:
            attributes[kEventSource] = "push_notification"
        case .none:
            break
        }
        return attributes
    }
    
    class func addToWishList(product: TrackableProductProtocol, screenName: String, success: Bool) -> EventAttributeType {
        var attributes = self.getCommonAttributes()
        attributes[kEventScreenName] = screenName
        attributes[kEventSuccess] = success
        attributes[kEventProduct] = product
        return attributes
    }
    
    class func removeFromWishList(product: TrackableProductProtocol, screenName: String) -> EventAttributeType {
        var attributes = self.getCommonAttributes()
        attributes[kEventScreenName] = screenName
        attributes[kEventProduct] = product
        return attributes
    }
    
    class func addToCart(product: TrackableProductProtocol, screenName: String, success: Bool) -> EventAttributeType {
        var attributes = self.getCommonAttributes()
        attributes[kEventScreenName] = screenName
        attributes[kEventSuccess] = success
        attributes[kEventProduct] = product
        return attributes
    }
    
    class func removeFromCard(product: TrackableProductProtocol, success: Bool) -> EventAttributeType {
        var attributes = self.getCommonAttributes()
        attributes[kEventSuccess] = success
        attributes[kEventProduct] = product
        return attributes
    }
    
    class func viewCart(cart: RICart, success: Bool) -> EventAttributeType {
        var attributes = self.getCommonAttributes()
        attributes[kEventCart] = success
        attributes[kEventSuccess] = success
        return attributes
    }
    
    class func purchase(cart: RICart, success: Bool) -> EventAttributeType {
        var attributes = self.getCommonAttributes()
        attributes[kEventCart] = cart
        attributes[kEventSuccess] = success
        return attributes
    }
    
    class func purchaseBehaviour(behaviour: PurchaseBehaviour) -> EventAttributeType {
        var attributes = self.getCommonAttributes()
        attributes[kGAEventCategory] = behaviour.categoryName
        attributes[kGAEventLabel] = behaviour.label
        return attributes
    }
    
    class func itemTapped(categoryEvent: String, screenName: String, labelEvent: String) -> EventAttributeType {
        var attributes = self.getCommonAttributes()
        attributes[kGAEventCategory] = categoryEvent
        attributes[kEventScreenName] = screenName
        attributes[kGAEventLabel] = labelEvent
        return attributes
    }
    
    class func viewProduct(parentViewScreenName: String, product: TrackableProductProtocol) -> EventAttributeType {
        var attributes = self.getCommonAttributes()
        attributes[kEventScreenName] = parentViewScreenName
        attributes[kEventProduct] = product
        return attributes
    }
    
    class func rateProduct(product: TrackableProductProtocol) -> EventAttributeType {
        var attributes = self.getCommonAttributes()
        attributes[kEventProduct] = product
        return attributes
    }
    
    class func searchAction(searchTarget: RITarget) -> EventAttributeType {
        var attributes = self.getCommonAttributes()
        attributes[kEventSearchTarget] = searchTarget
        return attributes
    }
    
    class func searchBarSearched(searchString: String, screenName: String) -> EventAttributeType {
        var attributes = self.getCommonAttributes()
        attributes[kEventKeywords] = searchString
        attributes[kEventScreenName] = screenName
        return attributes
    }
    
    class func tapEmarsysRecommendation(screenName: String, logic: String) -> EventAttributeType {
        var attributes = self.getCommonAttributes()
        attributes[kEventScreenName] = screenName
        attributes[kEventRecommendationLogic] = logic
        return attributes
    }
    
    class func filterSearch(filterQueryString: String) -> EventAttributeType {
        var attributes = self.getCommonAttributes()
        attributes[kEventFilterQuery] = filterQueryString
        return attributes
    }
    
    class func catalogViewChanged(listViewType: CatalogListViewType) -> EventAttributeType {
        var attributes = self.getCommonAttributes()
        attributes[kEventCatalogListViewType] = listViewType.rawValue
        return attributes
    }
    
    class func catalogSortChanged(sortMethod: Catalog.CatalogSortType) -> EventAttributeType {
        var attributes = self.getCommonAttributes()
        attributes[kEventCatalogSortMethod] = sortMethod
        return attributes
    }
    
    class func checkoutStart(cart :RICart) -> EventAttributeType {
        var attributes = self.getCommonAttributes()
        attributes[kEventCart] = cart
        return attributes
    }
    
    class func chekcoutFinish(cart: RICart) -> EventAttributeType {
        var attributes = self.getCommonAttributes()
        attributes[kEventCart] = cart
        return attributes
    }
    
    class func searchSuggestionTapped(suggestionTitle: String) -> EventAttributeType {
        var attributes = self.getCommonAttributes()
        attributes[kEventSuggestionTitle] = suggestionTitle
        return attributes
    }
    
    class func callToOrderTapped() -> EventAttributeType {
        return self.getCommonAttributes()
    }
    
    class func shareApp() -> EventAttributeType {
        return self.getCommonAttributes()
    }
    
    class func buyNowTapped(product: TrackableProductProtocol, screenName: String, success: Bool) -> EventAttributeType {
        var attributes = self.getCommonAttributes()
        attributes[kEventScreenName] = screenName
        attributes[kEventSuccess] = success
        attributes[kEventProduct] = product
        return attributes
    }
}
