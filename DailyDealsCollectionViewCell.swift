//
//  DailyDealsCollectionViewCell.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 10/8/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

import UIKit
import Kingfisher

class DailyDealsCollectionViewCell: BaseCollectionViewCellSwift {

    @IBOutlet weak private var imageview: UIImageView!
    @IBOutlet weak private var containerview: UIView!
    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak private var brandLabel: UILabel!
    @IBOutlet weak private var discountedPriceLabel: UILabel!
    @IBOutlet weak private var priceLabel: UILabel!
    @IBOutlet weak private var bottomBadgeContainerView: UIView!
    @IBOutlet weak private var bottomBadgeLabel: UILabel!
    
    @IBOutlet weak private var imageTopConstraint: NSLayoutConstraint!
    @IBOutlet weak private var imageLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak private var imageBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak private var titleHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak private var brandlabelHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak private var brandBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak private var priceHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak private var discountedPriceHeightConstraint: NSLayoutConstraint!
    
    private static let imagePadding: CGFloat = 8
    private static let labelSmallHeight: CGFloat = 14
    private static let labelBigHeight: CGFloat = 17
    private static let whiteSpaceHeigt: CGFloat = 10
    private var product: Product!
    
    override func setupView() {
        self.contentView.layer.cornerRadius = 1
        self.contentView.clipsToBounds = true
        
        self.applyShadow(position: CGSize(width:0 , height: 1), color: .black, opacity: 0.2)
        self.layer.borderWidth = 0
        self.clipsToBounds = false
        
        self.titleLabel.applyStyle(font: Theme.font(kFontVariationRegular, size: 12), color: Theme.color(kColorGray1))
        self.brandLabel.applyStyle(font: Theme.font(kFontVariationRegular, size: 11), color: Theme.color(kColorSecondaryGray1))
        self.discountedPriceLabel.applyStyle(font: Theme.font(kFontVariationBold, size: 13), color: Theme.color(kColorGray1))
        self.bottomBadgeContainerView.backgroundColor = Theme.color(kColorGray10)
        self.bottomBadgeLabel.applyStyle(font: Theme.font(kFontVariationRegular, size: 10), color: Theme.color(kColorSecondaryGray1))
        self.priceLabel.applyStyle(font: Theme.font(kFontVariationRegular, size: 11), color: Theme.color(kColorSecondaryGray1))
        
        //setting constraints
        self.imageTopConstraint.constant = DailyDealsCollectionViewCell.imagePadding
        self.imageBottomConstraint.constant = DailyDealsCollectionViewCell.imagePadding
        self.imageLeftConstraint.constant = DailyDealsCollectionViewCell.imagePadding
        self.titleHeightConstraint.constant = DailyDealsCollectionViewCell.labelSmallHeight
        self.brandlabelHeightConstraint.constant = DailyDealsCollectionViewCell.labelBigHeight
        self.brandBottomConstraint.constant = DailyDealsCollectionViewCell.whiteSpaceHeigt
        self.priceHeightConstraint.constant = DailyDealsCollectionViewCell.labelBigHeight
        self.discountedPriceHeightConstraint.constant = DailyDealsCollectionViewCell.labelBigHeight
    }
    
    func updateWithModel(product: Product) {
        titleLabel.text = product.name
        brandLabel.text = product.brand
        imageview.kf.indicatorType = .activity
        imageview.kf.setImage(with: product.imageUrl, options: [.transition(.fade(0.20))])
        self.containerview.alpha = 1
        self.bottomBadgeContainerView.backgroundColor = Theme.color(kColorGray10)
        self.bottomBadgeLabel.textColor = Theme.color(kColorSecondaryGray1)
        if let specialPrice = product.specialPrice, let price = product.price, let precentage = product.maxSavingPrecentage {
            bottomBadgeContainerView.isHidden = false
            discountedPriceLabel.text = "\(specialPrice)".formatPriceWithCurrency()
            priceLabel.attributedText = "\(price)".formatPriceWithCurrency().strucThroughPriceFormat()
            bottomBadgeLabel.text = "%\(precentage)".convertTo(language: .arabic)
        } else if let price = product.price {
            discountedPriceLabel.text = "\(price)".formatPriceWithCurrency()
            priceLabel.text = nil
            bottomBadgeLabel.text = nil
            bottomBadgeContainerView.isHidden = true
        }
        if (!product.hasStock) {
            self.priceLabel.text = nil
            self.containerview.alpha = 0.5
            self.bottomBadgeContainerView.isHidden = false
            self.bottomBadgeContainerView.backgroundColor = Theme.color(kColorGray1)
            self.bottomBadgeLabel.text = STRING_OUT_OF_STOCK
            self.bottomBadgeLabel.textColor = .white
        }
        self.product = product
    }
    
    class func cellHeight(relateTo width: CGFloat) -> CGFloat {
        let contentWithoudImageHeight = 2 * imagePadding + labelSmallHeight + 3 * labelBigHeight + whiteSpaceHeigt + 8
        let imageSidePadding = 2 * imagePadding
        let imageRatio:CGFloat = 1.25
        return (width - imageSidePadding) * imageRatio + contentWithoudImageHeight
    }
    
}
