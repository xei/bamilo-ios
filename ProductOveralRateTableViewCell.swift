//
//  ProductOveralRateTableViewCell.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 7/3/18.
//  Copyright © 2018 Rocket Internet. All rights reserved.
//

import UIKit

class ProductOveralRateTableViewCell: BaseTableViewCell {

    @IBOutlet private weak var averageRateLabel: UILabel!
    @IBOutlet private weak var baseRateLabel: UILabel!
    @IBOutlet private weak var rateCountLabel: UILabel!
    
    @IBOutlet private weak var oneStarViewControl: RateStarControl!
    @IBOutlet private weak var twoStarViewControl: RateStarControl!
    @IBOutlet private weak var threeStarViewControl: RateStarControl!
    @IBOutlet private weak var fourStarViewControl: RateStarControl!
    @IBOutlet private weak var fiveStarViewControl: RateStarControl!
    
    @IBOutlet private weak var oneStarProgress: SimpleProgressBarControl!
    @IBOutlet private weak var twoStarProgress: SimpleProgressBarControl!
    @IBOutlet private weak var threeStarProgress: SimpleProgressBarControl!
    @IBOutlet private weak var fourStarProgress: SimpleProgressBarControl!
    @IBOutlet private weak var fiveStarProgress: SimpleProgressBarControl!
    
    @IBOutlet private weak var singleStarImageView: UIImageView!
    
    var starControlsIndex: [Int: [RateStarControl: SimpleProgressBarControl]]?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
        
        starControlsIndex = [
            0: [oneStarViewControl: oneStarProgress],
            1: [twoStarViewControl: twoStarProgress],
            2: [threeStarViewControl: threeStarProgress],
            3: [fourStarViewControl: fourStarProgress],
            4: [fiveStarViewControl: fiveStarProgress]
        ]
        //rotate the star views
        [oneStarViewControl,
         oneStarProgress,
         twoStarViewControl,
         twoStarProgress,
         threeStarViewControl,
         threeStarProgress,
         fourStarViewControl,
         fourStarProgress,
         fiveStarViewControl,
         fiveStarProgress].forEach {
            ($0 as? UIView)?.transform = CGAffineTransform(scaleX: -1, y: 1)
        }
        
        averageRateLabel.applyStyle(font: Theme.font(kFontVariationRegular, size: 48), color: Theme.color(kColorGray1))
        baseRateLabel.applyStyle(font: Theme.font(kFontVariationRegular, size: 14), color: Theme.color(kColorGray8))
        rateCountLabel.applyStyle(font: Theme.font(kFontVariationRegular, size: 14), color: Theme.color(kColorGray1))
        
        singleStarImageView.image = #imageLiteral(resourceName: "ProductRateFullStar").withRenderingMode(.alwaysTemplate)
        singleStarImageView.tintColor = Theme.color(kColorOrange)
        
    }

    override func update(withModel model: Any!) {
        guard let rate = model as? ProductRate else { return }
        
        averageRateLabel.text = Utility.formatScoreValue(score: rate.average ?? 0)
        baseRateLabel.text = "\(STRING_FROM) \(Utility.formatScoreValue(score: rate.maxValue ?? 0))"
        rateCountLabel.text = "\(rate.totalCount ?? 0) \(STRING_COMMENT)".convertTo(language: .arabic)
        
        guard let starStatistics = rate.starsStatistics else { return }
        
        for i in 0..<starStatistics.count {
            let viewObj = starControlsIndex?[i]
            if let starNumber = starStatistics[i].starNumber {
                viewObj?.keys.first?.colorButtons(
                    rateValue: Double(starNumber),
                    color: Theme.color(kColorGray8),
                    disabledColor: .clear
                )
            }
            if let rateCount = starStatistics[i].count, let totalCount = rate.totalCount {
                let progressView = viewObj?.values.first
                progressView?.setTintColor(color: Theme.color(kColorExtraDarkBlue))
                progressView?.update(withModel: Double(rateCount) / Double(totalCount))
                progressView?.backgroundColor = Theme.color(kColorGray10)
            }
        }
    }
    
    override class func cellHeight() -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override class func nibName() -> String {
        return AppUtility.getStringFromClass(for: self)!
    }
    
}
