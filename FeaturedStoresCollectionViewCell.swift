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
    
    var indexPath: IndexPath? {
        didSet {
            if indexPath?.row != 0 {
                self.layer.shadowOffset = CGSize(width:0 , height: 1)
            } else {
                self.layer.shadowOffset = CGSize(width:1 , height: 1)
                self.roundCorners([.topRight, .bottomRight], radius: 5)
                self.layoutSubviews()
            }
        }
    }
    
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
        
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.1
        self.layer.shadowRadius = 0
        
        self.imageWidthConstraint.constant = UIDevice.current.userInterfaceIdiom == .pad ? imageWithBigSize : imageWithSmallSize
        self.imageIcon.layer.cornerRadius = self.imageWidthConstraint.constant / 2
    }
    
    func update(withModel model: HomePageFeaturedStoreItem) {
        self.title = model.title
        self.imageIcon.kf.setImage(with: model.imageUrl, placeholder: UIImage(named: "homepage_slider_placeholder"),options: [.transition(.fade(0.20))])
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
