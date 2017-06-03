//
//  MainTabBarViewController.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 5/31/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

import UIKit

@objc class MainTabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tabBar.isTranslucent = false
        
        self.tabBar.tintColor = Theme.color(kColorOrange)
        UITabBarItem.appearance().setTitleTextAttributes([NSFontAttributeName: Theme.font(kFontVariationRegular, size: 9), NSForegroundColorAttributeName: Theme.color(kColorOrange)], for: .selected)
        UITabBarItem.appearance().setTitleTextAttributes([NSFontAttributeName: Theme.font(kFontVariationRegular, size: 8), NSForegroundColorAttributeName: Theme.color(kColorExtraDarkGray)], for: UIControlState())
    }
    
    
    static func sharedInstance() -> MainTabBarViewController? {
        return UIApplication.shared.delegate?.window??.rootViewController as? MainTabBarViewController
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
            if let tabbar = tabBarController?.tabBar, let tabItem = tabBarController?.tabBar.items?[index] {
                tabBarController?.tabBar(tabbar, didSelect: tabItem)
            }
            if let navigationController = tabBarController?.viewControllers?[index] as? UINavigationController {
                navigationController.popToRootViewController(animated: false)
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
}
