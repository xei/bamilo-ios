//
//  CatalogListCollectionViewCell.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 5/16/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

import UIKit

class CatalogListCollectionViewCell: BaseCatallogCollectionViewCell {
    
    override func setupView() {
        super.setupView()
    }
    
    override func updateWithProduct(product: Product) {
        super.updateWithProduct(product: product)
        
        if let name = product.name {
            let style = NSMutableParagraphStyle()
            style.minimumLineHeight = 18
            style.maximumLineHeight = 18
            self.titleLabel?.attributedText = NSAttributedString(string: name, attributes: [NSParagraphStyleAttributeName: style])
        }
    }
}
