//
//  CatalogCardCollectionViewCell.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 5/16/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

import UIKit

class CatalogCardCollectionViewCell: BaseCatallogCollectionViewCell {
    
    @IBOutlet weak var discountedPriceTopConstaint: NSLayoutConstraint!
    @IBOutlet weak var rateViewCenterToPriceConstraint: NSLayoutConstraint!
    @IBOutlet weak var rateViewCenterToDiscountedPriceConstraint: NSLayoutConstraint!
    
    let discountedPriceTopConstaintForAvaiableSpecialPrice: CGFloat = 15
    let discountedPriceTopConstaintForNotAvaiableSpecialPrice: CGFloat = 33
    
    override func updateWithProduct(product: Product) {
        super.updateWithProduct(product: product)
        self.discountedPriceTopConstaint.constant = product.specialPrice != nil ? discountedPriceTopConstaintForAvaiableSpecialPrice: discountedPriceTopConstaintForNotAvaiableSpecialPrice
        if product.specialPrice != nil {
            self.rateViewCenterToPriceConstraint.priority = UILayoutPriority(rawValue: 750)
            self.rateViewCenterToDiscountedPriceConstraint.priority = UILayoutPriority(rawValue: 250)
        } else {
            self.rateViewCenterToPriceConstraint.priority = UILayoutPriority(rawValue: 250)
            self.rateViewCenterToDiscountedPriceConstraint.priority = UILayoutPriority(rawValue: 750)
        }
    }
}
