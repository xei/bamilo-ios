//
//  SellerOfferItemTableViewCell.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 7/11/18.
//  Copyright © 2018 Rocket Internet. All rights reserved.
//

import UIKit

class SellerOfferItemTableViewCell: BaseProductTableViewCell {

    @IBOutlet weak private var sellerNameTitleLabel: UILabel!
    @IBOutlet weak private var sellerNameLabel: UILabel!
    @IBOutlet weak private var deliveryTimeTitleLabel: UILabel!
    @IBOutlet weak private var deliveryTimeLabel: UILabel!
    @IBOutlet weak private var sellerScoreTitleLabel: UILabel!
    @IBOutlet weak private var sellerScoreWrapperView: UIView!
    @IBOutlet weak private var sellerOveralScoreLabel: UILabel!
    @IBOutlet weak private var horizontalSeperatorView: UIView!
    @IBOutlet weak private var oldPriceLabel: UILabel!
    @IBOutlet weak private var priceLabel: UILabel!
    @IBOutlet weak private var dicountPrecentageLabel: UILabel!
    @IBOutlet weak private var dicountPrecentageWrapperView: UIView!
    @IBOutlet weak private var addToCartButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        applyStyle()
    }
    
    
    override func update(withModel model: Any!) {
        if let item = model as? SellerListItem {
            sellerNameLabel.text = item.seller?.name
            deliveryTimeLabel.text = item.seller?.deliveryTime?.message
            sellerOveralScoreLabel.text = "\(item.seller?.score?.overall ?? 0)"
            priceLabel.text = "\(item.productOffer?.price ?? 0)".formatPriceWithCurrency()
            oldPriceLabel.attributedText = "\(item.productOffer?.price ?? 0)".formatPriceWithCurrency().strucThroughPriceFormat()
            dicountPrecentageLabel?.text = "%\(item.productOffer?.maxSavingPrecentage ?? 0)".convertTo(language: .arabic)
        }
    }
    
    
    func applyStyle() {
        horizontalSeperatorView.backgroundColor = Theme.color(kColorGray5)
        sellerNameTitleLabel.text = STRING_SELLER_NAME
        deliveryTimeTitleLabel.text = STRING_DELIVERY_TIME
        sellerScoreTitleLabel.text = STRING_SELLER_SCORE
        
        [sellerNameTitleLabel, deliveryTimeTitleLabel, sellerScoreTitleLabel].forEach { $0?.applyStyle(font: Theme.font(kFontVariationRegular, size: 10), color: Theme.color(kColorGray1)) }
        [dicountPrecentageLabel, sellerOveralScoreLabel].forEach { $0?.applyStyle(font: Theme.font(kFontVariationBold, size: 12), color: .white) }
        
        sellerNameLabel.applyStyle(font: Theme.font(kFontVariationBold, size: 12), color: Theme.color(kColorGray1))
        deliveryTimeLabel.applyStyle(font: Theme.font(kFontVariationRegular, size: 12), color: Theme.color(kColorGray1))
        sellerOveralScoreLabel.applyStyle(font: Theme.font(kFontVariationBold, size: 12), color: .white)
        priceLabel.applyStyle(font: Theme.font(kFontVariationBold, size: 14), color: Theme.color(kColorOrange))
        sellerScoreWrapperView.backgroundColor = Theme.color(kColorGreen)
        dicountPrecentageWrapperView.backgroundColor = Theme.color(kColorOrange)
        addToCartButton.backgroundColor = Theme.color(kColorOrange1)
        
    }
}
