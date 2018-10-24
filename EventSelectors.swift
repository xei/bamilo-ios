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
        return #selector(EventTrackerProtocol.search(attributes:))
    }
    class func searchBarSearchedSelector() -> Selector {
        return #selector(EventTrackerProtocol.searchbarSearched(attributes:))
    }
    class func searchFilteredSelector() -> Selector {
        return #selector(EventTrackerProtocol.searchFiltered(attributes:))
    }
    class func loginEventSelector() -> Selector {
        return #selector(EventTrackerProtocol.login(attributes:))
    }
    class func logoutEventSelector() -> Selector {
        return #selector(EventTrackerProtocol.logout(attributes:))
    }
    class func signupEventSelector() -> Selector {
        return #selector(EventTrackerProtocol.signup(attributes:))
    }
    class func appOpenEventSelector() -> Selector {
        return #selector(EventTrackerProtocol.appOpened(attributes:))
    }
    class func addToCartEventSelector() -> Selector {
        return #selector(EventTrackerProtocol.addToCart(attributes:))
    }
    class func removeFromCartEventSelector() -> Selector {
        return #selector(EventTrackerProtocol.removeFromCart(attributes:))
    }
    class func viewCartEventSelector() -> Selector {
        return #selector(EventTrackerProtocol.viewCart(attributes:))
    }
    class func addToWishListSelector() -> Selector {
        return #selector(EventTrackerProtocol.addToWishList(attributes:))
    }
    class func removeFromWishListSelector() -> Selector {
        return #selector(EventTrackerProtocol.removeFromWishList(attributes:))
    }
    class func purchaseSelector() -> Selector {
        return #selector(EventTrackerProtocol.purchased(attributes:))
    }
    class func itemTappedSelector() -> Selector {
        return #selector(EventTrackerProtocol.itemTapped(attributes:))
    }
    class func behaviourPurchasedSelector() -> Selector {
        return #selector(EventTrackerProtocol.purchaseBehaviour(attributes:))
    }
    class func viewProductSelector() -> Selector {
        return #selector(EventTrackerProtocol.viewProduct(attributes:))
    }
    class func rateProductSelector() -> Selector {
        return #selector(EventTrackerProtocol.rateProduct(attributes:))
    }
    class func callToOrderTappedSelector() -> Selector {
        return #selector(EventTrackerProtocol.callToOrderTapped(attributes:))
    }
    class func openAppSelector() -> Selector {
        return #selector(EventTrackerProtocol.appOpened(attributes:))
    }
    class func recommendationTappedSelector() -> Selector {
        return #selector(EventTrackerProtocol.recommendationTapped(attributes:))
    }
    class func catalogViewChangedSelector() -> Selector {
        return #selector(EventTrackerProtocol.catalogViewChanged(attributes:))
    }
    class func catalogSortChangedSelector() -> Selector {
        return #selector(EventTrackerProtocol.catalogSortChanged(attributes:))
    }
    class func checkoutStartSelector() -> Selector {
        return #selector(EventTrackerProtocol.checkoutStart(attributes:))
    }
    class func checkoutFinishedSelector() -> Selector {
        return #selector(EventTrackerProtocol.checkoutFinished(attributes:))
    }
    class func suggestionTappedSelector() -> Selector {
        return #selector(EventTrackerProtocol.searchSuggestionTapped(attributes:))
    }
    class func shareAppSelector() -> Selector {
        return #selector(EventTrackerProtocol.shareApp(attributes:))
    }
    class func buyNowTappedSelector() -> Selector {
        return #selector(EventTrackerProtocol.buyNowTapped(attributes:))
    }
}
