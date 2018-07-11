
//
//  MinimalProductTableViewCell.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 7/11/18.
//  Copyright © 2018 Rocket Internet. All rights reserved.
//

import UIKit
import Kingfisher

class MinimalProductTableViewCell: BaseProductTableViewCell {

    @IBOutlet weak private var productImageView: UIImageView!
    @IBOutlet weak private var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        applyStyle()
    }
    
    override func update(withModel model: Any!) {
        if let product = model as? Product {
            productImageView.kf.setImage(with: product.imageUrl, options: [.transition(.fade(0.20))])
            titleLabel.text = product.name
        }
    }
    
    func applyStyle() {
        titleLabel.applyStyle(font: Theme.font(kFontVariationRegular, size: 13), color: Theme.color(kColorGray))
        productImageView.layer.cornerRadius = 3
        productImageView.applyShadow(position: CGSize(width:0 , height: 1), color: .black, opacity: 0.2)
    }
}
