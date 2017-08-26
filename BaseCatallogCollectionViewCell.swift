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
 
class BaseCatallogCollectionViewCell: UICollectionViewCell {
    
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
    
    weak var delegate: BaseCatallogCollectionViewCellDelegate?
    private var product: Product?
    
    
    var cellIndex: Int = 0 {
        didSet {
            productImage?.backgroundColor = self.placeholderColors[cellIndex % 6]
        }
    }
    private let placeholderColors:[UIColor] = [ //Sequence of these colors are important
        UIColor.init(red: 249/255, green: 239/255, blue: 234/255, alpha: 1),
        UIColor.init(red: 236/255, green: 236/255, blue: 236/255, alpha: 1),
        UIColor.init(red: 226/255, green: 232/255, blue: 239/255, alpha: 1),
        UIColor.init(red: 233/255, green: 247/255, blue: 247/255, alpha: 1),
        UIColor.init(red: 245/255, green: 241/255, blue: 247/255, alpha: 1),
        UIColor.init(red: 236/255, green: 235/255, blue: 222/255, alpha: 1)
    ]
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupView()
    }
    
    func setupView() {
        self.rateView?.enableButtons(enable: false)
        self.newTagView?.backgroundColor = Theme.color(kColorOrange)
        

        self.rateCountLabel?.textColor = Theme.color(kColorSecondaryGray1)
        self.brandLabel?.textColor = Theme.color(kColorSecondaryGray1)
        self.priceLabel?.textColor = Theme.color(kColorSecondaryGray1)
        self.dicountPrecentageLabel?.textColor = Theme.color(kColorSecondaryGray1)
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
        titleLabel?.text = product.name
        brandLabel?.text = product.brand
        productImage?.kf.indicatorType = .activity
        productImage?.kf.setImage(with: product.imageUrl, options: [.transition(.fade(0.20))])
        if let specialPrice = product.specialPrice, let price = product.price, let precentage = product.maxSavingPrecentage {
            discountedPriceLabel?.text = "\(specialPrice)".formatPriceWithCurrency()
            priceLabel?.attributedText = "\(price)".formatPriceWithCurrency().strucThroughPriceFormat()
            dicountPrecentageLabel?.text = "%\(precentage)".convertTo(language: .arabic)
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
    
    static var nibName: String {
        return AppUtility.getStringFromClass(for: self)!
    }
}
