//
//  MainTabBarViewController.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 5/31/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

import UIKit

@objc class MainTabBarViewController: UITabBarController, UITabBarControllerDelegate, DataServiceProtocol {
    
    private static var previousSelectedViewController: JACenterNavigationController?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tabBar.isTranslucent = false
        self.delegate = self
        
        MainTabBarViewController.activateTabItem(rootViewClassType: JAHomeViewController.self)
        
        self.tabBar.tintColor = Theme.color(kColorOrange)
        UITabBarItem.appearance().setTitleTextAttributes([NSFontAttributeName: Theme.font(kFontVariationRegular, size: 9), NSForegroundColorAttributeName: Theme.color(kColorOrange)], for: .selected)
        UITabBarItem.appearance().setTitleTextAttributes([NSFontAttributeName: Theme.font(kFontVariationRegular, size: 8), NSForegroundColorAttributeName: Theme.color(kColorExtraDarkGray)], for: UIControlState())
        
        self.tabBar.layer.borderWidth = 0.50
        self.tabBar.layer.borderColor = Theme.color(kColorLightGray).cgColor //UIColor.clear.cgColor
        self.tabBar.clipsToBounds = true
        
        
        let attributes: [String : Any] = [NSFontAttributeName: Theme.font(kFontVariationRegular, size: 13)]
        if #available(iOS 10.0, *) {
            self.tabBar.items?.first?.setBadgeTextAttributes(attributes, for: .normal)
        } else {
            
        }
        
        //Get user and cart to refresh from server
        if (RICustomer.checkIfUserIsLogged()) {
            RICustomer.autoLogin(nil)
        }
        
        CartDataManager.sharedInstance.getUserCart(self) { data, errorMessages in
            self.bind(data, forRequestId: 0)
        };
    }
    
    static func sharedInstance() -> MainTabBarViewController? {
        return UIApplication.shared.delegate?.window??.rootViewController as? MainTabBarViewController
    }
    
    //MARk: - UITabBarControllerDelegate
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if let centerNav = viewController as? JACenterNavigationController, centerNav != MainTabBarViewController.previousSelectedViewController {
            centerNav.registerObservingOnNotifications()
            MainTabBarViewController.previousSelectedViewController?.removeObservingNotifications()
            MainTabBarViewController.previousSelectedViewController = centerNav
        }
    }
    
    static func activateTabItem<T>(rootViewClassType: T.Type) {
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
                navigationController.registerObservingOnNotifications()
                MainTabBarViewController.previousSelectedViewController?.removeObservingNotifications()
                MainTabBarViewController.previousSelectedViewController = navigationController
            }
        }
    }
    
    static func isTabItemActive<T>(tabItemClassType: T.Type) -> Bool {
        let tabBarController = MainTabBarViewController.sharedInstance()
        if (tabBarController?.selectedViewController as! UINavigationController).viewControllers.count > 0 {
            return (tabBarController?.selectedViewController as? UINavigationController)?.viewControllers[0] is T
        }
        return false
    }
    
    
    static func topNavigationController() -> JACenterNavigationController? {
        return MainTabBarViewController.sharedInstance()?.selectedViewController as? JACenterNavigationController
    }
    
    static func updateCartValue(cartItemsCount: Int) {
        MainTabBarViewController.sharedInstance()?.tabBar.items?.first?.badgeValue = cartItemsCount == 0 ? nil : "\(cartItemsCount)".convertTo(language: .arabic)
    }
    
    
    //TODO: Temprory helper functions (for objective c codes)
    static func showHome() {
        MainTabBarViewController.activateTabItem(rootViewClassType: JAHomeViewController.self)
    }
    
    static func showWishList() {
        MainTabBarViewController.activateTabItem(rootViewClassType: JASavedListViewController.self)
    }
    
    static func showProfile() {
        MainTabBarViewController.activateTabItem(rootViewClassType: ProfileViewController.self)
    }
    
    static func showCart() {
        MainTabBarViewController.activateTabItem(rootViewClassType: CartViewController.self)
    }
    
    
    //MARK: - DataServiceProtocol 
    func bind(_ data: Any!, forRequestId rid: Int32) {
        NotificationCenter.default.post(name: NSNotification.Name("NOTIFICATION_UPDATE_CART"), object: nil, userInfo: ["NOTIFICATION_UPDATE_CART_VALUE" : data as! RICart])
    }
}
