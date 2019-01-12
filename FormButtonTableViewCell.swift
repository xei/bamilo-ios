//
//  FormButtonTableViewCell.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 10/7/18.
//  Copyright © 2018 Rocket Internet. All rights reserved.
//

import UIKit

protocol FormButtonTableViewCellDelegate: class {
    func buttonTapped(for target: AuthenticationViewMode)
}

class FormButtonTableViewCell: BaseTableViewCell {

    @IBOutlet weak private var buttonHightConstraint: NSLayoutConstraint!
    @IBOutlet weak private var button: UIButton!
    weak var delegate: FormButtonTableViewCellDelegate?
    var tagretMode: AuthenticationViewMode = .signUp
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.button.layer.cornerRadius = buttonHightConstraint.constant / 2
        self.button.clipsToBounds = true
        self.button.applyBorder(width: 1, color: .gray)
        self.button.applyStyle(font: Theme.font(kFontVariationRegular, size: 11), color: .gray)
    }
    
    func setTitle(title: String) {
        self.button.setTitle(title, for: .normal)
    }
    
    @IBAction func buttonTapped(_ sender: Any) {
        self.delegate?.buttonTapped(for: tagretMode)
    }
    
    
    override class func nibName() -> String {
        return AppUtility.getStringFromClass(for: self)!
    }
}
