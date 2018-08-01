//
//  ProductDetailPrimaryInfoTableViewCell.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 5/28/18.
//  Copyright © 2018 Rocket Internet. All rights reserved.
//

import UIKit

protocol ProductDetailPrimaryInfoTableViewCellDelegate: class {
    func rateButtonTapped()
    func brandButtonTapped()
    func seeAllCommentButttonTapped()
}

class ProductDetailPrimaryInfoTableViewCell: BaseProductTableViewCell {
    
    @IBOutlet weak private var userIcon: UIImageView!
    @IBOutlet weak private var productNameLabel: UILabel!
    @IBOutlet weak private var rateViewControl: RateStarControl!
    @IBOutlet weak private var rateTitleLabel: UILabel!
    @IBOutlet weak private var rateValueLabel: UILabel!
    @IBOutlet weak private var ratingCountLabel: UILabel!
    @IBOutlet weak private var noRateLabel: UILabel!
    @IBOutlet weak private var seperatorLineView: UIView!
    @IBOutlet weak private var priceLabel: UILabel!
    @IBOutlet weak private var currencyLabel: UILabel!
    @IBOutlet weak private var discountPercentageLabel: UILabel!
    @IBOutlet weak private var calculatedBenefitLabel: UILabel!
    @IBOutlet weak private var oldPriceLabel: UILabel!
    @IBOutlet weak private var discountPercentageContainerView: UIView!
    @IBOutlet weak private var ratePresentorContainerView: UIView!
    @IBOutlet weak private var brandlabel: UILabel!
    @IBOutlet weak private var rateItButton: IconButton!
    weak var delegate: ProductDetailPrimaryInfoTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.applyStyle()
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear
        self.clipsToBounds = false
        self.contentView.clipsToBounds = false
    }
    
    private func applyStyle() {
        containerBoxView?.backgroundColor = .white
        seperatorLineView.backgroundColor = Theme.color(kColorGray10)
        [calculatedBenefitLabel, oldPriceLabel].forEach { $0.applyStyle(font: Theme.font(kFontVariationLight, size: 11), color: Theme.color(kColorGray3)) }
        
        calculatedBenefitLabel.textColor = Theme.color(kColorGray1)
        [productNameLabel, rateValueLabel].forEach { $0?.applyStyle(font: Theme.font(kFontVariationBold, size: 15), color: Theme.color(kColorGray1)) }
        [rateTitleLabel, ratingCountLabel, currencyLabel].forEach {$0?.applyStyle(font: Theme.font(kFontVariationLight, size: 12), color: Theme.color(kColorGray1))}
        priceLabel.applyStyle(font: Theme.font(kFontVariationBold, size: 25), color: Theme.color(kColorOrange1))
        noRateLabel.applyStyle(font: Theme.font(kFontVariationLight, size: 12), color: Theme.color(kColorGray3))
        
        discountPercentageContainerView.backgroundColor = Theme.color(kColorOrange1)
        discountPercentageContainerView.layer.cornerRadius = 4
        discountPercentageContainerView.clipsToBounds = true
        
        discountPercentageLabel.applyStyle(font: Theme.font(kFontVariationLight, size: 11), color: .white)
        discountPercentageLabel.textAlignment = .center
        discountPercentageLabel.clipsToBounds = false
        
        rateItButton.setTitle(STRING_RATE_IT, for: .normal)
        rateItButton.applyStyle(font: Theme.font(kFontVariationLight, size: 13), color: Theme.color(kColorBlue))
        brandlabel.applyStyle(font: Theme.font(kFontVariationLight, size: 10), color: Theme.color(kColorBlue))
        rateItButton.setImage( #imageLiteral(resourceName: "ProductComment").withRenderingMode(.alwaysTemplate), for: .normal)
        rateItButton.imageView?.tintColor = Theme.color(kColorBlue)
        userIcon.image = #imageLiteral(resourceName: "ic_user_form").withRenderingMode(.alwaysTemplate)
        userIcon.tintColor = Theme.color(kColorGray8)
    }
    
    override func update(withModel model: Any!) {
        if let product = model as? NewProduct {
            productNameLabel.text = product.name
            priceLabel.text = "\(product.price?.value ?? 0)".convertTo(language: .arabic).priceFormat()
            oldPriceLabel.attributedText = product.price?.oldPrice != nil ? "\(product.price?.oldPrice ?? 0)".formatPriceWithCurrency().strucThroughPriceFormat() : nil
            oldPriceLabel.isHidden = (product.price?.oldPrice ?? 0) == 0
            discountPercentageLabel.text = product.price?.discountPercentage != nil ? "%\(product.price?.discountPercentage ?? 0)".convertTo(language: .arabic) : nil
            calculatedBenefitLabel.text = "سود شما : \("\(product.price?.discountBenefit ?? 0)".formatPriceWithCurrency())"
            discountPercentageContainerView.isHidden = (product.price?.discountPercentage ?? 0) == 0
            brandlabel.text = product.brand
            if let rateCount = product.ratings?.totalCount, let rateAverage = product.ratings?.average , rateCount != 0 {
                noRateLabel.isHidden = true
                self.rateItButton.isHidden = true
                ratePresentorContainerView.isHidden = false
                rateValueLabel?.isHidden = false
                rateViewControl?.isHidden = false
                rateValueLabel?.text = Utility.formatScoreValue(score: rateAverage)
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
        self.delegate?.rateButtonTapped()
    }
    @IBAction func brandButtonTapped(_ sender: Any) {
        delegate?.brandButtonTapped()
    }
    @IBAction func seeAllCommentsButtonTapped(_ sender: Any) {
        delegate?.seeAllCommentButttonTapped()
    }
}
