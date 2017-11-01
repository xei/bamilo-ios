//
//  OrderOwnerInfoTableViewCell.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 10/23/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

import UIKit

class OrderOwnerInfoTableViewCell: BaseTableViewCell {

    @IBOutlet weak private var orderOwnerNameTitleLabel: UILabel!
    @IBOutlet weak private var orderOwnerAddressTitleLabel: UILabel!
    @IBOutlet weak private var orderOwnerPaymentValueTitleLabel: UILabel!
    @IBOutlet weak private var orderOwnerPaymentMethodTitleLabel: UILabel!
    
    @IBOutlet weak private var orderOwnerNameLabel: UILabel!
    @IBOutlet weak private var orderOwnerAddressLabel: UILabel!
    @IBOutlet weak private var orderOwnerPaymentValueLabel: UILabel!
    @IBOutlet weak private var orderOwnerPaymentMethodLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.orderOwnerNameTitleLabel.applyStype(font: Theme.font(kFontVariationRegular, size: 12),color: Theme.color(kColorGray2))
        self.orderOwnerNameLabel.applyStype(font: Theme.font(kFontVariationRegular, size: 12), color: Theme.color(kColorGray2))
        self.orderOwnerAddressTitleLabel.applyStype(font: Theme.font(kFontVariationRegular, size: 12),color: Theme.color(kColorGray2))
        self.orderOwnerAddressLabel.applyStype(font: Theme.font(kFontVariationRegular, size: 12), color: Theme.color(kColorGray2))
        self.orderOwnerPaymentValueTitleLabel.applyStype(font: Theme.font(kFontVariationRegular, size: 12),color: Theme.color(kColorGray2))
        self.orderOwnerPaymentValueLabel.applyStype(font: Theme.font(kFontVariationRegular, size: 12), color: Theme.color(kColorGray2))
        self.orderOwnerPaymentMethodTitleLabel.applyStype(font: Theme.font(kFontVariationRegular, size: 12),color: Theme.color(kColorGray2))
        self.orderOwnerPaymentMethodLabel.applyStype(font: Theme.font(kFontVariationRegular, size: 12), color: Theme.color(kColorGray2))
        
        self.orderOwnerNameTitleLabel.text = "\(STRING_RECIPIENT):"
        self.orderOwnerAddressTitleLabel.text = "\(STRING_SHIPPING_ADDRESS):"
        self.orderOwnerPaymentValueTitleLabel.text = "\(STRING_SHIPPING_COST):"
        self.orderOwnerPaymentMethodTitleLabel.text = "\(STRING_PAYMENT_OPTION):"
    }
    
    override func update(withModel model: Any!) {
        if let order = model as? OrderItem {
            if let name = order.customerFirstName, let lastName = order.customerLastName {
                self.orderOwnerNameLabel.text = "\(name) \(lastName)".forceRTL()
            }
            
            self.orderOwnerAddressLabel.text = "\(order.shippingAddress?.address ?? "")".convertTo(language: .arabic).forceRTL()
            if let deliveryCost = order.deliveryCost {
                self.orderOwnerPaymentValueLabel.text = deliveryCost > 0 ? "\(deliveryCost)".formatPriceWithCurrency().forceRTL() : STRING_FREE
            } else {
                self.orderOwnerPaymentValueLabel.text = STRING_FREE
            }
            self.orderOwnerPaymentMethodLabel.text = "\(order.paymentMethod ?? "")".forceRTL()
        }
    }
    
    override static func nibName() -> String {
        return AppUtility.getStringFromClass(for: self)!
    }
}
