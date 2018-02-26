//
//  OrderCancellationResultHeaderTableViewCell.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 1/14/18.
//  Copyright © 2018 Rocket Internet. All rights reserved.
//

import UIKit

class OrderCancellationResultHeaderTableViewCell: BaseTableViewCell {

    @IBOutlet weak var successMessage: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.successMessage.applyStyle(font: Theme.font(kFontVariationRegular, size: 13), color: Theme.color(kColorGray1))
        self.successMessage.text = ORDER_CANCELLATION_SUCCESS_MESSAGES
    }
    
    override static func nibName() -> String {
        return AppUtility.getStringFromClass(for: self)!
    }
    
}
