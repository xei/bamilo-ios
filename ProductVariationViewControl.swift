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
        if let product = model as? Product {
            self.productVariationView?.update(product: product)
        }
    }
    
    //MARK: - ProductVariationTableViewCellDelegate
    func didSelectVariationSku(product: SimpleProduct) {
        self.delegate?.didSelectVariationSku(product: product)
    }
    
    func didSelectSimpleSku(product: SimpleProduct) {
        self.delegate?.didSelectSimpleSku(product: product)
    }
}
