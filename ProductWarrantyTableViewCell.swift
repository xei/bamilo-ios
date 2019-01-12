//
//  ProductWarrantyTableViewCell.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 6/11/18.
//  Copyright © 2018 Rocket Internet. All rights reserved.
//

import UIKit
import Kingfisher

protocol ProductWarrantyTableViewCellDelegate: class {
    func didSelectWarrantyMoreInfo()
}

class ProductWarrantyTableViewCell: BaseProductTableViewCell {

    @IBOutlet private weak var warrantyImageView: UIImageView!
    @IBOutlet private weak var warrantyTitleLabel: UILabel!
    @IBOutlet private weak var seeMoreButton: UIButton!
    @IBOutlet private weak var seeMoreLabel: UILabel!
    weak var delegate: ProductWarrantyTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        warrantyTitleLabel.applyStyle(font: Theme.font(kFontVariationRegular, size: 12), color: Theme.color(kColorGray1))
        seeMoreLabel.applyStyle(font: Theme.font(kFontVariationRegular, size: 12), color: Theme.color(kColorBlue))
        seeMoreLabel.text = STRING_SEE
    }
    
    @IBAction func seeMoreTapped(_ sender: Any) {
        delegate?.didSelectWarrantyMoreInfo()
    }
    
    override func update(withModel model: Any!) {
        if let product = model as? NewProduct {
            warrantyTitleLabel.text = STRING_RETURN_POLICY //product.returnPolicy?.title
            warrantyImageView.kf.setImage(with: product.returnPolicy?.icon, placeholder: #imageLiteral(resourceName: "homepage_slider_placeholder"),options: [.transition(.fade(0.20))])
            
            if let _ = product.returnPolicy?.cmsKey {
                seeMoreButton.isHidden = false
            } else {
                seeMoreButton.isHidden = true
            }
        }
    }
}
