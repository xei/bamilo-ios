//
//  NavigationBarProtocol.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 7/12/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

import Foundation


@objc protocol NavigationBarProtocol {
    @objc optional func navbarTitleView() -> UIView
    @objc optional func navbarTitleString() -> String
    @objc optional func navbarleftButton() -> NavbarLeftButtonType
    @objc optional func navbarShowBackButton() -> Bool
    
    @objc optional func searchIconButtonTapped()
}
