//
//  EventSelectors.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 7/8/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

import Foundation

//TODO: this global variable (selectors) can be defined more easier, 
//but we have to define them for now like this, because objective c files can see them
@objcMembers class EventSelectors: NSObject {
    class func searchActionSelector() -> Selector {
        return Selector(("searchWithAttributes:"))
    }
    class func searchBarSearchedSelector() -> Selector {
        return Selector(("searchbarSearchedWithAttributes:"))
    }
    class func searchFilteredSelector() -> Selector {
        return Selector(("searchFilteredWithAttributes:"))
    }
    class func loginEventSelector() -> Selector {
        return Selector(("loginWithAttributes:"))
    }
    class func logoutEventSelector() -> Selector {
        return Selector(("logoutWithAttributes:"))
    }
    class func signupEventSelector() -> Selector {
        return Selector(("signupWithAttributes:"))
    }
    class func appOpenEventSelector() -> Selector {
        return Selector(("appOpenedWithAttributes:"))
    }
    class func addToCartEventSelector() -> Selector {
        return Selector(("addToCartWithAttributes:"))
    }
    class func removeFromCartEventSelector() -> Selector {
        return Selector(("removeFromCartWithAttributes:"))
    }
    class func viewCartEventSelector() -> Selector {
        return Selector(("viewCartWithAttributes:"))
    }
    class func addToWishListSelector() -> Selector {
        return Selector(("addToWishListWithAttributes:"))
    }
    class func removeFromWishListSelector() -> Selector {
        return Selector(("removeFromWishListWithAttributes:"))
    }
    class func purchaseSelector() -> Selector {
        return Selector(("purchasedWithAttributes:"))
    }
    class func itemTappedSelector() -> Selector {
        return Selector(("itemTappedWithAttributes:"))
    }
    class func behaviourPurchasedSelector() -> Selector {
        return Selector(("purchaseBehaviourWithAttributes:"))
    }
    class func viewProductSelector() -> Selector {
        return Selector(("viewProductWithAttributes:"))
    }
    class func rateProductSelector() -> Selector {
        return Selector(("rateProductWithAttributes:"))
    }
    class func callToOrderTappedSelector() -> Selector {
        return Selector(("callToOrderTappedWithAttributes:"))
    }
    class func openAppSelector() -> Selector {
        return Selector(("appOpenedWithAttributes:"))
    }
    class func recommendationTappedSelector() -> Selector {
        return Selector(("recommendationTappedWithAttributes:"))
    }
    class func catalogViewChangedSelector() -> Selector {
        return Selector(("catalogViewChangedWithAttributes:"))
    }
    class func catalogSortChangedSelector() -> Selector {
        return Selector(("catalogSortChangedWithAttributes:"))
    }
    class func checkoutStartSelector() -> Selector {
        return Selector(("checkoutStartWithAttributes:"))
    }
    class func checkoutFinishedSelector() -> Selector {
        return Selector(("checkoutFinishedWithAttributes:"))
    }
    class func suggestionTappedSelector() -> Selector {
        return Selector(("searchSuggestionTappedWithAttributes:"))
    }
    
    class func buyNowTappedSelector() -> Selector {
        return Selector(("buyNowTappedWithAttributes:"))
    }
}
