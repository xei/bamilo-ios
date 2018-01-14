//
//  OrderCancellationFooterView.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 1/13/18.
//  Copyright © 2018 Rocket Internet. All rights reserved.
//

import UIKit

class OrderCancellationFooterView: UITableViewHeaderFooterView {

    @IBOutlet weak private var moreDescriptionTitleLabel: UILabel!
    @IBOutlet weak var moreDescriptionTextView: UITextView!
    @IBOutlet weak var orderCancellationCMSWrapperView: UIView!
    @IBOutlet weak var orderCancellationCMSLabel: UILabel!
    @IBOutlet weak var orderCancellationNoticeMessage: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.moreDescriptionTitleLabel.applyStype(font: Theme.font(kFontVariationRegular, size: 13), color: Theme.color(kColorGray1))
        self.moreDescriptionTextView.font = Theme.font(kFontVariationRegular, size: 13)
        self.moreDescriptionTextView.textColor = Theme.color(kColorGray1)
        self.moreDescriptionTextView.applyBorder(width: 1, color: Theme.color(kColorGray7))
        self.orderCancellationCMSWrapperView.backgroundColor = Theme.color(kColorGray10)
        self.orderCancellationCMSWrapperView.layer.cornerRadius = 3
        self.orderCancellationCMSLabel.applyStype(font: Theme.font(kFontVariationRegular, size: 13), color: Theme.color(kColorGray1))
        self.orderCancellationNoticeMessage.applyStype(font: Theme.font(kFontVariationRegular, size: 13), color: Theme.color(kColorGray1))
        self.moreDescriptionTitleLabel.text = STRING_DESCRIPTION

    }
    
    class func nibName() -> String {
        return AppUtility.getStringFromClass(for: self) ?? "OrderCancellationFooterView"
    }
}
