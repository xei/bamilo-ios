//
//  Ext+NSLayoutConstraint.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 10/28/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

import UIKit

extension NSLayoutConstraint {
    func constraintWithMultiplier(_ multiplier: CGFloat) -> NSLayoutConstraint {
        return NSLayoutConstraint(item: self.firstItem, attribute: self.firstAttribute, relatedBy: self.relation, toItem: self.secondItem, attribute: self.secondAttribute, multiplier: multiplier, constant: self.constant)
    }
}
