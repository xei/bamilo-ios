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

    @IBOutlet weak var descriptionArrowImageView: UIImageView!
    @IBOutlet weak var specifiationArrowImageView: UIImageView!
    @IBOutlet var buttonViewWrapper: [UIView]!
    @IBOutlet private weak var producSpecificationLabel: UILabel!
    @IBOutlet private weak var productDescriptionLabel: UILabel!
    @IBOutlet private weak var productSpecificationButton: UIButton!
    @IBOutlet private weak var descriptionButton: UIButton!
    @IBOutlet private weak var productVariationViewControl: ProductVariationViewControl!
    @IBOutlet private weak var buttonsToVariationViewVerticalConstrint: NSLayoutConstraint!
    
    private var product: NewProduct?
    weak var delegate: ProductVariationTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        applyStyle()
        productDescriptionLabel.text = STRING_PRODUCT_DESCRIPTION
        producSpecificationLabel.text = STRING_PRODUCT_SPECIFICATION
        self.productVariationViewControl.delegate = self
        
        
    }
    
    func applyStyle() {
        buttonViewWrapper.forEach { view in
            view.applyShadow(position: CGSize(width:0 , height: 1), color: .black, opacity: 0.2)
            view.layer.cornerRadius = 3
        }
        [productDescriptionLabel,  producSpecificationLabel].forEach {
            $0.applyStyle(font: Theme.font(kFontVariationRegular, size: 13), color: Theme.color(kColorGray1)) 
        }
        
        [descriptionArrowImageView, specifiationArrowImageView].forEach {
            $0?.image = #imageLiteral(resourceName: "ArrowLeft").withRenderingMode(.alwaysTemplate)
            $0?.tintColor = Theme.color(kColorGray5)
        }
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
            
            
            if let sizeProducts = product.sizeVariaionProducts, sizeProducts.count > 0 {
                buttonsToVariationViewVerticalConstrint.constant = 8
            } else if let otherVariationProducts = product.OtherVariaionProducts, otherVariationProducts.count > 1 {
                buttonsToVariationViewVerticalConstrint.constant = 8
            } else {
                buttonsToVariationViewVerticalConstrint.constant = 0
            }
        }
    }
    
    //MARK: - ProductVariationViewDelegate
    func didSelectSizeProduct(product: NewProduct) {
        
    }
    
    func didSelectOtherVariety(product: NewProduct) {
        self.delegate?.didSelectOtherVariety(product: product)
    }
}

