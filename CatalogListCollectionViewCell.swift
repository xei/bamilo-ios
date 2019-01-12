//
//  CatalogListCollectionViewCell.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 5/16/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

import UIKit

class CatalogListCollectionViewCell: BaseCatallogCollectionViewCell {
    
    @IBOutlet weak var badgeWrapperBottomToNewTagViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var verticalBadgeToNewTagConstraint: NSLayoutConstraint!
    
    override func setupView() {
        super.setupView()
    }
    
    override func updateWithProduct(product: Product) {
        super.updateWithProduct(product: product)
        
        if let name = product.name {
            let style = NSMutableParagraphStyle()
            style.minimumLineHeight = 18
            style.maximumLineHeight = 18
            self.titleLabel?.attributedText = NSAttributedString(string: name, attributes: [NSAttributedStringKey.paragraphStyle: style])
        }
        
        if let badge = product.badge, badge.count > 0, product.isNew {
            badgeWrapperBottomToNewTagViewConstraint.priority = .defaultLow
            verticalBadgeToNewTagConstraint.priority = .defaultHigh
        } else {
            badgeWrapperBottomToNewTagViewConstraint.priority = .defaultHigh
            verticalBadgeToNewTagConstraint.priority = .defaultLow
        }
    }
}
