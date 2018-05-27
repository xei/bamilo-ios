//
//  SellerView.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 4/26/18.
//  Copyright © 2018 Rocket Internet. All rights reserved.
//

import UIKit

@objc protocol SellerViewDelegate {
    func refreshContent(sellerView: SellerView)
    func goToSellerPage(target: RITarget)
}

@objcMembers class SellerView: BaseControlView {

    @IBOutlet weak private var sellerNameLabel: UILabel!
    @IBOutlet weak private var sellerOrderCounts: UILabel!
    @IBOutlet weak private var guaranteeLabel: UILabel!
    @IBOutlet weak private var precenseDurationLabel: UILabel!
    @IBOutlet weak private var totalScoreValueLabel: UILabel!
    @IBOutlet weak private var totalScoreBaseValueLabel: UILabel!
    @IBOutlet weak private var fullfilmentTitleLabel: UILabel!
    @IBOutlet weak private var fullfilmentValueLabel: UILabel!
    @IBOutlet weak private var notReturnedTitleLabel: UILabel!
    @IBOutlet weak private var notReturnedValueLabel: UILabel!
    @IBOutlet weak private var slaReachedTitleLabel: UILabel!
    @IBOutlet weak private var slaReachedValueLabel: UILabel!
    @IBOutlet weak private var fullfillmentProgressView: SimpleProgressBarControl!
    @IBOutlet weak private var notReturnedProgressView: SimpleProgressBarControl!
    @IBOutlet weak private var slaReachedProgressView: SimpleProgressBarControl!
    @IBOutlet weak private var sellerRatingWrapperView: UIView!
    @IBOutlet weak private var deliveryTimeView: DeliveryTimeControl!
    @IBOutlet weak private var precenseDurationToSeperatorVerticalSpacingConstraint: NSLayoutConstraint!
    @IBOutlet weak private var guaranteeLabelToSeperatorVerticalSpacingConstraint: NSLayoutConstraint!
    @IBOutlet weak private var sellerRatingViewToDeliveryTimeVerticalSpacingConstraint: NSLayoutConstraint!
    @IBOutlet weak private var seperatorToDeliveryTimeViewVerticalSpacingConstraint: NSLayoutConstraint!
    @IBOutlet weak private var sellerNameToGuaranteeLabelVerticalSpacingConstraint: NSLayoutConstraint!
    @IBOutlet weak private var presenceDurationToGuaranteeLabelVerticalSpacingConstraint: NSLayoutConstraint!
    @IBOutlet weak private var horizontalSeperator: UIView!
    @IBOutlet weak private var norateView: UIView!
    @IBOutlet weak private var newSellerBadge: UIImageView!
    @IBOutlet weak private var noRateLabelToNewSellerBadgeHorizontalSpacingConstraint: NSLayoutConstraint!
    @IBOutlet weak private var noRateLabelToRightSuperviewConstriant: NSLayoutConstraint!
    @IBOutlet weak private var curroptedSellerRatingMessageLabel: UILabel!
    @IBOutlet weak private var sellerRatingRefreshButton: IconButton!
    @IBOutlet weak private var sellerRatingErrorView: UIView!
    @IBOutlet weak private var sellerNameToSeperatorVerticalSpacingConstraint: NSLayoutConstraint!
    
    weak var delegate: SellerViewDelegate?
    private var model: Seller?
    
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
        self.sellerRatingRefreshButton.setTitleColor(Theme.color(kColorOrange1), for: .normal)
        
    }
    
    func update(with seller: Seller) {
        self.sellerNameLabel.text = "\(STRING_SELLER): \(seller.name ?? STRING_NO_NAME)"
        if let orderDeliveryCount = seller.orderDeliveryCount {
            self.sellerOrderCounts.text = "\(orderDeliveryCount.label ?? STRING_ORDERS_COUNT): \(orderDeliveryCount.value ?? "")".convertTo(language: .arabic)
            self.sellerOrderCounts.textColor = orderDeliveryCount.color ?? Theme.color(kColorGray1)
        } else {
            self.sellerOrderCounts.text = ""
        }
        
        if let precenceDuration = seller.precenceDuration {
            self.precenseDurationLabel.text = "\(precenceDuration.label ?? STRING_PRECENSE_DURATION): \(precenceDuration.value ?? "")".convertTo(language: .arabic)
            self.precenseDurationLabel.textColor = precenceDuration.color ?? Theme.color(kColorGray1)
            self.precenseDurationLabel.alpha = 1
            
            self.sellerNameToGuaranteeLabelVerticalSpacingConstraint.priority = MASLayoutPriorityDefaultLow
            self.precenseDurationToSeperatorVerticalSpacingConstraint.priority = MASLayoutPriorityDefaultHigh
            self.sellerNameToSeperatorVerticalSpacingConstraint.priority = MASLayoutPriorityDefaultLow
        } else {
            self.sellerNameToGuaranteeLabelVerticalSpacingConstraint.priority = MASLayoutPriorityDefaultHigh
            self.precenseDurationToSeperatorVerticalSpacingConstraint.priority = MASLayoutPriorityDefaultLow
            self.precenseDurationLabel.alpha = 0
        }
        
        if let guarantee = seller.warranty {
            self.guaranteeLabel.text = "\(STRING_GUARANTEE): \(guarantee)".trimmingCharacters(in: .whitespacesAndNewlines)
            self.guaranteeLabelToSeperatorVerticalSpacingConstraint.priority = MASLayoutPriorityDefaultHigh
            self.precenseDurationToSeperatorVerticalSpacingConstraint.priority = MASLayoutPriorityDefaultLow
            self.guaranteeLabel.alpha = 1
            self.sellerNameToSeperatorVerticalSpacingConstraint.priority = MASLayoutPriorityDefaultLow
        } else {
            self.guaranteeLabel.text = nil
            self.guaranteeLabel.alpha = 0
            self.guaranteeLabelToSeperatorVerticalSpacingConstraint.priority = MASLayoutPriorityDefaultLow
            self.precenseDurationToSeperatorVerticalSpacingConstraint.priority = MASLayoutPriorityDefaultHigh
            
            if seller.precenceDuration == nil || seller.precenceDuration?.value == nil {
                self.sellerNameToSeperatorVerticalSpacingConstraint.priority = MASLayoutPriorityDefaultHigh
            }
        }
        
        if let score = seller.score {
            self.sellerRatingErrorView.isHidden = true
            if let totalScore = score.overall {
                self.totalScoreValueLabel.textColor = totalScore.color ?? Theme.color(kColorGreen1)
                if let value = totalScore.value, let maxValue = score.maxValue {
                    self.totalScoreValueLabel.text = formatScoreValue(score: value)
                    self.totalScoreBaseValueLabel.text = "\(STRING_FROM) \(formatScoreValue(score:maxValue)) \(STRING_RATE)"
                } else {
                    self.totalScoreValueLabel.text = nil
                    self.totalScoreBaseValueLabel.text = nil
                }
            } else {
                self.showErrorOnSellerScore()
            }
            self.fullfilmentTitleLabel.textColor = score.fullfilment?.color ?? Theme.color(kColorGray1)
            self.fullfilmentTitleLabel.text = score.fullfilment?.label ?? STRING_SUCCESSFUL_PRODUCT_SUMPPLEMENT
            
            self.fullfilmentValueLabel.textColor = score.fullfilment?.color ?? Theme.color(kColorGray1)
            self.fullfilmentValueLabel.text = "\(formatScoreValue(score: score.fullfilment?.value ?? 0)) \(STRING_FROM) \(formatScoreValue(score:score.maxValue ?? 0))"
            if let value = score.fullfilment?.value, let maxValue = score.maxValue {
                self.fullfillmentProgressView.update(withModel: CGFloat(value/maxValue))
            } else {
                self.showErrorOnSellerScore()
            }
            
            self.notReturnedTitleLabel.textColor = score.notReturned?.color ?? Theme.color(kColorGray1)
            self.notReturnedTitleLabel.text = score.notReturned?.label ?? STRING_NO_RETURN_TITLE
            
            self.notReturnedValueLabel.textColor = score.notReturned?.color ?? Theme.color(kColorGray1)
            self.notReturnedValueLabel.text = "\(formatScoreValue(score: score.notReturned?.value ?? 0)) \(STRING_FROM) \(formatScoreValue(score:score.maxValue ?? 0))"
            if let value = score.notReturned?.value, let maxValue = score.maxValue {
                self.notReturnedProgressView.update(withModel: CGFloat(value/maxValue))
            } else {
                self.showErrorOnSellerScore()
            }
            
            self.slaReachedTitleLabel.textColor = score.slaReached?.color ?? Theme.color(kColorGray1)
            self.slaReachedTitleLabel.text = score.slaReached?.label ?? STRING_SLA_TITLE
            
            self.slaReachedValueLabel.textColor = score.slaReached?.color ?? Theme.color(kColorGray1)
            self.slaReachedValueLabel.text = "\(formatScoreValue(score: score.slaReached?.value ?? 0)) \(STRING_FROM) \(formatScoreValue(score:score.maxValue ?? 0))"
            if let value = score.slaReached?.value, let maxValue = score.maxValue {
                self.slaReachedProgressView.update(withModel: CGFloat(value/maxValue))
            } else {
                self.showErrorOnSellerScore()
            }
            self.sellerRatingViewToDeliveryTimeVerticalSpacingConstraint.priority = MASLayoutPriorityDefaultHigh
            self.seperatorToDeliveryTimeViewVerticalSpacingConstraint.priority = MASLayoutPriorityDefaultLow
            self.sellerRatingWrapperView.alpha = 1
            self.horizontalSeperator.alpha = 1
            
            self.norateView.alpha = 0
        } else {
            self.sellerRatingViewToDeliveryTimeVerticalSpacingConstraint.priority = MASLayoutPriorityDefaultLow
            self.seperatorToDeliveryTimeViewVerticalSpacingConstraint.priority = MASLayoutPriorityDefaultHigh
            self.sellerRatingWrapperView.alpha = 0
            self.horizontalSeperator.alpha = 0
            self.norateView.alpha = 1
            
            self.noRateLabelToRightSuperviewConstriant.priority = seller.isNew ? MASLayoutPriorityDefaultLow : MASLayoutPriorityDefaultHigh
            self.noRateLabelToNewSellerBadgeHorizontalSpacingConstraint.priority = seller.isNew ? MASLayoutPriorityDefaultHigh : MASLayoutPriorityDefaultLow
            self.newSellerBadge.alpha = seller.isNew ? 1 : 0
        }
        self.model = seller
    }
    
    private func formatScoreValue(score: Double) -> String {
        let isInteger = floor(score) == score
        return "\(isInteger ? "\(Int(score))" : "\(score)")".convertTo(language: .arabic).persianDoubleFormat()
    }
    
    func showErrorOnSellerScore() {
        self.sellerRatingErrorView.isHidden = false
        self.sellerRatingErrorView.alpha = 1
    }
    
    func runDeliveryTimeCalculations(productSku: String) {
        self.deliveryTimeView.productSku = productSku
        self.deliveryTimeView.fillTheView()
    }
    
    override class func nibName() -> String {
        return AppUtility.getStringFromClass(for: self)!
    }
    
    
    //TODO: this function is unnecessary but we need it for now!,
    //because in PDVView we have to !! change the alignment (with previous implmentations)
    func switchTheTextAlignments() {
        self.precenseDurationLabel.textAlignment = .left
        self.sellerOrderCounts.textAlignment = .right
        self.sellerNameLabel.textAlignment = .left
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
        
        //if seller has no presence duration
        if self.precenseDurationLabel.alpha == 0 {
            heightSize -= 35
        }
        
        //if seller has no score
        if self.sellerRatingWrapperView.alpha == 0 {
            heightSize -= 185
        }
        
        return heightSize
    }
    
    @IBAction func sellerNameTapped(_ sender: Any) {
        if let target = self.model?.target {
            self.delegate?.goToSellerPage(target: target)
        }
    }
    
    @IBAction func sellerRatingRefreshButtonTapped(_ sender: Any) {
        self.delegate?.refreshContent(sellerView: self)
    }
}
