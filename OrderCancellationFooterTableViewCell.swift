//
//  OrderCancellationFooterTableViewCell.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 1/21/18.
//  Copyright © 2018 Rocket Internet. All rights reserved.
//

import UIKit

class OrderCancellationFooterTableViewCell: BaseTableViewCell {
        
    @IBOutlet weak private var moreDescriptionTitleLabel: UILabel!
    @IBOutlet weak var moreDescriptionTextView: UITextView!
    @IBOutlet weak var orderCancellationCMSWrapperView: UIView!
    @IBOutlet weak var orderCancellationCMSLabel: UILabel!
    @IBOutlet weak var orderCancellationNoticeMessage: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.moreDescriptionTitleLabel.applyStyle(font: Theme.font(kFontVariationRegular, size: 13), color: Theme.color(kColorGray1))
        self.moreDescriptionTextView.font = Theme.font(kFontVariationRegular, size: 13)
        self.moreDescriptionTextView.textColor = Theme.color(kColorGray1)
        self.moreDescriptionTextView.applyBorder(width: 1, color: Theme.color(kColorGray7))
        self.orderCancellationCMSWrapperView.backgroundColor = Theme.color(kColorGray10)
        self.orderCancellationCMSWrapperView.layer.cornerRadius = 3
        self.orderCancellationCMSLabel.applyStyle(font: Theme.font(kFontVariationRegular, size: 13), color: Theme.color(kColorGray1))
        self.orderCancellationNoticeMessage.applyStyle(font: Theme.font(kFontVariationRegular, size: 13), color: Theme.color(kColorGray1))
        self.moreDescriptionTitleLabel.text = STRING_DESCRIPTION

    }
    
    override func update(withModel model: Any!) {
        
    }
    
    override static func nibName() -> String {
        return AppUtility.getStringFromClass(for: self)!
    }
    
}
