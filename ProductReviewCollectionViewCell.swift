//
//  ProductReviewCollectionViewCell.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 7/1/18.
//  Copyright © 2018 Rocket Internet. All rights reserved.
//

import UIKit

class ProductReviewCollectionViewCell: BaseCollectionViewCellSwift {
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var rateViewControl: RateStarControl!
    @IBOutlet private weak var seeMoreButton: UIButton!
    private var model: ProductReviewItem?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        applyStyle()
        seeMoreButton.setTitle(STRING_MORE, for: .normal)
    }
    
    override func update(withModel model: Any) {
        if let reviewItem = model as? ProductReviewItem {
            titleLabel.text = reviewItem.username
            dateLabel.text = reviewItem.date
            rateViewControl.update(withModel: reviewItem.rateScore)
            descriptionLabel.text = reviewItem.comment
            descriptionLabel.numberOfLines = 3
            
            let beforeSizeFitFrame = descriptionLabel.frame
            descriptionLabel.sizeToFit()
            descriptionLabel.frame = CGRect(origin: beforeSizeFitFrame.origin, size: CGSize(width: beforeSizeFitFrame.width, height: descriptionLabel.frame.height))
            
            descriptionLabel.textAlignment = .right
            seeMoreButton.isHidden = descriptionLabel.numberOfVisibleLines <= 3
            seeMoreButton.isUserInteractionEnabled = false
            
            self.model = reviewItem
        }
    }

    func applyStyle() {
        titleLabel.applyStyle(font: Theme.font(kFontVariationBold, size: 14), color: Theme.color(kColorGray1))
        dateLabel.applyStyle(font: Theme.font(kFontVariationRegular, size: 10), color: Theme.color(kColorGray8))
        descriptionLabel.applyStyle(font: Theme.font(kFontVariationRegular, size: 12), color: Theme.color(kColorGray1))
        seeMoreButton.applyStyle(font: Theme.font(kFontVariationLight, size: 12), color: Theme.color(kColorBlue))
        
        if let backgroundColor = self.backgroundColor {
            let whiteClear = UIColor.white.withAlphaComponent(0)
            seeMoreButton.applyGradient(colours: [whiteClear, backgroundColor, backgroundColor, whiteClear], locations: [0, 0.3 , 0.7, 1],orientation: .horizontal)
        }
    }
}
