//
//  ProductVariationTableViewCell.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 6/3/18.
//  Copyright © 2018 Rocket Internet. All rights reserved.
//

import UIKit


protocol ProductVariationTableViewCellDelegate: class {
    func didSelectOtherVariety(product: NewProduct)
    func moreInfoButtonTapped(viewType: MoreInfoSelectedViewType)
}

class ProductVariationTableViewCell: BaseProductTableViewCell, ProductVariationViewDelegate {

    @IBOutlet private weak var productSpecificationButton: UIButton!
    @IBOutlet private weak var descriptionButton: UIButton!
    @IBOutlet private weak var productVariationViewControl: ProductVariationViewControl!
    
    private var product: NewProduct?
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
    
    @IBAction func moreDescriptionButtonTapped(_ sender: Any) {
        delegate?.moreInfoButtonTapped(viewType: .description)
    }
    
    @IBAction func moreSpecificationsButtonTapped(_ sender: Any) {
        delegate?.moreInfoButtonTapped(viewType: .specicifation)
    }
    
    override func update(withModel model: Any!) {
        if let product = model as? NewProduct {
            self.product = product
            self.productVariationViewControl.update(withModel: product)
        }
    }
    
    //MARK: - ProductVariationViewDelegate
    func didSelectSizeProduct(product: NewProduct) {
        
    }
    
    func didSelectOtherVariety(product: NewProduct) {
        self.delegate?.didSelectOtherVariety(product: product)
    }
}

