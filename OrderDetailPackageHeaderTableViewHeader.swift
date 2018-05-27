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
        self.deviationDescriptionLabel.applyStyle(font: Theme.font(kFontVariationRegular, size: 12), color: Theme.color(kColorPink3))
    }
    
    func update(deviationDescription: String?) {
        deviationDescBottomSuperViewConstraint.priority = deviationDescription != nil ? .defaultHigh : .defaultLow
        titleToBottomSuperViewConstraint.priority = deviationDescription != nil ? .defaultLow : .defaultHigh
        self.deviationDescriptionLabel.text = deviationDescription
    }
    
    override class func nibName() -> String {
        return AppUtility.getStringFromClass(for: self)!
    }
}
