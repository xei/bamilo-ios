//
//  ProductReviewItemTableViewCell.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 7/4/18.
//  Copyright © 2018 Rocket Internet. All rights reserved.
//

import UIKit

class ProductReviewItemTableViewCell: BaseTableViewCell {

    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var reviewTitleLabel: UILabel!
    @IBOutlet private weak var reviewUserName: UILabel!
    @IBOutlet private weak var verticalSeperatorView: UIView!
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var reviewDescription: UILabel!
    @IBOutlet private weak var rateView: RateStarControl!
    @IBOutlet private weak var seeMoreButton: UIButton!
    
    var isExpanded: Bool = false
    let minimizedLineNumbers = 4
    
    override func awakeFromNib() {
        super.awakeFromNib()
        applyStyle()
        seeMoreButton.setTitle(STRING_MORE, for: .normal)
    }
    
    func applyStyle() {
        seeMoreButton.applyStyle(font: Theme.font(kFontVariationLight, size: 12), color: Theme.color(kColorBlue))
        reviewTitleLabel.applyStyle(font: Theme.font(kFontVariationBold, size: 12), color: Theme.color(kColorGray1))
        [reviewUserName, dateLabel].forEach { $0?.applyStyle(font: Theme.font(kFontVariationRegular, size: 10), color: Theme.color(kColorGray8)) }
        
        verticalSeperatorView.layer.cornerRadius = 4
        verticalSeperatorView.backgroundColor = Theme.color(kColorGray9)
        reviewDescription.numberOfLines = minimizedLineNumbers
        reviewDescription.applyStyle(font: Theme.font(kFontVariationRegular, size: 12), color: Theme.color(kColorGray1))
        containerView.backgroundColor = Theme.color(kColorGray10)
        
        if let backgroundColor = self.containerView.backgroundColor {
            let whiteClear = UIColor.white.withAlphaComponent(0)
            seeMoreButton.applyGradient(colours: [whiteClear, backgroundColor, backgroundColor, whiteClear], locations: [0, 0.3 , 0.7, 1],orientation: .horizontal)
        }
    }
    
    override func update(withModel model: Any!) {
        if let reviewItem = model as? ProductReviewItem {
            reviewTitleLabel.text = reviewItem.title
            reviewUserName.text = reviewItem.username
            dateLabel.text = reviewItem.date
            reviewDescription.text = reviewItem.comment
            if let rateScore = reviewItem.rateScore {
                rateView.colorButtons(rateValue: Double(rateScore), disabledColor: Theme.color(kColorGray9))
            }
            
            let beforeSizeFitFrame = reviewDescription.frame
            reviewDescription.sizeToFit()
            reviewDescription.frame = CGRect(origin: beforeSizeFitFrame.origin, size: CGSize(width: beforeSizeFitFrame.width, height: reviewDescription.frame.height))
            
            
            seeMoreButton.isHidden = isExpanded || reviewDescription.numberOfVisibleLines <= minimizedLineNumbers
            reviewDescription.numberOfLines = seeMoreButton.isHidden ? 0 : minimizedLineNumbers
            
            seeMoreButton.isUserInteractionEnabled = false
        }
    }
    
    func expand() {
        reviewDescription.numberOfLines = 0
        seeMoreButton.isHidden = true
        isExpanded = true
    }

    override class func nibName() -> String {
        return AppUtility.getStringFromClass(for: self)!
    }
}
