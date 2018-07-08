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
    @IBOutlet weak private var ratingCountLabel: UILabel!
    @IBOutlet weak private var noRateLabel: UILabel!
    @IBOutlet weak private var seperatorLineView: UIView!
    @IBOutlet weak private var priceLabel: UILabel!
    @IBOutlet weak private var currencyLabel: UILabel!
    @IBOutlet weak private var discountedPriceLabel: UILabel!
    @IBOutlet weak private var calculatedBenefitLabel: UILabel!
    @IBOutlet weak private var discountPercentageLabel: UILabel!
    @IBOutlet weak private var discountPercentageContainerView: UIView!
    @IBOutlet weak private var ratePresentorContainerView: UIView!
    @IBOutlet weak private var rateItButton: UIButton!
    weak var delegate: BaseProductTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.applyStyle()
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear
        self.clipsToBounds = false
        self.contentView.clipsToBounds = false
    }
    
    private func applyStyle() {
        self.containerBoxView?.backgroundColor = .white
        seperatorLineView.backgroundColor = Theme.color(kColorGray10)
        [calculatedBenefitLabel, discountedPriceLabel].forEach { $0.applyStyle(font: Theme.font(kFontVariationLight, size: 11), color: Theme.color(kColorGray3)) }
        [productNameLabel, rateValueLabel].forEach { $0?.applyStyle(font: Theme.font(kFontVariationBold, size: 15), color: Theme.color(kColorGray1)) }
        [rateTitleLabel, ratingCountLabel, currencyLabel].forEach {$0?.applyStyle(font: Theme.font(kFontVariationLight, size: 12), color: Theme.color(kColorGray1))}
        priceLabel.applyStyle(font: Theme.font(kFontVariationBold, size: 25), color: Theme.color(kColorOrange1))
        noRateLabel.applyStyle(font: Theme.font(kFontVariationLight, size: 12), color: Theme.color(kColorGray3))
        discountPercentageContainerView.applyBorder(width: 1, color: Theme.color(kColorOrange1))
        discountPercentageLabel.applyStyle(font: Theme.font(kFontVariationLight, size: 11), color: Theme.color(kColorOrange1))
        discountPercentageLabel.textAlignment = .center
        discountPercentageLabel.clipsToBounds = false
        self.rateItButton.setTitle(STRING_RATE, for: .normal)
        self.rateItButton.applyStyle(font: Theme.font(kFontVariationLight, size: 13), color: Theme.color(kColorBlue1))
    }
    
    override func update(withModel model: Any!) {
        if let product = model as? Product {
            self.productNameLabel.text = product.name
            if let specialPrice = product.specialPrice, let price = product.price, product.price != product.specialPrice {
                discountedPriceLabel?.attributedText = "\(price)".formatPriceWithCurrency().strucThroughPriceFormat()
                priceLabel?.text = "\(specialPrice)".convertTo(language: .arabic).priceFormat()
                if let precentage = product.maxSavingPrecentage {
                    discountPercentageLabel?.text = "%\(precentage)".convertTo(language: .arabic)
                } else {
                    discountPercentageLabel?.text = ""
                }
                discountPercentageLabel.isHidden = false
                discountPercentageContainerView.isHidden = false
                calculatedBenefitLabel.isHidden = false
            } else if let price = product.price {
                priceLabel?.text = "\(price)".convertTo(language: .arabic).priceFormat()
                discountedPriceLabel?.text = nil
                discountPercentageLabel?.text = nil
                discountPercentageLabel.isHidden = true
                discountPercentageContainerView.isHidden = true
                calculatedBenefitLabel.isHidden = true
            }
            
            if let rateCount = product.ratings?.totalCount, let rateAverage = product.ratings?.average , rateCount != 0 {
                noRateLabel.isHidden = true
                self.rateItButton.isHidden = true
                ratePresentorContainerView.isHidden = false
                rateValueLabel?.isHidden = false
                rateViewControl?.isHidden = false
                rateValueLabel?.text = "\(rateAverage)".convertTo(language: .arabic)
                ratingCountLabel.text = "(\(rateCount)".convertTo(language: .arabic)
                rateViewControl?.update(withModel: rateAverage)
            } else {
                rateValueLabel?.isHidden = true
                rateViewControl?.isHidden = true
                noRateLabel.isHidden = false
                ratePresentorContainerView.isHidden = true
                self.rateItButton.isHidden = false
            }
        }
    }
    @IBAction func rateButtonTapped(_ sender: Any) {
        self.delegate?.rateButtonTapped?(cell: self)
    }
}
