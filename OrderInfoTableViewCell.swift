//
//  OrderInfoTableViewCell.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 10/23/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

import UIKit

class OrderInfoTableViewCell: BaseTableViewCell {

    @IBOutlet weak private var orderIdTitleLabel: UILabel!
    @IBOutlet weak private var orderCostTitleLabel: UILabel!
    @IBOutlet weak private var orderCreationDateTitleLabel: UILabel!
    @IBOutlet weak private var orderProductCountTitleLabel: UILabel!
    
    @IBOutlet weak private var orderIdLabel: UILabel!
    @IBOutlet weak private var orderCostLabel: UILabel!
    @IBOutlet weak private var orderCreationDateLabel: UILabel!
    @IBOutlet weak private var orderProductCountLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.orderIdLabel.applyStype(font: Theme.font(kFontVariationRegular, size: 12),color: Theme.color(kColorGray2))
        self.orderIdTitleLabel.applyStype(font: Theme.font(kFontVariationRegular, size: 12), color: Theme.color(kColorGray2))
        self.orderCostLabel.applyStype(font: Theme.font(kFontVariationRegular, size: 12),color: Theme.color(kColorGray2))
        self.orderCostTitleLabel.applyStype(font: Theme.font(kFontVariationRegular, size: 12), color: Theme.color(kColorGray2))
        self.orderCreationDateLabel.applyStype(font: Theme.font(kFontVariationRegular, size: 12),color: Theme.color(kColorGray2))
        self.orderCreationDateTitleLabel.applyStype(font: Theme.font(kFontVariationRegular, size: 12), color: Theme.color(kColorGray2))
        self.orderProductCountLabel.applyStype(font: Theme.font(kFontVariationRegular, size: 12),color: Theme.color(kColorGray2))
        self.orderProductCountTitleLabel.applyStype(font: Theme.font(kFontVariationRegular, size: 12), color: Theme.color(kColorGray2))
        
        self.orderIdTitleLabel.text = "\(STRING_ORDER_ID):"
        self.orderCostTitleLabel.text = "\(STRING_ORDER_COST):"
        self.orderCreationDateTitleLabel.text = "\(STRING_CREATION_DATE):"
        self.orderProductCountTitleLabel.text = "\(STRING_ORDDER_PRODUCT_QUANTITY):"
    }
    
    override func update(withModel model: Any!) {
        if let model = model as? OrderItem {
            self.orderIdLabel.text = "\(model.id ?? "")".forceRTL()
            self.orderCreationDateLabel.text = "\(model.creationDate ?? "")".forceRTL()
            self.orderCostLabel.text = "\("\(model.price ?? 0)".formatPriceWithCurrency())".forceRTL()
            self.orderProductCountLabel.text = "\(model.productionCount)".convertTo(language: .arabic).forceRTL()
        }
    }
    
    override static func nibName() -> String {
        return AppUtility.getStringFromClass(for: self)!
    }
}
