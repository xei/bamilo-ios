//
//  ProductVariationViewControl.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 6/18/18.
//  Copyright © 2018 Rocket Internet. All rights reserved.
//

import UIKit

class ProductVariationViewControl: BaseViewControl, ProductVariationViewDelegate {

    weak var delegate: ProductVariationViewDelegate?
    var productVariationView: ProductVariationView?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = .clear
        self.productVariationView = ProductVariationView.nibInstance()
        self.productVariationView?.delegate = self
        if let view = self.productVariationView {
            self.addAnchorMatchedSubView(view: view)
        }
    }
    
    override func update(withModel model: Any!) {
        if let product = model as? NewProduct {
            self.productVariationView?.update(product: product)
        }
    }
    
    //MARK: - ProductVariationTableViewCellDelegate
    func didSelectSizeProduct(product: NewProduct) {
        delegate?.didSelectSizeProduct(product: product)
    }
    
    func didSelectOtherVariety(product: NewProduct) {
        delegate?.didSelectOtherVariety(product: product)
    }
}
