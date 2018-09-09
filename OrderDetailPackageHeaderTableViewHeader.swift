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
    @IBOutlet weak private var descriptionHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak private var deliveryTypeDescriptionLabel: UILabel!
    @IBOutlet weak private var deliveryTypeDescriptionHeightConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.deviationDescriptionLabel.text = nil
        self.deviationDescriptionLabel.applyStyle(font: Theme.font(kFontVariationRegular, size: 12), color: Theme.color(kColorPink3))
        deliveryTypeDescriptionLabel.applyStyle(font: Theme.font(kFontVariationRegular, size: 12), color: Theme.color(kColorGray8))
    }
    
    func update(deviationDescription: String?) {
        descriptionHeightConstraint.constant = deviationDescription == nil ? 0 : 35
        self.deviationDescriptionLabel.text = deviationDescription
    }
    
    func updateDeliveryDescription(desccription: String?) {
        deliveryTypeDescriptionHeightConstraint.constant = desccription == nil ? 0 : 35
        deliveryTypeDescriptionLabel.text = desccription
    }
    
    override class func nibName() -> String {
        return AppUtility.getStringFromClass(for: self)!
    }
}
