//
//  SellerView.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 4/26/18.
//  Copyright © 2018 Rocket Internet. All rights reserved.
//

import UIKit

class SellerView: BaseControlView {

    @IBOutlet weak var sellerNameLabel: UILabel!
    @IBOutlet weak var sellerOrderCounts: UILabel!
    @IBOutlet weak var guaranteeLabel: UILabel!
    @IBOutlet weak var precenseDurationLabel: UILabel!
    @IBOutlet weak var totalScoreValueLabel: UILabel!
    @IBOutlet weak var totalScoreBaseValueLabel: UILabel!
    @IBOutlet weak var fullfilmentTitleLabel: UILabel!
    @IBOutlet weak var fullfilmentValueLabel: UILabel!
    @IBOutlet weak var notReturnedTitleLabel: UILabel!
    @IBOutlet weak var notReturnedValueLabel: UILabel!
    @IBOutlet weak var slaReachedTitleLabel: UILabel!
    @IBOutlet weak var slaReachedValueLabel: UILabel!
    @IBOutlet weak var fullfillmentProgressView: SimpleProgressBarControl!
    @IBOutlet weak var notReturnedProgressView: SimpleProgressBarControl!
    @IBOutlet weak var slaReachedProgressView: SimpleProgressBarControl!
    
    @IBOutlet weak var sellerRatingWrapperView: UIView!
    
    @IBOutlet weak var deliveryTimeView: DeliveryTimeControl!
    @IBOutlet weak var precenseDurationToSeperatorVerticalSpacingConstraint: NSLayoutConstraint!
    @IBOutlet weak var guaranteeLabelToSeperatorVerticalSpacingConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var sellerRatingViewToDeliveryTimeVerticalSpacingConstraint: NSLayoutConstraint!
    @IBOutlet weak var seperatorToDeliveryTimeViewVerticalSpacingConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.sellerNameLabel.textColor = Theme.color(kColorGray1)
        self.sellerOrderCounts.textColor = Theme.color(kColorGray1)
        self.guaranteeLabel.textColor = Theme.color(kColorGray1)
        self.precenseDurationLabel.textColor = Theme.color(kColorGray1)
        self.totalScoreValueLabel.textColor = Theme.color(kColorGreen1)
        self.totalScoreBaseValueLabel.textColor = Theme.color(kColorGray1)
        self.fullfilmentTitleLabel.textColor = Theme.color(kColorGray1)
        self.fullfilmentValueLabel.textColor = Theme.color(kColorGray1)
        self.notReturnedTitleLabel.textColor = Theme.color(kColorGray1)
        self.notReturnedValueLabel.textColor = Theme.color(kColorGray1)
        self.slaReachedTitleLabel.textColor = Theme.color(kColorGray1)
        self.slaReachedValueLabel.textColor = Theme.color(kColorGray1)
    }
    
    func update(with seller: Seller) {
        self.sellerNameLabel.text = "\(STRING_SELLER): \(seller.name ?? "")"
        
        if let orderDeliveryCount = seller.orderDeliveryCount {
            self.sellerOrderCounts.text = "\(orderDeliveryCount.label ?? STRING_ORDERS_COUNT): \(orderDeliveryCount.value ?? "")".convertTo(language: .arabic)
            self.sellerOrderCounts.textColor = orderDeliveryCount.color ?? Theme.color(kColorGray1)
        } else {
            self.sellerOrderCounts.text = ""
        }
        
        if let precenceDuration = seller.precenceDuration {
            self.precenseDurationLabel.text = "\(precenceDuration.label ?? STRING_PRECENSE_DURATION): \(precenceDuration.value ?? "")".convertTo(language: .arabic)
            self.precenseDurationLabel.textColor = precenceDuration.color ?? Theme.color(kColorGray1)
        }
        
        if let guarantee = seller.warranty {
            self.guaranteeLabel.text = "\(STRING_GUARANTEE): \(guarantee)".trimmingCharacters(in: .whitespacesAndNewlines)
            self.guaranteeLabelToSeperatorVerticalSpacingConstraint.priority = MASLayoutPriorityDefaultHigh
            self.precenseDurationToSeperatorVerticalSpacingConstraint.priority = MASLayoutPriorityDefaultLow
        } else {
            self.guaranteeLabel.text = nil
            self.guaranteeLabelToSeperatorVerticalSpacingConstraint.priority = MASLayoutPriorityDefaultLow
            self.precenseDurationToSeperatorVerticalSpacingConstraint.priority = MASLayoutPriorityDefaultHigh
        }
        
        if let score = seller.score {
            if let totalScore = score.overall {
                self.totalScoreValueLabel.textColor = totalScore.color ?? Theme.color(kColorGreen1)
                if let value = totalScore.value, let maxValue = score.maxValue {
                    self.totalScoreValueLabel.text = "\(value)".convertTo(language: .arabic)
                    self.totalScoreBaseValueLabel.text = "\(STRING_FROM) \(maxValue) \(STRING_RATE)".convertTo(language: .arabic)
                } else {
                    self.totalScoreValueLabel.text = nil
                    self.totalScoreBaseValueLabel.text = nil
                }
            }
            self.fullfilmentTitleLabel.textColor = score.fullfilment?.color ?? Theme.color(kColorGray1)
            self.fullfilmentTitleLabel.text = score.fullfilment?.label ?? STRING_SUCCESSFUL_PRODUCT_SUMPPLEMENT
            
            self.fullfilmentValueLabel.textColor = score.fullfilment?.color ?? Theme.color(kColorGray1)
            self.fullfilmentValueLabel.text = "\(score.fullfilment?.value ?? 0)".convertTo(language: .arabic)
            if let value = score.fullfilment?.value, let maxValue = score.maxValue {
                self.fullfillmentProgressView.update(withModel: CGFloat(value/maxValue))
            }
            
            self.notReturnedTitleLabel.textColor = score.notReturned?.color ?? Theme.color(kColorGray1)
            self.notReturnedTitleLabel.text = score.notReturned?.label ?? STRING_NO_RETURN_TITLE
            
            self.notReturnedValueLabel.textColor = score.notReturned?.color ?? Theme.color(kColorGray1)
            self.notReturnedValueLabel.text = "\(score.notReturned?.value ?? 0)".convertTo(language: .arabic)
            if let value = score.notReturned?.value, let maxValue = score.maxValue {
                self.notReturnedProgressView.update(withModel: CGFloat(value/maxValue))
            }
            
            self.slaReachedTitleLabel.textColor = score.slaReached?.color ?? Theme.color(kColorGray1)
            self.slaReachedTitleLabel.text = score.slaReached?.label ?? STRING_SLA_TITLE
            
            self.slaReachedValueLabel.textColor = score.slaReached?.color ?? Theme.color(kColorGray1)
            self.slaReachedValueLabel.text = "\(score.slaReached?.value ?? 0)".convertTo(language: .arabic)
            if let value = score.slaReached?.value, let maxValue = score.maxValue {
                self.slaReachedProgressView.update(withModel: CGFloat(value/maxValue))
            }
            self.sellerRatingViewToDeliveryTimeVerticalSpacingConstraint.priority = MASLayoutPriorityDefaultHigh
            self.seperatorToDeliveryTimeViewVerticalSpacingConstraint.priority = MASLayoutPriorityDefaultLow
            self.sellerRatingWrapperView.alpha = 1
        } else {
            self.sellerRatingViewToDeliveryTimeVerticalSpacingConstraint.priority = MASLayoutPriorityDefaultLow
            self.seperatorToDeliveryTimeViewVerticalSpacingConstraint.priority = MASLayoutPriorityDefaultHigh
            self.sellerRatingWrapperView.alpha = 0
        }
        
    }
    
    func runDeliveryTimeCalculations(productSku: String) {
        self.deliveryTimeView.productSku = productSku
        self.deliveryTimeView.fillTheView()
    }
    
    override static func nibName() -> String {
        return AppUtility.getStringFromClass(for: self)!
    }
    
    
    //TODO: this function is unnecessary but we need it for now!,
    //because in PDVVIew we have to !! change the alignment (with previous implmentations)
    func switchTheTextAlignments() {
        self.precenseDurationLabel.textAlignment = .left
        self.sellerOrderCounts.textAlignment = .right
        self.deliveryTimeView.switchTheTextAlignments()
    }
    
    func getCalculatedHeight() -> CGFloat {
        let totalHeightSize: CGFloat = 538
        let labelHeight: CGFloat = 35
        var heightSize: CGFloat = totalHeightSize
        
        //if seller has no guarantee message
        if self.guaranteeLabel.text == nil {
            heightSize -= labelHeight
        }
        
        //if seller has no score
        if self.sellerRatingWrapperView.alpha == 0 {
            heightSize -= 185
        }
        
        return heightSize
    }
}
