//
//  CMSTableViewHeader.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 1/29/18.
//  Copyright © 2018 Rocket Internet. All rights reserved.
//

import UIKit

class CMSTableViewHeader: UITableViewHeaderFooterView {

    @IBOutlet weak private var horizontalLabelSpacingConstraint: NSLayoutConstraint!
    @IBOutlet weak var cmsContainerView: UIView!
    @IBOutlet weak var cmsMessageLabel: UILabel!
    @IBOutlet weak var horizontalSpacingConstraint: NSLayoutConstraint!
    @IBOutlet weak var verticalSpacingConstraint: NSLayoutConstraint!
   
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.cmsContainerView.backgroundColor = Theme.color(kColorOrange10)
        self.cmsMessageLabel.applyStyle(font: Theme.font(kFontVariationRegular, size: 11), color: Theme.color(kColorGray1))
        self.horizontalSpacingConstraint.constant = 20
        self.verticalSpacingConstraint.constant = 0
        self.cmsMessageLabel.numberOfLines = 0
        self.cmsMessageLabel.lineBreakMode = .byWordWrapping
        self.cmsMessageLabel.preferredMaxLayoutWidth = UIScreen.main.bounds.width -
            ((self.horizontalLabelSpacingConstraint.constant + self.horizontalSpacingConstraint.constant) * 2)
        self.cmsContainerView.layer.cornerRadius = 3
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.contentView.layoutIfNeeded()
    }
    
    func setMessage(message: String) {
        self.cmsMessageLabel.text = message
    }
    
    class func nibName() -> String {
        return AppUtility.getStringFromClass(for: self)!
    }
}
