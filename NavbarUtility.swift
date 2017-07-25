//
//  NavbarUtility.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 7/12/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

import Foundation

@objc class NavbarUtility: NSObject {
    static func navbarLogo() -> UIImageView {
        let logoView = UIImageView(image: UIImage(named: "img_navbar_logo"))
        logoView.frame.size = CGSize(width: 83, height: 20)
        return logoView
    }
    
    static func navbarSearchButton(viewController: NavigationBarProtocol) -> UIBarButtonItem {
        let button = IconButton(type: .custom)
        button.imageHeightToButtonHeightRatio = 0.8
        button.setImage(UIImage(named: "btn_search"), for: UIControlState.normal)
        button.addTarget(viewController, action:#selector(viewController.searchIconButtonTapped), for: UIControlEvents.touchUpInside)
        button.frame.size = CGSize(width: 30, height: 30)
        let barButton = UIBarButtonItem(customView: button)
        return barButton
    }
}
