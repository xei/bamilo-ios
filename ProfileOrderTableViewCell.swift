//
//  ProfileOrderTableViewCell.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 5/29/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

import UIKit

class ProfileOrderTableViewCell: BaseProfileTableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var iconImage: UIImageView!
    
    override func setupView() {
        super.setupView()
        self.titleLabel.applyStyle(font: Theme.font(kFontVariationRegular, size: 14), color: Theme.color(kColorExtraDarkGray))
        self.iconImage.image = #imageLiteral(resourceName: "order-tracking-profile")
    }
    
    override class func nibName() -> String {
        return AppUtility.getStringFromClass(for: self)!
    }
    
    override class func cellHeight() -> CGFloat {
        return 60
    }
    
}
