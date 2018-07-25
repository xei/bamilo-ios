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
    @IBOutlet weak private var titleLabelToImageRightConstraint: NSLayoutConstraint!
    @IBOutlet weak private var titleToSuperviewRightConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.applyStyle()
    }
    
    private func applyStyle() {
        self.backgroundColor = .white
        self.contentView.backgroundColor = .white
        self.titleLabel.applyStyle(font: Theme.font(kFontVariationRegular, size: 13), color: Theme.color(kColorGray1))
    }
    
    override func update(withModel model: Any!) {
        if let category = model as? CategoryProduct {
            self.updateView(imageUrl: category.image, title: category.name ?? "")
        } else if let externalLink = model as? ExternalLink {
            self.updateView(imageUrl: externalLink.imageURl, title: externalLink.label ?? "")
        } else if let internalLink = model as? InternalLink {
            self.updateView(imageUrl: internalLink.imageURl, title: internalLink.label ?? "")
        }
    }
    
    private func updateView(imageUrl: URL?, title: String) {
        self.titleLabel.text = title
        if let image = imageUrl {
            self.imageViewContainerView.isHidden = false
            self.titleToSuperviewRightConstraint.priority = .defaultLow
            self.titleLabelToImageRightConstraint.priority = .defaultHigh
            self.iconImageView.kf.setImage(with: image, options: [.transition(.fade(0.20))])
        } else {
            self.imageViewContainerView.isHidden = true
            self.titleToSuperviewRightConstraint.priority = .defaultHigh
            self.titleLabelToImageRightConstraint.priority = .defaultLow
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
            
        self.titleLabel.text = nil
        self.iconImageView.image = nil
    }
    
    override class func nibName() -> String {
        return AppUtility.getStringFromClass(for: self)!
    }
}
