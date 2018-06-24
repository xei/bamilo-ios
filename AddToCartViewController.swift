//
//  AddToCartViewController.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 6/18/18.
//  Copyright © 2018 Rocket Internet. All rights reserved.
//

import UIKit

protocol AddToCartViewControllerDelegate: class {
    func submitAddToCartSimple(product: SimpleProduct)
    func didSelectVariationSku(product: SimpleProduct, completionHandler: @escaping ((_ prodcut: Product)->Void))
    func didSelectSimpleSkuFromAddToCartView(product: SimpleProduct)
}

class AddToCartViewController: UIViewController {

    @IBOutlet private weak var submitButton: IconButton!
    @IBOutlet private weak var productVariationView: ProductVariationViewControl!
    @IBOutlet private weak var backgroundView: UIView!
    @IBOutlet private weak var productImageView: UIImageView!
    @IBOutlet private weak var productTitleLabel: UILabel!
    @IBOutlet private weak var productPriceLabel: UILabel!
    @IBOutlet private weak var discountPriceLabel: UILabel!
    @IBOutlet private weak var currencyLabel: UILabel!
    @IBOutlet private weak var titleColorLabel: UILabel!
    @IBOutlet private weak var colorLabel: UILabel!
    @IBOutlet private weak var titleSizeLabel: UILabel!
    @IBOutlet private weak var sizeLabel: UILabel!
    
    weak var delegate: AddToCartViewControllerDelegate?
    var product: Product?
    
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
    }
    
    private func update(product: Product) {
        
        productImageView.kf.setImage(with: product.imageList?.first?.normal, options: [.transition(.fade(0.20))])
        productTitleLabel.text = product.name
        
        if let specialPrice = product.specialPrice, let price = product.price, product.price != product.specialPrice {
            discountPriceLabel?.attributedText = "\(price)".formatPriceWithCurrency().strucThroughPriceFormat()
            productPriceLabel?.text = "\(specialPrice)".convertTo(language: .arabic).priceFormat()
        } else if let price = product.price {
            productPriceLabel?.text = "\(price)".convertTo(language: .arabic).priceFormat()
            discountPriceLabel?.text = nil
        }
        
        productVariationView.update(withModel: product)
        self.product = product
    }
    
    @IBAction func dissmissButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addToCartButtonTapped(_ sender: Any) {
        if let simples = self.product?.simples, simples.count > 0 {
            let selectedSimple = simples.filter { $0.isSelected }.first
            if let selected = selectedSimple {
                self.delegate?.submitAddToCartSimple(product: selected)
            }
        } else {
            //TODO: message user to selected some of simple products
        }
        self.dismiss(animated: true, completion: nil)
    }
}


extension AddToCartViewController: ProductVariationViewDelegate {
    
    func didSelectVariationSku(product: SimpleProduct) {
        self.delegate?.didSelectVariationSku(product: product, completionHandler: { (product) in
            self.update(product: product)
        })
    }
    
    func didSelectSimpleSku(product: SimpleProduct) {
        self.delegate?.didSelectSimpleSkuFromAddToCartView(product: product)
    }
    
}
