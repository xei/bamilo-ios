//
//  BaseProductTableViewCell.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 5/22/18.
//  Copyright © 2018 Rocket Internet. All rights reserved.
//

import UIKit

class BaseProductTableViewCell: BaseTableViewCell {

    @IBOutlet internal weak var containerBoxView: UIView!
    @IBOutlet internal weak var horizontalSpacingConstraint: NSLayoutConstraint!
    
    private let horizontalSpacing: CGFloat = 6
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.horizontalSpacingConstraint.constant = horizontalSpacing
        self.contentView.clipsToBounds = false
        self.clipsToBounds = false
        self.containerBoxView.roundCorners(.allCorners, radius: 3)
        self.containerBoxView.applyShadow(position: CGSize(width:0 , height: 1), color: .black, opacity: 0.2)
    }
    
    override class func cellHeight() -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override class func nibName() -> String {
        return AppUtility.getStringFromClass(for: self)!
    }
}
