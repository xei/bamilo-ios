//
//  FeaturedStoresCollectionViewCell.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 9/23/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

import UIKit
import Kingfisher

class FeaturedStoresCollectionViewCell: BaseCollectionViewCellSwift {

    @IBOutlet private weak var imageWidthConstraint: NSLayoutConstraint!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var imageIcon: UIImageView!
    
    private let imageWithSmallSize: CGFloat = 54
    private let imageWithBigSize: CGFloat = 54 * 1.15
    
    var title: String? {
        didSet {
            self.titleLabel.setTitle(title: title ?? "", lineHeight: 16 ,lineSpaceing: 0, alignment: .center)
        }
    }
    
    var image: UIImage? {
        didSet {
            self.imageIcon.image = image
        }
    }
    
    override func setupView() {
        self.titleLabel.applyStype(font: Theme.font(kFontVariationRegular, size: 10), color: UIColor.black)
        self.backgroundColor = .white
        
        self.imageWidthConstraint.constant = UIDevice.current.userInterfaceIdiom == .pad ? imageWithBigSize : imageWithSmallSize
        self.imageIcon.layer.cornerRadius = self.imageWidthConstraint.constant / 2
    }
    
    override func update(withModel model: Any) {
        if let featureStoreItem = model as? HomePageFeaturedStoreItem {
            self.title = featureStoreItem.title
            self.imageIcon.kf.setImage(with: featureStoreItem.imageUrl, placeholder: #imageLiteral(resourceName: "homepage_slider_placeholder"),options: [.transition(.fade(0.20))])
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.roundCorners([.allCorners], radius: 0)
        self.layer.shadowOffset = .zero
        self.titleLabel.text = nil
        self.titleLabel.attributedText = nil
        self.imageIcon.image = nil
    }
}
