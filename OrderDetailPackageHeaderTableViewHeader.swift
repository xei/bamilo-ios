//
//  OrderDetailPackageHeaderTableViewHeader.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 1/15/18.
//  Copyright © 2018 Rocket Internet. All rights reserved.
//

import UIKit

class OrderDetailPackageHeaderTableViewHeader: MutualTitleHeaderCell {

    @IBOutlet weak private var deviationDescriptionLabel: UILabel!
    @IBOutlet weak private var titleToBottomSuperViewConstraint: NSLayoutConstraint!
    
    @IBOutlet weak private var deviationDescBottomSuperViewConstraint: NSLayoutConstraint!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.deviationDescriptionLabel.applyStype(font: Theme.font(kFontVariationRegular, size: 12), color: Theme.color(kColorPink3))
    }
    
    func update(deviationDescription: String?) {
        deviationDescBottomSuperViewConstraint.priority = deviationDescription != nil ? UILayoutPriorityDefaultHigh : UILayoutPriorityDefaultLow
        titleToBottomSuperViewConstraint.priority = deviationDescription != nil ? UILayoutPriorityDefaultLow : UILayoutPriorityDefaultHigh
        self.deviationDescriptionLabel.text = deviationDescription
    }
    
    override static func nibName() -> String {
        return AppUtility.getStringFromClass(for: self)!
    }
}
