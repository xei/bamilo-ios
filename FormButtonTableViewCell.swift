//
//  FormButtonTableViewCell.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 10/7/18.
//  Copyright © 2018 Rocket Internet. All rights reserved.
//

import UIKit

class FormButtonTableViewCell: BaseTableViewCell {

    @IBOutlet weak private var buttonHightConstraint: NSLayoutConstraint!
    @IBOutlet weak private var button: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.button.layer.cornerRadius = buttonHightConstraint.constant / 2
        self.button.clipsToBounds = true
        self.button.applyBorder(width: 1, color: .gray)
        self.button.applyStyle(font: Theme.font(kFontVariationBold, size: 12), color: .gray)
    }
    
    
    override class func nibName() -> String {
        return AppUtility.getStringFromClass(for: self)!
    }
}
