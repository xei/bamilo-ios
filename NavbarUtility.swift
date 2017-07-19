//
//  NavbarUtility.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 7/12/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

import Foundation

class NavbarUtility {
    static func navbarLogo() -> UIImageView {
        let logoView = UIImageView(image: UIImage(named: "img_navbar_logo"))
        logoView.frame.size = CGSize(width: 83, height: 20)
        return logoView
    }
}
