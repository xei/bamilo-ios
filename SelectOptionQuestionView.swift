//
//  SelectOptionQuestionView.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 3/12/18.
//  Copyright © 2018 Rocket Internet. All rights reserved.
//

import UIKit
import Kingfisher

class SelectOptionQuestionView: BaseSurveyQuestionControlView {
    
    @IBOutlet weak var titleLabelBottomToSelectViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageBottonToSelectViewConstraint: NSLayoutConstraint!
    @IBOutlet weak private var selectView: SelectViewControl!
    @IBOutlet weak private var questionTitleLabel: UILabel!
    @IBOutlet weak private var productImageView: UIImageView!
    @IBOutlet weak private var selectViewHeightConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.questionTitleLabel.applyStyle(font: Theme.font(kFontVariationRegular, size: 13), color: Theme.color(kColorGray1))
        self.questionTitleLabel.textAlignment = .right
        self.selectView.applyShadow(position: CGSize(width:0 , height: 1), color: .black, opacity: 0.2)
    }
    
    override func update(model: SurveyQuestion) {
        if let type = model.type, (type == .radio || type == .checkbox) {
            self.questionTitleLabel.text = model.title
            if let options = model.options {
                self.selectView.selectionType = type == .checkbox ? .checkbox : .radio
                self.selectView.update(withModel: options)
            }
            if let image = model.product?.imageUrl {
                self.productImageView.kf.setImage(with: image, options: [.transition(.fade(0.20))])
                self.imageBottonToSelectViewConstraint.priority = UILayoutPriorityDefaultHigh
                self.titleLabelBottomToSelectViewConstraint.priority = UILayoutPriorityDefaultLow
            } else {
                self.imageBottonToSelectViewConstraint.priority = UILayoutPriorityDefaultLow
                self.titleLabelBottomToSelectViewConstraint.priority = UILayoutPriorityDefaultHigh
            }
        }
        self.selectViewHeightConstraint.constant = self.selectView.getGetContentSizeHeight()
    }
}
