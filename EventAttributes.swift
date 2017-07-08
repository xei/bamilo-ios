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
            kEventConnection: DeviceManager.getConnectionType(),
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
    
    static func signup(method: String, user: RICustomer,success: Bool) -> EventAttributeType {
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
    
    static func addToFavorite(product: RIProduct, success: Bool) -> EventAttributeType {
        var attributes = self.getCommonAttributes()
        attributes[kEventSuccess] = success
        attributes[kEventProduct] = product
        return attributes
    }
    
    static func addToCard(product: RIProduct, success: Bool) -> EventAttributeType {
        var attributes = self.getCommonAttributes()
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
    
    static func viewProduct(product: RIProduct) -> EventAttributeType {
        var attributes = self.getCommonAttributes()
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
}
