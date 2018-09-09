//
//  MainTabBarViewController.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 5/31/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

import UIKit
import Crashlytics

@objcMembers class MainTabBarViewController: UITabBarController, UITabBarControllerDelegate, DataServiceProtocol {
    
    private static var previousSelectedViewController: JACenterNavigationController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setRTL()
        NavBarUtility.changeStatusBarColor(color: Theme.color(kColorExtraDarkBlue))
        
        self.tabBar.isTranslucent = false
        self.delegate = self
        
        MainTabBarViewController.activateTabItem(rootViewClassType: HomeViewController.self)
        
        self.tabBar.tintColor = Theme.color(kColorExtraDarkBlue)
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedStringKey.font: Theme.font(kFontVariationRegular, size: 9), NSAttributedStringKey.foregroundColor: Theme.color(kColorExtraDarkBlue)], for: .selected)
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedStringKey.font: Theme.font(kFontVariationRegular, size: 8), NSAttributedStringKey.foregroundColor: Theme.color(kColorExtraDarkGray)], for: UIControlState())
        
        self.tabBar.layer.borderWidth = 0.50
        self.tabBar.layer.borderColor = Theme.color(kColorLightGray).cgColor //UIColor.clear.cgColor
        self.tabBar.clipsToBounds = true
        
        
        let attributes: [String : Any] = [NSAttributedStringKey.font.rawValue: Theme.font(kFontVariationRegular, size: 13)]

        if #available(iOS 10.0, *) {
            self.tabBar.items?.first?.setBadgeTextAttributes(attributes, for: .normal)
            UITabBarItem.appearance().badgeColor = Theme.color(kColorOrange)
        } else {}
        
        self.updateUserSessionAndCart()
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateUserSessionAndCart), name: NSNotification.Name(NotificationKeys.EnterForground), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateCartListener(notification:)), name: NSNotification.Name(NotificationKeys.UpdateCart), object: nil)
    }
    
    func updateCartListener(notification: Notification) {
        if let cart = notification.userInfo?[NotificationKeys.NotificationCart] as? RICart {
            MainTabBarViewController.updateCartValue(cart: cart)
        }
    }
    
    func updateUserSessionAndCart() {
        //Get user and cart to refresh from server
        if let currentUser = RICustomer.getCurrent() {
            EmarsysPredictManager.setCustomer(currentUser)
            PushWooshTracker.setUserID(currentUser.customerId.stringValue)
            Crashlytics.sharedInstance().setUserName(currentUser.email)
        }
        self.getAndUpdateCart()
    }
    
    func getAndUpdateCart() {
        CartDataManager.sharedInstance.getUserCart(self, type: .background) { data, errorMessages in
            self.bind(data, forRequestId: 0)
        };
    }
    
    class func sharedInstance() -> MainTabBarViewController? {
        return UIApplication.shared.delegate?.window??.rootViewController as? MainTabBarViewController
    }
    
    private func setRTL() {
        if #available(iOS 9.0, *) {
            UIView.appearance().semanticContentAttribute = .forceRightToLeft
            UINavigationBar.appearance().semanticContentAttribute = .forceRightToLeft
        } else {
            // Fallback on earlier versions
        }
    }
    
    //MARk: - UITabBarControllerDelegate
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if let centerNav = viewController as? JACenterNavigationController, centerNav != MainTabBarViewController.previousSelectedViewController {
            MainTabBarViewController.previousSelectedViewController?.removeObservingNotifications()
            centerNav.registerObservingOnNotifications()
            MainTabBarViewController.previousSelectedViewController = centerNav
            
            
            //Whenever we go to cart tab bar item, we need to go to the root of this tab bar item
            if centerNav.viewControllers.first is CartViewController {
               centerNav.popToRootViewController(animated: false)
            }
        }
    }
    
    class func activateTabItem<T>(rootViewClassType: T.Type) {
        let tabBarController = MainTabBarViewController.sharedInstance()
        if let index = tabBarController?.viewControllers?.index(where: {
            if ($0 as! UINavigationController).viewControllers.count > 0 {
                return ($0 as? UINavigationController)?.viewControllers[0] is T
            }
            return false
        }) {
            tabBarController?.selectedIndex = index
            if let navigationController = tabBarController?.viewControllers?[index] as? JACenterNavigationController {
                navigationController.popToRootViewController(animated: false)
                MainTabBarViewController.previousSelectedViewController?.removeObservingNotifications()
                navigationController.registerObservingOnNotifications()
                MainTabBarViewController.previousSelectedViewController = navigationController
            }
        }
    }
    
    class func isTabItemActive<T>(tabItemClassType: T.Type) -> Bool {
        let tabBarController = MainTabBarViewController.sharedInstance()
        if (tabBarController?.selectedViewController as! UINavigationController).viewControllers.count > 0 {
            return (tabBarController?.selectedViewController as? UINavigationController)?.viewControllers[0] is T
        }
        return false
    }
    
    
    class func topNavigationController() -> JACenterNavigationController? {
        return MainTabBarViewController.sharedInstance()?.selectedViewController as? JACenterNavigationController
    }
    
    class func topViewController() -> UIViewController? {
        return self.topNavigationController()?.visibleViewController
    }
    
    class func updateCartValue(cart: RICart) {
        if let cartItemsCount = cart.cartEntity?.cartCount?.intValue {
            MainTabBarViewController.sharedInstance()?.tabBar.items?.last?.badgeValue = cartItemsCount == 0 ? nil : "\(cartItemsCount)" //.convertTo(language: .arabic)
        }
        
        MainTabBarViewController.sharedInstance()?.viewControllers?.forEach {
            ($0 as? JACenterNavigationController)?.updateCart(with: cart)
        }
    }
    
    class func getTabbarItemView<T>(rootViewClassType: T.Type) -> UIView? {
        let tabBarController = MainTabBarViewController.sharedInstance()
        var targetView: UIView?
        if let index = tabBarController?.viewControllers?.index(where: {
            if ($0 as! UINavigationController).viewControllers.count > 0 {
                return ($0 as? UINavigationController)?.viewControllers[0] is T
            }
            return false
        }) {
            if let view = tabBarController?.tabBar.items?[index].value(forKey: "view") as? UIView {
                targetView = view
            }
        }
        return targetView
    }
    
    //TODO: Temprory helper functions (for objective c codes)
    class func showHome() {
        MainTabBarViewController.activateTabItem(rootViewClassType: HomeViewController.self)
    }
    
    class func showWishList() {
        MainTabBarViewController.activateTabItem(rootViewClassType: WishListViewController.self)
    }
    
    class func showProfile() {
        MainTabBarViewController.activateTabItem(rootViewClassType: ProfileViewController.self)
    }
    
    class func showCart() {
        MainTabBarViewController.activateTabItem(rootViewClassType: CartViewController.self)
    }
    
    class func showCategories() {
        MainTabBarViewController.activateTabItem(rootViewClassType: RootCategoryViewController.self)
    }
    
    
    //MARK: - DataServiceProtocol 
    func bind(_ data: Any!, forRequestId rid: Int32) {
        if let cart = data as? RICart {
            NotificationCenter.default.post(name: NSNotification.Name(NotificationKeys.UpdateCart), object: nil, userInfo: [NotificationKeys.NotificationCart : cart])
        }
    }
}
