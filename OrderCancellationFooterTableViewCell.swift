//
//  OrderCancellationFooterTableViewCell.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 1/21/18.
//  Copyright © 2018 Rocket Internet. All rights reserved.
//

import UIKit

class OrderCancellationFooterTableViewCell: BaseTableViewCell {
        
    @IBOutlet weak var orderCancellationCMSBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak private var orderCancelletaionCMSViewWrapperHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak private var orderCancellationCMSViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak private var moreDescriptionBottomToNoticeMessageTopConstraint: NSLayoutConstraint!
    @IBOutlet weak private var moreDescriptionTitleLabel: UILabel!
    @IBOutlet weak var moreDescriptionTextView: UITextView!
    @IBOutlet weak var orderCancellationCMSWrapperView: UIView!
    @IBOutlet weak private var orderCancellationCMSLabel: UILabel!
    @IBOutlet weak private var orderCancellationNoticeMessage: UILabel!
    
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
    
    func setCMSMessage(message: String) {
        self.orderCancelletaionCMSViewWrapperHeightConstraint.priority = message.count == 0 ? .defaultHigh : .defaultLow
        self.moreDescriptionBottomToNoticeMessageTopConstraint.priority = message.count == 0 ? .defaultHigh : .defaultLow
        self.orderCancellationCMSViewBottomConstraint.priority = message.count == 0 ? .defaultLow : .defaultHigh
        self.orderCancellationCMSBottomConstraint.priority = message.count == 0 ? .defaultLow : .defaultHigh
        self.orderCancellationCMSLabel.text = message
    }
    
    func setNoticeMessage(message: String) {
        self.orderCancellationNoticeMessage.text = message
    }
    
    override func update(withModel model: Any!) {
        
    }
    
    override class func nibName() -> String {
        return AppUtility.getStringFromClass(for: self)!
    }
    
}
