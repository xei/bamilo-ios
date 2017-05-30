//
//  ProfileUserTableViewCell.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 5/29/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

import UIKit

class ProfileUserTableViewCell: BaseProfileTableViewCell {
    
    @IBOutlet private weak var logoImage: UIImageView!
    @IBOutlet private weak var topMessageLabel: UILabel!
    @IBOutlet private weak var bottomMessageLabel: UILabel!
    
    override func setupView() {
        super.setupView()
        self.setupLoggedOutView()
    }
    
    func setupLoggedOutView() {
        self.topMessageLabel.applyStype(font: Theme.font(kFontVariationRegular, size: 12), color: Theme.color(kColorLightGray))
        self.bottomMessageLabel.applyStype(font: Theme.font(kFontVariationRegular, size: 14), color: Theme.color(kColorExtraDarkGray))
    }
    
    func setupLoggedInView() {
        self.topMessageLabel.applyStype(font: Theme.font(kFontVariationRegular, size: 14), color: Theme.color(kColorExtraDarkGray))
        self.bottomMessageLabel.applyStype(font: Theme.font(kFontVariationRegular, size: 12), color: Theme.color(kColorExtraDarkGray))
    }

    override func update(withModel model: Any!) {
        if let user = model as? RICustomer {
            self.setupLoggedInView()
            self.topMessageLabel.text = user.firstName
            self.bottomMessageLabel.text = user.email
        } else {
            self.setupLoggedOutView()
            self.topMessageLabel.text = STRING_WELCOME
            self.bottomMessageLabel.text = STRING_LOGIN_OR_SIGNUP
        }
    }
    
    override static func nibName() -> String {
        return AppUtility.getStringFromClass(for: self)!
    }
    
    override static func cellHeight() -> CGFloat {
        return 82
    }
}
