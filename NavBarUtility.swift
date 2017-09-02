//
//  NavBarUtility.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 7/12/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

import Foundation

@objc class NavBarUtility: NSObject {
    
    static let navbarLogoFrame = CGSize(width: 83, height: 20)
    static let barButtonItemFrame = CGSize(width: 30, height: 30)
    
    static func navBarLogo() -> UIImageView {
        let logoView = UIImageView(image: UIImage(named: "img_navbar_logo"))
        logoView.frame.size = navbarLogoFrame
        return logoView
    }
    
    static func navBarLeftButton(type: NavBarLeftButtonType, viewController: NavigationBarProtocol) -> UIBarButtonItem {
        let button = IconButton(type: .custom)
        button.imageHeightToButtonHeightRatio = 0.8
        
        button.setImage(UIImage(named: type ==  .search ? "btn_search" : "btn_cart"), for: UIControlState.normal)
        button.addTarget(viewController, action: type == .search ? #selector(viewController.searchIconButtonTapped): #selector(viewController.cartIconButtonTapped), for: UIControlEvents.touchUpInside)
        button.frame.size = barButtonItemFrame
        let barButton = UIBarButtonItem(customView: button)
        
        if type == .cart {
            let cartEntity = RICart.sharedInstance().cartEntity
            barButton.badgeValue = "\((cartEntity != nil && cartEntity!.cartCount != nil) ? cartEntity!.cartCount.intValue : 0)"
            barButton.badgeFont = Theme.font(kFontVariationRegular, size: 15)
            barButton.badgePadding = -9
            barButton.badgeBGColor = Theme.color(kColorOrange)
            barButton.badgeOriginX -= 5
        }
        return barButton
    }
    
    static func changeStatusBarColor(color: UIColor) {
        (UIApplication.shared.value(forKey: "statusBar") as? UIView)?.backgroundColor = color
    }
    
    static func getStatusBarHeight() -> CGFloat {
        return UIApplication.shared.statusBarFrame.size.height
    }
}
