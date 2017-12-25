//
//  CategoryTableViewCell.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 12/23/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

import UIKit

class CategoryTableViewCell: BaseTableViewCell {

    @IBOutlet weak private var imageViewContainerView: UIView!
    @IBOutlet weak private var iconImageView: UIImageView!
    @IBOutlet weak private var imageViewContainerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak private var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.applyStyle()
    }
    
    private func applyStyle() {
        self.backgroundColor = .white
        self.contentView.backgroundColor = .white
        self.iconImageView.layer.cornerRadius = self.imageViewContainerHeightConstraint.constant / 2
        self.iconImageView.clipsToBounds = true
        self.imageViewContainerView.layer.cornerRadius = self.imageViewContainerHeightConstraint.constant / 2
        self.imageViewContainerView.layer.shadowColor = UIColor.black.cgColor
        self.imageViewContainerView.layer.shadowOffset = CGSize(width:1 , height: 2)
        self.imageViewContainerView.layer.shadowRadius = 1
        self.imageViewContainerView.layer.shadowOpacity = 0.2
        self.imageViewContainerView.clipsToBounds = false
        
        self.titleLabel.applyStype(font: Theme.font(kFontVariationRegular, size: 13), color: Theme.color(kColorGray1))
    }
    
    override func update(withModel model: Any!) {
        if let category = model as? CategoryProduct {
            self.titleLabel.text = category.name
            self.iconImageView.kf.setImage(with: category.image, options: [.transition(.fade(0.20))])
        }
    }
    
    override static func nibName() -> String {
        return AppUtility.getStringFromClass(for: self)!
    }
}
