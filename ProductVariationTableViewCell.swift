//
//  ProductVariationTableViewCell.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 6/3/18.
//  Copyright © 2018 Rocket Internet. All rights reserved.
//

import UIKit


protocol ProductVariationTableViewCellDelegate: class {
    func didSelectVariationSku(product: SimpleProduct, cell: ProductVariationTableViewCell)
}

class ProductVariationTableViewCell: BaseProductTableViewCell, ProductVariationViewDelegate {

    @IBOutlet private weak var productSpecificationButton: UIButton!
    @IBOutlet private weak var descriptionButton: UIButton!
    @IBOutlet private weak var productVariationViewControl: ProductVariationViewControl!
    
    private var product: Product?
    weak var delegate: ProductVariationTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        applyStyle()
        descriptionButton.setTitle(STRING_PRODUCT_DESCRIPTION, for: .normal)
        productSpecificationButton.setTitle(STRING_PRODUCT_SPECIFICATION, for: .normal)
        self.productVariationViewControl.delegate = self
    }
    
    func applyStyle() {
        [descriptionButton,  productSpecificationButton].forEach { $0.applyStyle(font: Theme.font(kFontVariationRegular, size: 13), color: Theme.color(kColorBlue)) }
    }
    
    override func update(withModel model: Any!) {
        if let product = model as? Product {
            self.product = product
            self.productVariationViewControl.update(withModel: product)
        }
    }
    
    //MARK: - ProductVariationViewDelegate
    func didSelectSimpleSku(product: SimpleProduct) {
        
    }
    
    func didSelectVariationSku(product: SimpleProduct) {
        self.delegate?.didSelectVariationSku(product: product, cell: self)
    }
}

