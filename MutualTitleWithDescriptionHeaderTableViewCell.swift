//
//  MutualTitleWithDescriptionHeaderTableViewCell.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 8/4/18.
//  Copyright © 2018 Rocket Internet. All rights reserved.
//

import UIKit

@objcMembers class MutualTitleWithDescriptionHeaderTableViewCell: MutualTitleHeaderCell {
    
    @IBOutlet weak private var descriptionLabel: UILabel!
    @IBOutlet weak private var titleToBottomSuperViewConstraint: NSLayoutConstraint!
    @IBOutlet weak private var descriptionBottomSuperViewConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.descriptionLabel.applyStyle(font: Theme.font(kFontVariationRegular, size: 12), color: Theme.color(kColorGray8))
    }
    
    func update(description: String?) {
        descriptionBottomSuperViewConstraint.priority = description != nil ? .defaultHigh : .defaultLow
        titleToBottomSuperViewConstraint.priority = description != nil ? .defaultLow : .defaultHigh
        self.descriptionLabel.text = description
    }
    
    override class func nibName() -> String {
        return AppUtility.getStringFromClass(for: self)!
    }
}
