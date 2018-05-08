//
//  RadioOptionQuestionView.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 5/7/18.
//  Copyright © 2018 Rocket Internet. All rights reserved.
//

import UIKit

class RadioOptionQuestionView: BaseSurveyQuestionControlView {

    @IBOutlet weak var titleLabelBottomToRadioViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageToRadioViewVerticalSpaceConstraint: NSLayoutConstraint!
    @IBOutlet weak private var radioButtonGroupView: RadioColoredButtonsGroupControl!
    @IBOutlet weak private var questionTitleLabel: UILabel!
    @IBOutlet weak private var productImageView: UIImageView!
    @IBOutlet weak private var radioViewHeightConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.questionTitleLabel.applyStyle(font: Theme.font(kFontVariationRegular, size: 13), color: Theme.color(kColorGray1))
        self.questionTitleLabel.textAlignment = .right
    }
    
    override func update(model: SurveyQuestion) {
        if let type = model.type, (type == .radio || type == .checkbox) {
            self.questionTitleLabel.text = model.title
            if let options = model.options {
                self.radioButtonGroupView.update(withModel: options)
            }
            if let image = model.product?.imageUrl {
                self.productImageView.kf.setImage(with: image, options: [.transition(.fade(0.20))])
                self.imageToRadioViewVerticalSpaceConstraint.priority = UILayoutPriorityDefaultHigh
                self.titleLabelBottomToRadioViewConstraint.priority = UILayoutPriorityDefaultLow
            } else {
                self.imageToRadioViewVerticalSpaceConstraint.priority = UILayoutPriorityDefaultLow
                self.titleLabelBottomToRadioViewConstraint.priority = UILayoutPriorityDefaultHigh
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.radioViewHeightConstraint.constant = self.radioButtonGroupView.getGetContentSizeHeight()
        self.superview?.setNeedsLayout()
        self.superview?.layoutIfNeeded()
    }
}
