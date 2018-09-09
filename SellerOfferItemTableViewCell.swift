//
//  SellerOfferItemTableViewCell.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 7/11/18.
//  Copyright © 2018 Rocket Internet. All rights reserved.
//

import UIKit

protocol SellerOfferItemTableViewCellDelegate: class {
    func addToCart(simpleSku: String, product: TrackableProductProtocol)
}

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
    @IBOutlet weak private var sellerScoreContainerWidthConstraint: NSLayoutConstraint!
    
    weak var delegate: SellerOfferItemTableViewCellDelegate?
    var model: SellerListItem?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        applyStyle()
    }
    
    
    override func update(withModel model: Any!) {
        if let item = model as? SellerListItem {
            sellerNameLabel.text = item.seller?.name
            deliveryTimeLabel.text = item.seller?.deliveryTime?.message
            sellerOveralScoreLabel.text = Utility.formatScoreValue(score: item.seller?.score?.overall ?? 0)
            if (item.seller?.score?.overall ?? 0) == 0 {
                sellerOveralScoreLabel.text = STRING_NO_RATE
                sellerScoreContainerWidthConstraint.constant = 65
            } else {
                sellerScoreContainerWidthConstraint.constant = 25
            }
            priceLabel.text = "\(item.productOffer?.price?.value ?? 0)".formatPriceWithCurrency()
            oldPriceLabel.attributedText = "\(item.productOffer?.price?.oldPrice ?? 0)".formatPriceWithCurrency().strucThroughPriceFormat()
            dicountPrecentageLabel?.text = "%\(item.productOffer?.price?.discountPercentage ?? 0)".convertTo(language: .arabic)
            dicountPrecentageWrapperView.isHidden = (item.productOffer?.price?.discountPercentage ?? 0) == 0
            oldPriceLabel.isHidden = (item.productOffer?.price?.oldPrice ?? 0) == 0
            self.model = item
        }
    }
    
    @IBAction func addToCartButtonTapped(_ sender: Any) {
        if let product = self.model?.productOffer {
            self.delegate?.addToCart(simpleSku: product.simpleSku ?? product.sku, product: product)
        }
    }
    
    
    func applyStyle() {
        horizontalSeperatorView.backgroundColor = Theme.color(kColorGray10)
        sellerNameTitleLabel.text = STRING_SELLER_NAME
        deliveryTimeTitleLabel.text = STRING_DELIVERY_TIME
        sellerScoreTitleLabel.text = STRING_SELLER_SCORE
        
        [sellerNameTitleLabel, deliveryTimeTitleLabel, sellerScoreTitleLabel, oldPriceLabel].forEach { $0?.applyStyle(font: Theme.font(kFontVariationRegular, size: 10), color: Theme.color(kColorGray1)) }
        [dicountPrecentageLabel, sellerOveralScoreLabel].forEach { $0?.applyStyle(font: Theme.font(kFontVariationBold, size: 12), color: .white) }
        
        sellerNameLabel.applyStyle(font: Theme.font(kFontVariationBold, size: 12), color: Theme.color(kColorGray1))
        deliveryTimeLabel.applyStyle(font: Theme.font(kFontVariationRegular, size: 12), color: Theme.color(kColorGray1))
        priceLabel.applyStyle(font: Theme.font(kFontVariationBold, size: 14), color: Theme.color(kColorOrange1))
        sellerScoreWrapperView.backgroundColor = Theme.color(kColorGreen)
        sellerScoreWrapperView.clipsToBounds = false
        dicountPrecentageWrapperView.backgroundColor = Theme.color(kColorOrange)
        addToCartButton.backgroundColor = Theme.color(kColorOrange1)
        addToCartButton.setTitle(STRING_ADD_TO_SHOPPING_CART, for: .normal)
        addToCartButton.applyStyle(font: Theme.font(kFontVariationRegular, size: 14), color: .white)
        addToCartButton.layer.cornerRadius = 4
    }
}
