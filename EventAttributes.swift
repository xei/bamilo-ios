//
//  EventAtrributes.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 7/5/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

public typealias EventAttributeType = [String:Any]


@objc class EventAttributes: NSObject {
    
    private static func getCommonAttributes() -> EventAttributeType {
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
    
    static func login(loginMethod: String, user: RICustomer) -> EventAttributeType {
        var attributes = self.getCommonAttributes()
        attributes[kEventMethod] = loginMethod
        attributes[kEventUser] = user
        return attributes
    }
    
    static func logout(success: Bool) -> EventAttributeType {
        var attributes = self.getCommonAttributes()
        attributes[kEventSuccess] = success
        return attributes
    }
    
    static func signup(method: String, user: RICustomer?,success: Bool) -> EventAttributeType {
        var attributes = self.getCommonAttributes()
        attributes[kEventMethod] = method
        attributes[kEventUser] = user
        attributes[kEventSuccess] = success
        return attributes
    }
    
    static func openApp(source: OpenAppEventSourceType) -> EventAttributeType {
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
    
    static func addToWishList(product: RIProduct, screenName: String, success: Bool) -> EventAttributeType {
        var attributes = self.getCommonAttributes()
        attributes[kEventScreenName] = screenName
        attributes[kEventSuccess] = success
        attributes[kEventProduct] = product
        return attributes
    }
    
    static func removeToWishList(product: RIProduct, screenName: String) -> EventAttributeType {
        var attributes = self.getCommonAttributes()
        attributes[kEventScreenName] = screenName
        attributes[kEventProduct] = product
        return attributes
    }
    
    static func addToCard(product: RIProduct, screenName: String, success: Bool) -> EventAttributeType {
        var attributes = self.getCommonAttributes()
        attributes[kEventScreenName] = screenName
        attributes[kEventSuccess] = success
        attributes[kEventProduct] = product
        return attributes
    }
    
    static func purchase(cart: RICart, success: Bool) -> EventAttributeType {
        var attributes = self.getCommonAttributes()
        attributes[kEventCart] = cart
        attributes[kEventSuccess] = success
        return attributes
    }
    
    static func teaserPurchase(teaserName: String, screenName: String) -> EventAttributeType {
        var attributes = self.getCommonAttributes()
        attributes[kEventTeaser] = teaserName
        attributes[kEventScreenName] = screenName
        return attributes
    }
    
    static func teaserTapped(teaserName: String, screenName: String, teaserTargetNode: String) -> EventAttributeType {
        var attributes = self.getCommonAttributes()
        attributes[kEventTeaser] = teaserName
        attributes[kEventScreenName] = screenName
        attributes[kEventTargetString] = teaserTargetNode
        return attributes
    }
    
    static func viewProduct(parentViewScreenName: String, product: RIProduct) -> EventAttributeType {
        var attributes = self.getCommonAttributes()
        attributes[kEventScreenName] = parentViewScreenName
        attributes[kEventProduct] = product
        return attributes
    }
    
    static func searchAction(searchTarget: RITarget) -> EventAttributeType {
        var attributes = self.getCommonAttributes()
        attributes[kEventSearchTarget] = searchTarget
        return attributes
    }
    
    static func searchBarSearched(searchString: String, screenName: String) -> EventAttributeType {
        var attributes = self.getCommonAttributes()
        attributes[kEventKeywords] = searchString
        attributes[kEventScreenName] = screenName
        return attributes
    }
    
    static func tapEmarsysRecommendation(screenName: String, logic: String) -> EventAttributeType {
        var attributes = self.getCommonAttributes()
        attributes[kEventScreenName] = screenName
        attributes[kEventRecommendationLogic] = logic
        return attributes
    }
    
    static func filterSearch(filterQueryString: String) -> EventAttributeType {
        var attributes = self.getCommonAttributes()
        attributes[kEventFilterQuery] = filterQueryString
        return attributes
    }
    
    static func catalogViewChanged(listViewType: CatalogListViewType) -> EventAttributeType {
        var attributes = self.getCommonAttributes()
        attributes[kEventCatalogListViewType] = listViewType.rawValue
        return attributes
    }
    
    static func catalogSortChanged(sortMethod: Catalog.CatalogSortType) -> EventAttributeType {
        var attributes = self.getCommonAttributes()
        attributes[kEventCatalogSortMethod] = sortMethod
        return attributes
    }
    
    static func checkoutStart(cart :RICart) -> EventAttributeType {
        var attributes = self.getCommonAttributes()
        attributes[kEventCart] = cart
        return attributes
    }
    
    static func chekcoutFinish(cart: RICart) -> EventAttributeType {
        var attributes = self.getCommonAttributes()
        attributes[kEventCart] = cart
        return attributes
    }
    
    static func searchSuggestionTapped(suggestionTitle: String) -> EventAttributeType {
        var attributes = self.getCommonAttributes()
        attributes[kEventSuggestionTitle] = suggestionTitle
        return attributes
    }
    
}
