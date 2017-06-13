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
        self.titleLabel.applyStype(font: Theme.font(kFontVariationRegular, size: 14), color: Theme.color(kColorExtraDarkGray))
        self.iconImage.image = UIImage(named: "order-tracking-profile")
    }
    
    override static func nibName() -> String {
        return AppUtility.getStringFromClass(for: self)!
    }
    
    override static func cellHeight() -> CGFloat {
        return 60
    }
    
}
