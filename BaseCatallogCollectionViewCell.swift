//
//  BaseCatallogCollectionViewCell.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 5/16/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

import UIKit
import Kingfisher

@objc protocol BaseCatallogCollectionViewCellDelegate {
    @objc optional func addOrRemoveFromWishList(product: Product, cell: BaseCatallogCollectionViewCell, add: Bool)
}
 
class BaseCatallogCollectionViewCell: BaseCollectionViewCellSwift {
    
    @IBOutlet weak var productImage: UIImageView?
    @IBOutlet weak var titleLabel: UILabel?
    @IBOutlet weak var brandLabel: UILabel?
    @IBOutlet weak var discountedPriceLabel: UILabel?
    @IBOutlet weak var priceLabel: UILabel?
    @IBOutlet weak var dicountPrecentageLabel: UILabel?
    @IBOutlet weak var rateView: RateStarControl?
    @IBOutlet weak var rateCountLabel: UILabel?
    @IBOutlet weak var addToWishListButton: DOFavoriteButton?
    @IBOutlet weak var newTagView: UIView?
    var product: Product?
    
    weak var delegate: BaseCatallogCollectionViewCellDelegate?
    
    
    var cellIndex: Int = 0 {
        didSet {
            productImage?.backgroundColor = UIColor.placeholderColors[cellIndex % 6]
        }
    }
    
    override func setupView() {
        
        self.titleLabel?.applyStype(font: Theme.font(kFontVariationBold, size: 12), color: Theme.color(kColorGray1))
        self.brandLabel?.applyStype(font: Theme.font(kFontVariationRegular, size: 11), color: Theme.color(kColorGray5))
        self.discountedPriceLabel?.applyStype(font: Theme.font(kFontVariationBold, size: 13), color: Theme.color(kColorGray1))
        self.priceLabel?.applyStype(font: Theme.font(kFontVariationRegular, size: 11), color: Theme.color(kColorGray5))
        
        self.rateView?.enableButtons(enable: false)
        self.newTagView?.backgroundColor = Theme.color(kColorOrange)
        self.rateCountLabel?.textColor = Theme.color(kColorGray3)
        self.dicountPrecentageLabel?.textColor = Theme.color(kColorGray3)
        
        //apply shadow
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.2
        self.layer.shadowOffset = CGSize(width:0 , height: 1)
        self.layer.shadowRadius = 1
    }
    
    @IBAction func addToWishListButtonTapped(_ sender: DOFavoriteButton) {
        if sender.isSelected {
            sender.deselect()
        } else {
            sender.select()
        }
        if let avaiableProduct = self.product {
            avaiableProduct.isInWishList.toggle()
            self.delegate?.addOrRemoveFromWishList?(product: avaiableProduct, cell: self, add: avaiableProduct.isInWishList)
        }
    }
    
    func updateWithProduct(product: Product) {
        titleLabel?.text = product.name?.forceRTL()
        brandLabel?.text = product.brand?.forceRTL()
        productImage?.kf.indicatorType = .activity
        productImage?.kf.setImage(with: product.imageUrl, options: [.transition(.fade(0.20))])
        if let specialPrice = product.specialPrice, let price = product.price, product.price != product.specialPrice {
            discountedPriceLabel?.text = "\(specialPrice)".formatPriceWithCurrency()
            priceLabel?.attributedText = "\(price)".formatPriceWithCurrency().strucThroughPriceFormat()
            if let precentage = product.maxSavingPrecentage {
                dicountPrecentageLabel?.text = "%\(precentage)".convertTo(language: .arabic)
            } else {
                dicountPrecentageLabel?.text = ""
            }
        } else if let price = product.price {
            discountedPriceLabel?.text = "\(price)".formatPriceWithCurrency()
            priceLabel?.text = nil
            dicountPrecentageLabel?.text = nil
        }
        self.newTagView?.isHidden = !product.isNew
        if let rateCount = product.ratingsCount, let reviewAverage = product.reviewsAverage {
            self.rateCountLabel?.isHidden = false
            self.rateView?.isHidden = false
            self.rateCountLabel?.text = "(\(rateCount))".convertTo(language: .arabic)
            self.rateView?.update(withModel: reviewAverage)
        } else {
            self.rateCountLabel?.isHidden = true
            self.rateView?.isHidden = true
        }
        self.addToWishListButton?.isSelected = product.isInWishList
        self.product = product
    }
}
