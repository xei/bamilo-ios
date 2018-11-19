//
//  AddToCartViewController.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 6/18/18.
//  Copyright © 2018 Rocket Internet. All rights reserved.
//

import UIKit

protocol AddToCartViewControllerDelegate: class {
    func submitAddToCartSimple(product: NewProduct, refrence: UIViewController)
    func didSelectOtherVariation(product: NewProduct, source: AddToCartViewController, completionHandler: @escaping ((_ prodcut: NewProduct)->Void))
    func didSelectSizeVariationFromAddToCartView(product: NewProduct)
}

class AddToCartViewController: UIViewController {

    @IBOutlet private weak var submitButton: IconButton!
    @IBOutlet private weak var productVariationView: ProductVariationViewControl!
    @IBOutlet private weak var backgroundView: UIView!
    @IBOutlet private weak var productImageView: UIImageView!
    @IBOutlet private weak var productTitleLabel: UILabel!
    @IBOutlet private weak var productPriceLabel: UILabel!
    @IBOutlet private weak var oldPriceLabel: UILabel!
    @IBOutlet private weak var currencyLabel: UILabel!
    @IBOutlet private weak var titleColorLabel: UILabel!
    @IBOutlet private weak var colorLabel: UILabel!
    @IBOutlet private weak var titleSizeLabel: UILabel!
    @IBOutlet private weak var sizeLabel: UILabel!
    @IBOutlet private weak var seperatorView: UIView!
    
    weak var delegate: AddToCartViewControllerDelegate?
    var product: NewProduct?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        applyStyle()
        productVariationView.delegate = self
        if let product = product {
            self.update(product: product)
        }
    }
    
    private func applyStyle() {
        backgroundView.backgroundColor = .white
        backgroundView.alpha = 0.95
        backgroundView.addBlurView()
        submitButton.applyStyle(font: Theme.font(kFontVariationRegular, size: 13), color: .white)
        submitButton.setTitle(STRING_ADD_TO_SHOPPING_CART, for: .normal)
        submitButton.backgroundColor = Theme.color(kColorOrange1)
        
        [currencyLabel, titleSizeLabel, titleColorLabel].forEach { $0?.applyStyle(font: Theme.font(kFontVariationLight, size: 12), color: Theme.color(kColorGray8)) }
        productTitleLabel.applyStyle(font: Theme.font(kFontVariationBold, size: 12), color: Theme.color(kColorGray1))
        
        submitButton.layer.cornerRadius = 46 / 2
        submitButton.clipsToBounds = true
    }
    
    private func update(product: NewProduct) {
        
        productImageView.kf.setImage(with: product.imageList?.first?.medium, options: [.transition(.fade(0.20))])
        productTitleLabel.text = product.name
        productPriceLabel.text = "\(product.price?.value ?? 0)".convertTo(language: .arabic).priceFormat()
        if let oldPrice = product.price?.oldPrice {
            oldPriceLabel.attributedText = "\(oldPrice)".formatPriceWithCurrency().strucThroughPriceFormat()
        } else {
            oldPriceLabel.text = nil
        }
        oldPriceLabel.isHidden = (product.price?.oldPrice ?? 0) == 0
        
        productVariationView.update(withModel: product)
        seperatorView.backgroundColor = Theme.color(kColorGray10)
        self.product = product
    }
    
    @IBAction func dissmissButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addToCartButtonTapped(_ sender: Any) {
        if let variations = self.product?.variations, variations.count > 0 {
            let selectedColorProduct = variations.filter { $0.type == .size }.first?.products?.filter { $0.isSelected }.first
            if let selected = selectedColorProduct {
                self.delegate?.submitAddToCartSimple(product: selected, refrence: self)
                self.dismiss(animated: true, completion: nil)
            } else {
                productVariationView.productVariationView?.sizeSelectionLabel.textColor = Theme.color(kColorOrange1)
                productVariationView.productVariationView?.sizeSelectionLabel.layer.add(bounceAnimation, forKey: nil)
            }
        } else {
            
        }
    }
    
    private lazy var bounceAnimation: CABasicAnimation = {
        let animation = CABasicAnimation(keyPath: "transform")
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        animation.duration = 0.125
        animation.repeatCount = 1
        animation.autoreverses = true
        animation.isRemovedOnCompletion = false
        animation.fromValue = NSValue.init(caTransform3D: CATransform3DMakeScale(1.0, 1.0, 1.0))
        animation.toValue = NSValue.init(caTransform3D: CATransform3DMakeScale(1.4, 1.4, 1.0))
        return animation
    }()
}


extension AddToCartViewController: ProductVariationViewDelegate {
    
    func didSelectSizeProduct(product: NewProduct) {
        self.delegate?.didSelectSizeVariationFromAddToCartView(product: product)
    }
    
    func didSelectOtherVariety(product: NewProduct) {
        self.delegate?.didSelectOtherVariation(product: product, source: self) { (productInfo) in
            self.update(product: productInfo)
        }
    }
    
}
