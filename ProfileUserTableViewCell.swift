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
            self.setDefaults()
            if let name = user.firstName {
                self.topMessageLabel.text = "\(STRING_HELLO) \(name)"
            } else {
                self.topMessageLabel.text = STRING_HELLO
            }
            if let gender = user.gender {
                self.logoImage.image = UIImage(named: gender == "female" ? "woman_user_profile" : "man_user_profile")
            }
            if let email = user.email {
                self.bottomMessageLabel.text = email
            }
            
        } else {
            self.setupLoggedOutView()
            self.setDefaults()
        }
    }
    
    private func setDefaults() {
        self.topMessageLabel.text = STRING_WELCOME
        self.bottomMessageLabel.text = STRING_LOGIN_OR_SIGNUP
        self.logoImage.image = #imageLiteral(resourceName: "man_user_profile")
    }
    
    override static func nibName() -> String {
        return AppUtility.getStringFromClass(for: self)!
    }
    
    override static func cellHeight() -> CGFloat {
        return 82
    }
}
