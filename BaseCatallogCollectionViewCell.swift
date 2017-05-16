//
//  BaseCatallogCollectionViewCell.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 5/16/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

import UIKit

class BaseCatallogCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var productImage: UIImageView?
    @IBOutlet weak var titleLabel: UILabel?
    @IBOutlet weak var brandLabel: UILabel?
    @IBOutlet weak var discountedPriceLabel: UILabel?
    @IBOutlet weak var priceLabel: UILabel?
    @IBOutlet weak var dicountPrecentageLabel: UILabel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupView()
    }
    
    func setupView() {
        return
    }
    
    @IBAction func addToWishListButtonTapped(_ sender: Any) {
        
    }
    
    func updateWithProduct(product: Product) {
        titleLabel?.text = product.name
        brandLabel?.text = product.brand
        if let specialPrice = product.specialPrice, let price = product.price, let precentage = product.maxSavingPrecentage {
            discountedPriceLabel?.text = "\(specialPrice)".formatPriceWithCurrency()
            priceLabel?.attributedText = "\(price)".formatPriceWithCurrency().strucThroughPriceFormat()
            dicountPrecentageLabel?.text = precentage
        } else if let price = product.price {
            discountedPriceLabel?.text = "\(price)".formatPriceWithCurrency()
            priceLabel?.text = nil
            dicountPrecentageLabel?.text = nil
        }
    }
    
    static var nibName: String {
        return AppUtility.getStringFromClass(for: self)!
    }
}
