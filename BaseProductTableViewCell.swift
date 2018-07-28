//
//  BaseProductTableViewCell.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 5/22/18.
//  Copyright © 2018 Rocket Internet. All rights reserved.
//

import UIKit

class BaseProductTableViewCell: BaseTableViewCell {

    @IBOutlet internal weak var containerBoxView: UIView?
    @IBOutlet internal weak var horizontalSpacingConstraint: NSLayoutConstraint?
    
    private let horizontalSpacing: CGFloat = 6
    private var shadowLayer: CAShapeLayer!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.backgroundColor = .clear
        self.backgroundColor = .clear
        self.horizontalSpacingConstraint?.constant = horizontalSpacing
        self.contentView.clipsToBounds = false
        self.clipsToBounds = false
        
        self.containerBoxView?.applyShadow(position: CGSize(width:0 , height: 1), color: .black, opacity: 0.2)
        self.containerBoxView?.layer.cornerRadius = 3
    }
    
    override class func cellHeight() -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override class func nibName() -> String {
        return AppUtility.getStringFromClass(for: self)!
    }
}
