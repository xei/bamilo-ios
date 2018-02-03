//
//  GoogleAnalyticsTracker.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 7/5/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

@objc class GoogleAnalyticsTracker: BaseTracker, EventTrackerProtocol, ScreenTrackerProtocol {

    private var campaginDataString: String?
    
    //TODO: Must be changed when we migrate all Trackers
    private static var sharedInstance: GoogleAnalyticsTracker? // = GoogleAnalyticsTracker()
    override class func shared() -> GoogleAnalyticsTracker {
        if sharedInstance == nil {
            sharedInstance = GoogleAnalyticsTracker()
            sharedInstance?.setConfig()
        }
        return sharedInstance!
    }
    
    func setConfig() {
        // Automatically send uncaught exceptions to Google Analytics.
        GAI.sharedInstance().trackUncaughtExceptions = true
        
        // Dispatch tracking information every 5 seconds (default: 120)
        GAI.sharedInstance().dispatchInterval = 5
        GAI.sharedInstance().logger.logLevel = .none
        
        let GAID = (Bundle.main.object(forInfoDictionaryKey: "Configs") as? [String:Any])?["GoogleAnalyticsID"] as? String
        GAI.sharedInstance().tracker(withTrackingId: GAID)
        GAI.sharedInstance().defaultTracker.set(kGAIAppVersion, value: AppManager.sharedInstance().getAppFullFormattedVersion() ?? "")
        GAI.sharedInstance().defaultTracker.allowIDFACollection = true
    }
    
    func trackScreenName(screenName:String) {
        let tracker = GAI.sharedInstance().defaultTracker
        tracker?.set(kGAIScreenName, value: screenName)
        var builder = GAIDictionaryBuilder.createScreenView()
        if let campaignString = self.campaginDataString {
            builder = builder?.setCampaignParametersFromUrl(campaignString)
        }
        tracker?.send(builder!.build() as! [AnyHashable : Any])
    }
    
    func trackCampaignData(campaignDictionary: [String: String]) {
        if campaignDictionary.count > 0 {
            var params = [String]()
            
            if let utmCampaign = campaignDictionary[kUTMCampaign] {
                params += ["\(kUTMCampaign)=\(utmCampaign)"]
            }
            if let utmContent = campaignDictionary[kUTMContent] {
                params += ["\(kUTMContent)=\(utmContent)"]
            }
            if let utmTerm = campaignDictionary[kUTMTerm] {
                params += ["\(kUTMTerm)=\(utmTerm)"]
            }
            
            
            if let utmSource = campaignDictionary[kUTMSource], utmSource.count > 0 {
                if let _ = campaignDictionary[kUTMCampaign] {
                    params += ["\(kUTMSource)=push"]
                } else {
                    params += ["\(kUTMSource)=\(utmSource)"]
                }
            }
            
            if let utmMedium = campaignDictionary[kUTMMedium], utmMedium.count > 0 {
                if let _ = campaignDictionary[kUTMCampaign] {
                    params += ["\(kUTMMedium)=referrer"]
                } else {
                    params += ["\(kUTMMedium)=\(utmMedium)"]
                }
            }
            
            self.campaginDataString = params.joined(separator:"&")
        }
    }
    
    
    //MARK: -EventTrackerProtocol
    func search(attributes: EventAttributeType) {
        let params = GAIDictionaryBuilder.createEvent(
            withCategory: "Catalog",
            action: "Search",
            label: (attributes[kEventSearchTarget] as? RITarget)?.node,
            value: nil
        )
        self.sendParamsToGA(params: params)
    }
    
    func searchbarSearched(attributes: EventAttributeType) {
        if let screenName = attributes[kEventScreenName] as? String, let searchString = attributes[kEventKeywords] as? String {
            let params = GAIDictionaryBuilder.createEvent(
                withCategory: screenName,
                action: "SearchBarSearch",
                label: searchString,
                value: nil
            )
            self.sendParamsToGA(params: params)
        }
    }
    
    func searchFiltered(attributes: EventAttributeType) {
        if let filterQuery = attributes[kEventFilterQuery] as? String {
            let arrayOfFilterKeysAndValues = filterQuery.components(separatedBy: "/")
            let filterKeys = arrayOfFilterKeysAndValues.enumerated().flatMap { $0 % 2 == 0 ? $1 : nil}.joined(separator: ", ")
            //let filterValues = arrayOfFilterKeysAndValues.enumerated().flatMap { $0 % 2 != 0 ? $1 : nil}.joined(separator: ", ")
            let params = GAIDictionaryBuilder.createEvent(
                withCategory: "Catalog",
                action: "Filters",
                label: filterKeys,
                value: nil
            )
            self.sendParamsToGA(params: params)
        }
    }
    
    func catalogSortChanged(attributes: EventAttributeType) {
        if let sortMethod = attributes[kEventCatalogSortMethod] as? Catalog.CatalogSortType {
            let params = GAIDictionaryBuilder.createEvent(
                withCategory: "Catalog",
                action: "CatalogSort",
                label:sortMethod.rawValue,
                value: nil
            )
            self.sendParamsToGA(params: params)
        }
    }
    
    func catalogViewChanged(attributes: EventAttributeType) {
        if let listType = attributes[kEventCatalogListViewType] as? String {
            let params = GAIDictionaryBuilder.createEvent(
                withCategory: "Catalog",
                action: "CatalogViewChanged",
                label: listType,
                value: nil
            )
            self.sendParamsToGA(params: params)
        }
    }
    
    func recommendationTapped(attributes: EventAttributeType) {
        if let screenName = attributes[kEventScreenName] as? String, let logic = attributes[kEventRecommendationLogic] as? String {
            let params = GAIDictionaryBuilder.createEvent(
                withCategory: "Emarsys",
                action: "Click",
                label: "\(screenName)-\(logic)",
                value: nil
            )
            self.sendParamsToGA(params: params)
        }
    }
    
    func addToWishList(attributes: EventAttributeType) {
        if let screenName = attributes[kEventScreenName] as? String,
            let product = attributes[kEventProduct] as? RIProduct {
            let params = GAIDictionaryBuilder.createEvent(
                withCategory: screenName,
                action: "AddToWishList",
                label: product.sku,
                value: product.price
            )
            self.sendParamsToGA(params: params)
        }
    }
    
    func removeFromWishList(attributes: EventAttributeType) {
        if let screenName = attributes[kEventScreenName] as? String,
            let product = attributes[kEventProduct] as? RIProduct {
            let params = GAIDictionaryBuilder.createEvent(
                withCategory: screenName,
                action: "RemoveFromWishList",
                label: product.sku,
                value: product.price
            )
            self.sendParamsToGA(params: params)
        }
    }
    
    func addToCart(attributes: EventAttributeType) {
        if let screenName = attributes[kEventScreenName] as? String,
            let product = attributes[kEventProduct] as? RIProduct {
            let params = GAIDictionaryBuilder.createEvent(
                withCategory: screenName,
                action: "AddToCart",
                label: product.sku,
                value: product.price
            )
            self.sendParamsToGA(params: params)
        }
    }
    
    func viewProduct(attributes: EventAttributeType) {
        if let parentScreenName = attributes[kEventScreenName] as? String,
            let product = attributes[kEventProduct] as? RIProduct {
            let params = GAIDictionaryBuilder.createEvent(
                withCategory: "\(parentScreenName)",
                action: "ViewProduct",
                label: product.sku,
                value: product.price
            )
            self.sendParamsToGA(params: params)
        }
    }
    
    
    
    func teaserTapped(attributes: EventAttributeType) {
        if let screenName = attributes[kEventScreenName] as? String,
            let teaserName = attributes[kEventTeaser] as? String,
            let teaserTarget = attributes[kEventTargetString] as? String {
            let params = GAIDictionaryBuilder.createEvent(
                withCategory: "\(screenName)+\(teaserName)",
                action: "TeaserTapped",
                label: teaserTarget,
                value: nil
            )
            self.sendParamsToGA(params: params)
        }
    }
    
    
    func login(attributes: EventAttributeType) {
        if let loginMethod = attributes[kEventMethod] as? String, let user = attributes[kEventUser] as? RICustomer {
            let params = GAIDictionaryBuilder.createEvent(
                withCategory: "Account",
                action: "Login",
                label: "\(loginMethod)",
                value: user.customerId
            )
            self.sendParamsToGA(params: params)
        }
    }
    
    func logout(attributes: EventAttributeType) {
        let params = GAIDictionaryBuilder.createEvent(
            withCategory: "Account",
            action: "Logout",
            label: nil,
            value: nil
        )
        self.sendParamsToGA(params: params)
    }
    
    func signup(attributes: EventAttributeType) {
        if let loginMethod = attributes[kEventMethod] as? String, let success = attributes[kEventSuccess] as? Bool {
            let user = attributes[kEventUser] as? RICustomer
            let params = GAIDictionaryBuilder.createEvent(
                withCategory: "Account",
                action: success ? "SignupSuccess" : "SignupFailed",
                label: "\(loginMethod)",
                value: user?.customerId
            )
            self.sendParamsToGA(params: params)
        }
    }
    
    func checkoutStart(attributes: EventAttributeType) {
        if let cart = attributes[kEventCart] as? RICart {
            let combinedSkus = cart.cartEntity.cartItems.map { ($0 as? RICartItem)?.sku }.flatMap { $0 }.joined(separator: ",")
            let params = GAIDictionaryBuilder.createEvent(
                withCategory: "Checkout",
                action: "CheckoutStart",
                label: combinedSkus,
                value: cart.cartEntity.cartValue
            )
            self.sendParamsToGA(params: params)
        }
    }
    
    func checkoutFinished(attributes: EventAttributeType) {
        if let cart = attributes[kEventCart] as? RICart {
            let combinedSkus = cart.cartEntity.cartItems.map { ($0 as? RICartItem)?.sku }.flatMap { $0 }.joined(separator: ",")
            let params = GAIDictionaryBuilder.createEvent(
                withCategory: "Checkout",
                action: "CheckoutFinish",
                label: combinedSkus,
                value: cart.cartEntity.cartValue
            )
            self.sendParamsToGA(params: params)
        }
    }

    func purchaseBehaviour(attributes: EventAttributeType) {
        if let category = attributes[kGAEventCategory] as? String,
            let label = attributes[kGAEventLabel] as? String {
            let params = GAIDictionaryBuilder.createEvent(
                withCategory: category,
                action: "Purchase",
                label: label,
                value: nil
            )
            self.sendParamsToGA(params: params)
        }
    }
    
    func searchSuggestionTapped(attributes: EventAttributeType) {
        if let suggestionTitle = attributes[kEventSuggestionTitle] as? String {
            let params = GAIDictionaryBuilder.createEvent(
                withCategory: "SearchSuggestions",
                action: "Tapped",
                label: "\(suggestionTitle)",
                value: nil
            )
            self.sendParamsToGA(params: params)
        }
    }
    
    
    func trackLoadTime(screenName: String, interval: NSNumber, label: String) {
        if let timingParms = GAIDictionaryBuilder.createTiming(
            withCategory: "Screen",
            interval: interval,
            name: screenName,
            label: label) {
            self.sendParamsToGA(params: timingParms)
        }
    }
    
    //MARK: - Helper functions
    private func sendParamsToGA(params: GAIDictionaryBuilder?) {
        guard let params = params else { return }
        if let campaignStrig = self.campaginDataString,  campaignStrig.count > 0 {
            let _ = params.setCampaignParametersFromUrl(campaignStrig)
        }
        GAI.sharedInstance().defaultTracker.send(params.build() as! [AnyHashable : Any])
    }
}
