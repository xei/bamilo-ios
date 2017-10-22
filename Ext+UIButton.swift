//
//  Ext+UIButton.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 10/22/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

import UIKit

extension UIButton {
    func applyStyle(font: UIFont, color: UIColor) {
        self.titleLabel?.font = font
        self.setTitleColor(color, for: .normal)
    }
}
