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
        if let GAID = AppUtility.getInfoConfigs(for: "GoogleAnalyticsID") as? String {
            GAI.sharedInstance().tracker(withTrackingId: GAID)
        }
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
            
            //Ecommerce tracking
            self.sendEcommerceEvent(product: product, actionName: kGAIPAAdd)
        }
    }
    
    func removeFromCart(attributes: EventAttributeType) {
        if let product = attributes[kEventProduct] as? RIProduct {
            let params = GAIDictionaryBuilder.createEvent(
                withCategory: "CART",
                action: "RemoveFromCart",
                label: product.sku,
                value: product.price
            )
            self.sendParamsToGA(params: params)
            
            //Ecommerce tracking
            self.sendEcommerceEvent(product: product, actionName: kGAIPARemove)
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
        if  let teaserName = attributes[kEventTeaser] as? String,
            let teaserTarget = attributes[kEventTargetString] as? String {
            let params = GAIDictionaryBuilder.createEvent(
                withCategory: teaserName,
                action: "Tapped",
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
            let combinedSkus = cart.cartEntity.cartItems.map { $0.sku }.flatMap { $0 }.joined(separator: ",")
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
            var combinedSkus: String?
            if let cartItems = cart.cartEntity.cartItems,  cartItems.count > 0 {
                combinedSkus = cart.cartEntity.cartItems?.map { $0.sku }.flatMap { $0 }.joined(separator: ",")
            } else if let packages = cart.cartEntity.packages, packages.count > 0 {
                combinedSkus = cart.cartEntity.packages.map{$0.products}.flatMap{$0}.flatMap{$0}.map { $0.sku }.flatMap { $0 }.joined(separator: ",")
            }

            let combinedSkusFromPackages = cart.cartEntity.packages.map{$0.products}.flatMap{$0}.flatMap{$0}.map{$0.sku}.flatMap {$0}.joined(separator: ",")
            let params = GAIDictionaryBuilder.createEvent(
                withCategory: "Checkout",
                action: "CheckoutFinish",
                label: combinedSkus ?? combinedSkusFromPackages,
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
                action: "Purchased",
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
    
    
    
    // --- GA ECommerce trackings ----
    func trackProductImpression(products: [Product], impressionList: String, impressionSource: String) {
        let builder = GAIDictionaryBuilder.createScreenView()
        products.map { (product) -> GAIEcommerceProduct in
            let gaProduct = GAIEcommerceProduct()
            gaProduct.setId(product.sku)
            gaProduct.setName(product.name)
            gaProduct.setBrand(product.brand)
            if let price = product.price {
                gaProduct.setPrice(NSNumber(value: price))
            }
            return gaProduct
        }.forEach{ let _ = builder?.addProductImpression($0, impressionList: impressionList, impressionSource: impressionSource) }
        self.sendParamsToGA(params: builder)
    }
    
    
    func trackEcommerceProductClick(product: RIProduct) {  //RIProduct must be replaced with Product after PDVController refactor
        self.sendEcommerceEvent(product: product, actionName: kGAIPAClick)
    }
    
    func trackEcommerceProductDetailView(product: RIProduct) {
        self.sendEcommerceEvent(product: product, actionName: kGAIPADetail)
    }
    
    func trackEcommerceCartInCheckout(cart: RICart, step: NSNumber, options: String? = nil) {
        let builder = GAIDictionaryBuilder.createEvent(withCategory: "Ecommerce", action: "Checkout", label: nil, value: nil)
        
        if let cartItems = cart.cartEntity.cartItems,  cartItems.count > 0 {
            cart.cartEntity.cartItems.map { self.convertCartItemToGAIProduct(cartItem: $0) }.forEach { let _ = builder?.add($0) }
        } else if let packages = cart.cartEntity.packages, packages.count > 0 {
            cart.cartEntity.packages.map{$0.products}.flatMap{$0}.flatMap{$0}.map { self.convertCartItemToGAIProduct(cartItem: $0) }.forEach { let _ = builder?.add($0) }
        }
        
        let action = GAIEcommerceProductAction()
        action.setAction(kGAIPACheckout)
        action.setCheckoutStep(step)
        if let options = options {
            action.setCheckoutOption(options)
        }
        let _ = builder?.setProductAction(action)
        self.sendParamsToGA(params: builder)
    }
    
    
    func trackTransaction(cart: RICart) {
        let builder = GAIDictionaryBuilder.createEvent(withCategory: "Ecommerce", action: "Purchase", label: nil, value: nil)
        
        if let cartItems = cart.cartEntity.cartItems,  cartItems.count > 0 {
            cart.cartEntity.cartItems.map { self.convertCartItemToGAIProduct(cartItem: $0) }.forEach { let _ = builder?.add($0) }
        } else if let packages = cart.cartEntity.packages, packages.count > 0 {
            cart.cartEntity.packages.map{$0.products}.flatMap{$0}.flatMap{$0}.map { self.convertCartItemToGAIProduct(cartItem: $0) }.forEach { let _ = builder?.add($0) }
        }
        
        let action = GAIEcommerceProductAction()
        action.setAction(kGAIPAPurchase)
        action.setShipping(cart.cartEntity.shippingValue)
        if let orderNr = cart.orderNr {
            action.setTransactionId(orderNr)
        }
        action.setAffiliation("Bamilo iOS")
        if let vatValue = cart.cartEntity.vatValue {
            action.setTax(vatValue)
        }
        if let code = cart.cartEntity.couponCode {
            action.setCouponCode(code)
        }
        let _ = builder?.setProductAction(action)
        self.sendParamsToGA(params: builder)
    }
    
    //Ecommerce tracking helpers
    private func sendEcommerceEvent(product: RIProduct, actionName: String) {
        let action = GAIEcommerceProductAction()
        action.setAction(actionName)
        
        let builder = GAIDictionaryBuilder.createScreenView()
        let _ = builder?.setProductAction(action)
        let _ = builder?.add(self.convertRIProductToGAIProduct(product: product))
        
        self.sendParamsToGA(params: builder)
    }
    
    private func convertCartItemToGAIProduct(cartItem: RICartItem) -> GAIEcommerceProduct {
        let gaProduct = GAIEcommerceProduct()
        gaProduct.setId(cartItem.sku)
        gaProduct.setName(cartItem.name)
        gaProduct.setBrand(cartItem.brand)
        if let price = cartItem.price {
            gaProduct.setPrice(price)
        }
        gaProduct.setQuantity(cartItem.quantity)
        gaProduct.setVariant(cartItem.variation)
        return gaProduct
    }
    
    private func convertRIProductToGAIProduct(product: RIProduct) -> GAIEcommerceProduct {
        let gaProduct = GAIEcommerceProduct()
        gaProduct.setId(product.sku)
        gaProduct.setName(product.name)
        gaProduct.setBrand(product.brand)
        if let price = product.price {
            gaProduct.setPrice(price)
        }
        gaProduct.setQuantity(1)
        return gaProduct
    }
    
}
