//
//  ProductWarrantyTableViewCell.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 6/11/18.
//  Copyright © 2018 Rocket Internet. All rights reserved.
//

import UIKit

class ProductWarrantyTableViewCell: BaseProductTableViewCell {

    @IBOutlet private weak var warrantyImageView: UIImageView!
    @IBOutlet private weak var warrantyTitleLabel: UILabel!
    @IBOutlet private weak var seeMoreButton: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        warrantyTitleLabel.applyStyle(font: Theme.font(kFontVariationRegular, size: 12), color: Theme.color(kColorGray1))
        seeMoreButton.applyStyle(font: Theme.font(kFontVariationRegular, size: 12), color: Theme.color(kColorBlue))
        
        seeMoreButton.setTitle(STRING_PRIVACY_POLICY, for: .normal)
    }
    
    override func update(withModel model: Any!) {
        if let product = model as? Product {
            self.warrantyTitleLabel.text = product.seller?.warranty
        }
    }
}
