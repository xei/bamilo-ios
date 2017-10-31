//
//  OrderDetailTableViewCell.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 10/22/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

import UIKit
import Kingfisher

protocol OrderDetailTableViewCellDelegate: class {
    func opensProductDetailWithSku(sku: String)
    func openRateViewWithSku(sku: String)
}

class OrderDetailTableViewCell: AccordionTableViewCell {

    @IBOutlet weak private var progressBarView: ProgressBar!
    @IBOutlet weak private var productImage: UIImageView!
    @IBOutlet weak private var productTitleLabel: UILabel!
    @IBOutlet weak private var productPriceLabel: UILabel!
    @IBOutlet weak private var productMoreInfoLabel: UILabel!
    @IBOutlet weak private var rateButtonBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak private var headreViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak private var bottomArrowImage: UIImageView!
    @IBOutlet weak private var detailView: UIView!
    @IBOutlet weak private var headerView: UIView!
    @IBOutlet weak private var rateButton: UIButton!
    @IBOutlet weak private var notInStockMessageLabel: UILabel!
    
    weak var delegate: OrderDetailTableViewCellDelegate?
    private var product: OrderProductItem?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.clipsToBounds = true
        self.detailView.clipsToBounds = true
        self.headerView.clipsToBounds = true
        
        self.productTitleLabel.applyStype(font: Theme.font(kFontVariationRegular, size: 12), color: Theme.color(kColorGray1))
        self.productPriceLabel.applyStype(font: Theme.font(kFontVariationRegular, size: 12), color: Theme.color(kColorGray1))
        self.productMoreInfoLabel.applyStype(font: Theme.font(kFontVariationRegular, size: 12), color: Theme.color(kColorGray1))
        self.rateButton.applyStyle(font: Theme.font(kFontVariationRegular, size: 12), color: .white)
        self.notInStockMessageLabel.applyStype(font: Theme.font(kFontVariationRegular, size: 11), color: Theme.color(kColorGray4))
        
        self.rateButton.backgroundColor = Theme.color(kColorDarkGreen)
        self.setPropoerConstraints(expanded: expanded)
        self.productImage?.layer.borderColor = Theme.color(kColorGray9).cgColor
        self.productImage?.layer.borderWidth = 1
        self.productImage?.layer.cornerRadius = 2
    }

    override func setExpanded(_ expanded: Bool, animated: Bool) {
        super.setExpanded(expanded, animated: animated)
        self.setPropoerConstraints(expanded: expanded)
        
        if animated {
            UIView.transition(with: detailView, duration: 0.15, animations: {
                self.detailView.alpha = expanded ? 1 : 0
                self.bottomArrowImage.transform = expanded ? CGAffineTransform(rotationAngle: .pi) : CGAffineTransform(rotationAngle: 0)
            }, completion: { (finished) in
                self.detailView.isHidden = !expanded
            })
        } else {
            self.detailView.isHidden = !expanded
            self.detailView.alpha = expanded ? 1 : 0
            self.bottomArrowImage.transform = expanded ? CGAffineTransform(rotationAngle: .pi) : CGAffineTransform(rotationAngle: 0)
        }
        self.layoutSubviews()
    }
    
    override func update(withModel model: Any!) {
        if let product = model as? OrderProductItem {
            self.productTitleLabel.text = product.name
            self.productImage.kf.setImage(with: product.imageUrl, placeholder: UIImage(named: "placeholder_gallery"), options: [.transition(.fade(0.20))])
            let productPrice = product.specialPrice ?? product.price ?? 0
            self.productPriceLabel.text = "\(Int(productPrice) * (product.quantity ?? 0))".formatPriceWithCurrency()
            let formattedPrice = "\(productPrice)".formatPriceWithCurrency()
            var productInfo = "\(STRING_QUANTITY): \(product.quantity ?? 0)".convertTo(language: .arabic)
            productInfo += "\n\(STRING_BRAND): \(product.brand ?? "") \n\(STRING_SELLER): \(product.seller ?? "") \n\(STRING_PRICE): \(formattedPrice)"
            if let size = product.size { productInfo += "\n\(STRING_SIZE):\(size)".convertTo(language: .arabic)}
            self.productMoreInfoLabel.text = productInfo
            self.progressBarView.update(withModel: product.histories)
            self.notInStockMessageLabel.text = product.sku != nil ? nil : STRING_ORDER_OUT_OF_STOCK
            self.rateButton.backgroundColor = product.sku != nil ? Theme.color(kColorDarkGreen) : Theme.color(kColorGray9)
            self.product = product
        }
    }
    
    @IBAction func imageTapped(_ sender: Any) {
        if let sku = self.product?.sku {
            self.delegate?.opensProductDetailWithSku(sku: sku)
        }
    }

    @IBAction func rateButtonTapped(_ sender: Any) {
        if let sku = self.product?.sku {
            self.delegate?.openRateViewWithSku(sku: sku)
        }
    }
    
    private func setPropoerConstraints(expanded: Bool) {
        //to set the height of cell via
        self.headreViewBottomConstraint.priority = expanded ?  UILayoutPriorityDefaultLow:UILayoutPriorityDefaultHigh
        self.rateButtonBottomConstraint.priority = expanded ? UILayoutPriorityDefaultHigh:UILayoutPriorityDefaultLow
        self.layoutIfNeeded()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.productImage.image = nil
        self.productPriceLabel.text = .EMPTY
        self.productTitleLabel.text = .EMPTY
        self.productMoreInfoLabel.text = .EMPTY
        self.detailView.isHidden = true
    }
    
    override static func nibName() -> String {
        return AppUtility.getStringFromClass(for: self)!
    }
    
}
