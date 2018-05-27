//
//  OrderCancellationResultTableViewCell.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 1/14/18.
//  Copyright © 2018 Rocket Internet. All rights reserved.
//

import UIKit
import Kingfisher

class OrderCancellationResultTableViewCell: BaseTableViewCell {
    
    @IBOutlet weak private var productImage: UIImageView!
    @IBOutlet weak private var productNameLabel: UILabel!
    @IBOutlet weak private var productAttributesLabel: UILabel!
    @IBOutlet weak private var productQuantityLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.productNameLabel.applyStyle(font: Theme.font(kFontVariationRegular, size: 13), color: Theme.color(kColorGray1))
        self.productAttributesLabel.applyStyle(font: Theme.font(kFontVariationRegular, size: 13), color: Theme.color(kColorGray1))
        self.productQuantityLabel.applyStyle(font: Theme.font(kFontVariationRegular, size: 13), color: Theme.color(kColorGray1))
    }
    
    override func update(withModel model: Any!) {
        super.update(withModel: model)
        if let canceledItem = model as? CancellingOrderProduct {
            self.productNameLabel.text = canceledItem.name
            self.productAttributesLabel.text = canceledItem.color
            self.productImage.kf.setImage(with: canceledItem.imageUrl, placeholder: UIImage(named: "placeholder_list"), options: [.transition(.fade(0.20))])
            self.productQuantityLabel.text = "\(STRING_QUANTITY): \(canceledItem.cancellingQuantity)".convertTo(language: .arabic)
        }
    }
    
    override class func nibName() -> String {
        return AppUtility.getStringFromClass(for: self)!
    }
}
