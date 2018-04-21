//
//  ImageSelectQuestionView.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 3/6/18.
//  Copyright © 2018 Rocket Internet. All rights reserved.
//

import UIKit
import Kingfisher

class ImageSelectQuestionView: BaseSurveyQuestionControlView {
    
    @IBOutlet weak private var questionTitle: UILabel!
    @IBOutlet weak private var reviewSelectImageControl: ReviewImageSelectControl!
    @IBOutlet weak private var titleToImageSelectViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak private var productImageViewToSelectViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak private var productImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.questionTitle.applyStyle(font: Theme.font(kFontVariationRegular, size: 13), color: Theme.color(kColorGray1))
        self.questionTitle.textAlignment = .right
    }
    
    override func update(model: SurveyQuestion) {
        if model.type == .imageSelect {
            self.questionTitle.text = model.title
            self.reviewSelectImageControl.update(withModel: model)
            self.questionModel = model
            
            
            if let productImage = model.product?.imageUrl {
                self.productImageView.kf.setImage(with: productImage, options: [.transition(.fade(0.20))])
                self.productImageViewToSelectViewBottomConstraint.priority = UILayoutPriorityDefaultHigh
                self.titleToImageSelectViewBottomConstraint.priority = UILayoutPriorityDefaultLow
            } else {
                self.productImageViewToSelectViewBottomConstraint.priority = UILayoutPriorityDefaultLow
                self.titleToImageSelectViewBottomConstraint.priority = UILayoutPriorityDefaultHigh
            }
        }
    }
    
    override static func nibInstance() -> ImageSelectQuestionView {
        return Bundle.main.loadNibNamed(String(describing: self), owner: self, options: nil)?.last as! ImageSelectQuestionView
    }
}
