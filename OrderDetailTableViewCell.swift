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
    func openRateViewWithProdcut(product: TrackableProductProtocol)
    func cancelProduct(product: OrderProductItem)
}

class OrderDetailTableViewCell: AccordionTableViewCell {

    @IBOutlet weak private var cancellationView: UIView!
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
    @IBOutlet weak private var cancellationButton: UIButton!
    @IBOutlet weak private var cancellationReasonLabel: UILabel!
    @IBOutlet weak private var refundDescriptionLabel: UILabel!
    @IBOutlet weak private var cancellationHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak private var refuadDescriptionLabelBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak private var cancellationReasonLabelBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak private var refundMessagesToTopSuperViewConstriant: NSLayoutConstraint!
    @IBOutlet weak private var refundStateIconImageView: UIImageView!
    
    @IBOutlet weak private var cancellationReasonBottomToBottomConstraint: NSLayoutConstraint!
    
    weak var delegate: OrderDetailTableViewCellDelegate?
    private var product: OrderProductItem?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.clipsToBounds = true
        self.detailView.clipsToBounds = true
        self.headerView.clipsToBounds = true
        
        self.productTitleLabel.applyStyle(font: Theme.font(kFontVariationRegular, size: 12), color: Theme.color(kColorGray1))
        self.productPriceLabel.applyStyle(font: Theme.font(kFontVariationRegular, size: 12), color: Theme.color(kColorGray1))
        self.productMoreInfoLabel.applyStyle(font: Theme.font(kFontVariationRegular, size: 12), color: Theme.color(kColorGray1))
        self.rateButton.applyStyle(font: Theme.font(kFontVariationRegular, size: 12), color: .white)
        self.rateButton.applyShadow(position: CGSize(width:0 , height: 1), color: .black, opacity: 0.2)
        self.cancellationButton.applyStyle(font: Theme.font(kFontVariationRegular, size: 12), color: Theme.color(kColorGray1))
        self.notInStockMessageLabel.applyStyle(font: Theme.font(kFontVariationRegular, size: 9), color: Theme.color(kColorGray4))
        
        self.cancellationReasonLabel.applyStyle(font: Theme.font(kFontVariationRegular, size: 11), color: Theme.color(kColorGray1))
        self.refundDescriptionLabel.applyStyle(font: Theme.font(kFontVariationRegular, size: 11), color: Theme.color(kColorGray1))
        self.cancellationView.backgroundColor = Theme.color(kColorOrange10)
        self.cancellationView.layer.cornerRadius = 3
        
        self.rateButton.backgroundColor = Theme.color(kColorDarkGreen)
        self.cancellationButton.backgroundColor = .white
        self.cancellationButton.applyShadow(position: CGSize(width:0 , height: 1), color: .black, opacity: 0.2)
        
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
            self.productImage.kf.setImage(with: product.imageUrl, placeholder: #imageLiteral(resourceName: "placeholder_gallery"), options: [.transition(.fade(0.20))])
            let productPrice = product.specialPrice ?? product.price ?? 0
            self.productPriceLabel.text = "\(Int(productPrice) * (product.quantity ?? 0))".formatPriceWithCurrency()
            
            var productInfo = "\(STRING_QUANTITY): \(product.quantity ?? 0)".convertTo(language: .arabic)
            if (product.brand ?? "").count > 0 {
                productInfo += "\n\(STRING_BRAND): \(product.brand ?? "")"
            }
            if (product.sellerName ?? "").count > 0 {
                productInfo += "\n\(STRING_SELLER): \(product.sellerName ?? "")"
            }
            if let size = product.size {
                productInfo += "\n\(STRING_SIZE): \(size)".convertTo(language: .arabic)
            }
            if let color = product.color {
                productInfo += "\n\(STRING_COLOR): \(color)".convertTo(language: .arabic)
            }
            
            self.cancellationButton.isHidden = !product.isCancelable
            if !product.isCancelable, let reasonType = product.notCancellableReasonType, reasonType != .isCancelled, let lastHistory = product.histories?.last, (lastHistory.status == .inactive || lastHistory.status == .active) {
                self.cancellationButton.isHidden = false
            }
        
            self.productMoreInfoLabel.text = productInfo
            self.progressBarView.update(withModel: product.histories)
            self.notInStockMessageLabel.text = product.sku != nil ? nil : STRING_ORDER_OUT_OF_STOCK
            self.rateButton.backgroundColor = product.sku != nil ? Theme.color(kColorDarkGreen) : Theme.color(kColorGray9)
            
            if let refund = product.refaund {
                if let reason = refund.cancellationReason {
                    self.refuadDescriptionLabelBottomConstraint.priority = .defaultHigh
                    self.cancellationReasonLabelBottomConstraint.priority = .defaultHigh
                    self.refundMessagesToTopSuperViewConstriant.priority = .defaultLow
                    self.cancellationReasonLabel.text = reason.convertTo(language: .arabic)
                } else {
                    self.refuadDescriptionLabelBottomConstraint.priority = .defaultLow
                    self.cancellationReasonLabelBottomConstraint.priority = .defaultHigh
                }
                if let status = refund.status {
                    if status == .success {
                        self.refundStateIconImageView.image = #imageLiteral(resourceName: "outlined_checked_rounded")
                    } else {
                        self.refundStateIconImageView.image = #imageLiteral(resourceName: "img_emptyrecentsearches")
                    }
                    self.refundDescriptionLabel.text = self.getRefundMessage(refund: refund)
                    self.cancellationReasonBottomToBottomConstraint.constant = 249
                    self.cancellationHeightConstraint.priority = .defaultLow
                    
                } else {
                    self.cancellationReasonBottomToBottomConstraint.priority = .defaultHigh
                    self.cancellationReasonLabelBottomConstraint.priority = .defaultLow
                    self.refundDescriptionLabel.text = "   "
                }
                
            } else {
                self.cancellationHeightConstraint.priority = .defaultHigh
                self.cancellationReasonBottomToBottomConstraint.priority = .defaultLow
            }
            
            self.product = product
        }
    }
    
    @IBAction func imageTapped(_ sender: Any) {
        if let sku = self.product?.sku {
            self.delegate?.opensProductDetailWithSku(sku: sku)
        }
    }
    
    private func getRefundMessage(refund: OrderProductItemRefund) -> String {
        var refundMsg = "مبلغ کالا به "
        refundMsg += "\(refund.cardNumber ?? "کارتی که با آن پرداخت نمودید")"
        refundMsg += " به صورت خودکار "
        if let date = refund.date, let status = refund.status, status == .success {
            refundMsg += "در تاریخ \(date)"
        }
        if let status = refund.status, status == .pending {
            refundMsg += "بازگشت داده خواهد شد"
        } else {
            refundMsg += " بازگشت داده شده است"
        }
        return refundMsg.convertTo(language: .arabic)
    }

    @IBAction func rateButtonTapped(_ sender: Any) {
        if let product = self.product {
            self.delegate?.openRateViewWithProdcut(product: product)
        }
    }
    
    @IBAction func cancellButtonTapped(_ sender: Any) {
        if let product = self.product {
            if product.isCancelable {
                self.delegate?.cancelProduct(product: product)
            } else if let notCancellationReasonType = product.notCancellableReasonType {
                //switch case
                switch notCancellationReasonType {
                case .isCancelled:
                    AlertManager.sharedInstance().simpleAlert("", text: STRING_NOT_CANCELLABLE_UNKNOWN_STATUS, confirm: STRING_GOT_IT)
                case .hasCancellationRequest:
                    AlertManager.sharedInstance().simpleAlert("", text: STRING_NOT_CANCELLABLE_HAS_CANCELLATION_REQUEST, confirm: STRING_GOT_IT)
                case .isShipped:
                    AlertManager.sharedInstance().simpleAlert("", text: STRING_NOT_CANCELLABLE_SHIPPED, confirm: STRING_GOT_IT)
                }
            } else {
                AlertManager.sharedInstance().simpleAlert("", text: STRING_NOT_CANCELLABLE_UNKNOWN_STATUS, confirm: STRING_GOT_IT)
            }
        }
    }
    
    private func setPropoerConstraints(expanded: Bool) {
        //to set the height of cell via
        self.headreViewBottomConstraint.priority = expanded ?  .defaultLow:.defaultHigh
        self.rateButtonBottomConstraint.priority = expanded ? .defaultHigh:.defaultLow
        self.layoutIfNeeded()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.productImage.image = nil
        self.productPriceLabel.text = .EMPTY
        self.productTitleLabel.text = .EMPTY
        self.productMoreInfoLabel.text = .EMPTY
        self.detailView.isHidden = true
        self.cancellationReasonLabel.text = nil
        self.refundDescriptionLabel.text = nil
    }
    
    override class func nibName() -> String {
        return AppUtility.getStringFromClass(for: self)!
    }
    
}
