//
//  WishListCollectionViewCell.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 11/18/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

import UIKit
import Kingfisher

protocol WishListCollectionViewCellDelegate: class {
    func share(product:Product, cell: WishListCollectionViewCell)
    func remove(product: Product, cell: WishListCollectionViewCell)
    func addToCart(product: Product, cell: WishListCollectionViewCell)
}

class WishListCollectionViewCell: BaseCatallogCollectionViewCell {
    
    @IBOutlet weak private var shareButton: IconButton!
    @IBOutlet weak private var addToCartButton: UIButton!
    private let horizontalAddToCartPadding:CGFloat = 15
    private let verticalAddToCartPadding:CGFloat = 5
    weak var wishListItemDelegate: WishListCollectionViewCellDelegate?
    
    override func setupView() {
        super.setupView()
        
        //TODO: for now this button must be removed because
        // we don't have the share url of product in whishlist
        self.shareButton.isHidden = true
        
        self.addToCartButton.applyStyle(font: Theme.font(kFontVariationRegular, size: 12), color: .white)
        self.addToCartButton.backgroundColor = Theme.color(kColorOrange1)
        self.addToCartButton.setTitle(STRING_BUY_NOW, for: .normal)
        self.addToCartButton.contentEdgeInsets = UIEdgeInsets(top: verticalAddToCartPadding, left: horizontalAddToCartPadding, bottom: verticalAddToCartPadding, right: horizontalAddToCartPadding)
        
        self.contentView.clipsToBounds = false
        self.clipsToBounds = false
    }
    
    @IBAction func shareButtonTapped(_ sender: Any) {
        if let product = self.product {
            self.wishListItemDelegate?.share(product: product, cell: self)
        }
    }
    
    @IBAction func removeButtonTapped(_ sender: Any) {
        if let product = self.product {
            self.wishListItemDelegate?.remove(product: product, cell: self)
        }
    }
    
    @IBAction func addToCartButtonTapped(_ sender: Any) {
        if let product = self.product {
            self.wishListItemDelegate?.addToCart(product: product, cell: self)
        }
    }
}
