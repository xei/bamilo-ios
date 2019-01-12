//
//  FormLinkButtonTableViewCell.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 10/15/18.
//  Copyright © 2018 Rocket Internet. All rights reserved.
//

import UIKit

class FormLinkButtonTableViewCell: BaseTableViewCell {
    
    @IBOutlet weak private var linkButton: UIButton!
    var tagretMode: AuthenticationViewMode = .forgetPass
    weak var delegate: FormButtonTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        linkButton.applyStyle(font: Theme.font(kFontVariationMedium, size: 10), color: Theme.color(kColorBlue))
    }
    
    @IBAction func buttonTapped(_ sender: Any) {
        self.delegate?.buttonTapped(for: tagretMode)
    }
    
    func setTitle(title: String) {
        self.linkButton.setTitle(title, for: .normal)
    }
    
    override class func nibName() -> String {
        return AppUtility.getStringFromClass(for: self)!
    }
}
