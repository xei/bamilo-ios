//
//  ProductDetailPrimaryInfoTableViewCell.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 5/28/18.
//  Copyright © 2018 Rocket Internet. All rights reserved.
//

import UIKit

class ProductDetailPrimaryInfoTableViewCell: BaseProductTableViewCell {
    
    @IBOutlet weak private var productNameLabel: UILabel!
    @IBOutlet weak private var rateViewControl: RateStarControl!
    @IBOutlet weak private var rateTitleLabel: UILabel!
    @IBOutlet weak private var rateValueLabel: UILabel!
    @IBOutlet weak private var commentsCountLabel: UILabel!
    @IBOutlet weak private var noRateLabel: UILabel!
    @IBOutlet weak private var seperatorLineView: UIView!
    @IBOutlet weak private var priceLabel: UILabel!
    @IBOutlet weak private var currencyLabel: UILabel!
    @IBOutlet weak private var discountedPriceLabel: UILabel!
    @IBOutlet weak private var calculatedBenefitLabel: UILabel!
    @IBOutlet weak private var discountPercentageLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.applyStyle()
    }
    
    private func applyStyle() {
        seperatorLineView.backgroundColor = Theme.color(kColorGray8)
        [calculatedBenefitLabel, discountedPriceLabel].forEach { $0.applyStyle(font: Theme.font(kFontVariationLight, size: 11), color: Theme.color(kColorGray3)) }
        [productNameLabel, rateValueLabel].forEach { $0?.applyStyle(font: Theme.font(kFontVariationBold, size: 12), color: Theme.color(kColorGray1)) }
        [rateTitleLabel, commentsCountLabel, currencyLabel].forEach {$0?.applyStyle(font: Theme.font(kFontVariationLight, size: 12), color: Theme.color(kColorGray1))}
        priceLabel.applyStyle(font: Theme.font(kFontVariationLight, size: 25), color: Theme.color(kColorOrange1))
        noRateLabel.applyStyle(font: Theme.font(kFontVariationLight, size: 12), color: Theme.color(kColorGray3))
    }
}
