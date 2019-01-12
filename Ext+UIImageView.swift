//
//  Ext+UIImageView.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 9/22/18.
//  Copyright © 2018 Rocket Internet. All rights reserved.
//

import UIKit

extension UIImageView {
    func applyTintColor(color: UIColor) {
        self.image = self.image?.withRenderingMode(.alwaysTemplate)
        self.tintColor = color
    }
}
