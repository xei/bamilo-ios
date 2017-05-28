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
    
    let discountedPriceTopConstaintForAvaiableSpecialPrice: CGFloat = 4
    let discountedPriceTopConstaintForNotAvaiableSpecialPrice: CGFloat = 20
    
    override func setupView() {
        super.setupView()
    }
    
    override func updateWithProduct(product: Product) {
        super.updateWithProduct(product: product)
        self.discountedPriceTopConstaint.constant = product.specialPrice != nil ? discountedPriceTopConstaintForAvaiableSpecialPrice: discountedPriceTopConstaintForNotAvaiableSpecialPrice
    }
}
