//
//  NavBarUtility.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 7/12/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

import Foundation

@objcMembers class NavBarUtility: NSObject {
    
    static let navbarLogoFrame = CGSize(width: 83, height: 20)
    static let barButtonItemFrame = CGSize(width: 30, height: 30)
    
    class func navBarLogo() -> UIImageView {
        let logoView = UIImageView(image: UIImage(named: "img_navbar_logo"))
        logoView.frame.size = navbarLogoFrame
        return logoView
    }
    
    class func navBarButton(type: NavBarButtonType, viewController: NavigationBarProtocol) -> UIBarButtonItem {
        let button = IconButton(type: .custom)
        button.imageHeightToButtonHeightRatio = 0.8
        
        let buttonNameMapper: [NavBarButtonType: String] = [
            .search : "btn_search",
            .cart : "btn_cart",
            .close : "WhiteClose",
            .darkClose: "GrayClose"
        ]
        if let buttonImageName = buttonNameMapper[type] {
            button.setImage(UIImage(named: buttonImageName), for: UIControlState.normal)
        }
        
        let buttonSelectorMapper: [NavBarButtonType: Selector] = [
            .search : #selector(viewController.searchIconButtonTapped),
            .cart : #selector(viewController.cartIconButtonTapped),
            .close : #selector(viewController.closeButtonTapped),
            .darkClose : #selector(viewController.closeButtonTapped)
        ]
        
        if let buttonAction = buttonSelectorMapper[type] {
            button.addTarget(viewController, action:buttonAction , for: UIControlEvents.touchUpInside)
        }
        
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
    
    class func changeStatusBarColor(color: UIColor) {
        (UIApplication.shared.value(forKey: "statusBar") as? UIView)?.backgroundColor = color
    }
    
    class func getStatusBarHeight() -> CGFloat {
        return UIApplication.shared.statusBarFrame.size.height
    }
}
