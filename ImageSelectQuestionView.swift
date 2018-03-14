//
//  ImageSelectQuestionView.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 3/6/18.
//  Copyright © 2018 Rocket Internet. All rights reserved.
//

import UIKit

class ImageSelectQuestionView: BaseSurveyQuestionControlView {
    
    @IBOutlet weak private var questionTitle: UILabel!
    @IBOutlet weak private var reviewSelectImageControl: ReviewImageSelectControl!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.questionTitle.applyStyle(font: Theme.font(kFontVariationRegular, size: 15), color: Theme.color(kColorGray1))
    }
    
    override func update(model: SurveyQuestion) {
        if model.type == .imageSelect {
            self.questionTitle.text = model.title
            self.reviewSelectImageControl.update(withModel: model)
            self.questionModel = model
        }
    }
    
    override func getQuestionResponse(for orderID: String) -> [String:Any]? {
        if let selectedOption = self.reviewSelectImageControl.getSelectedOption() {
            questionModel?.options?.forEach({ $0.isSelected = $0.id == selectedOption.id })
            return questionModel?.prepareForSubmission(for: orderID)
        }
        return nil
    }
    
    override static func nibInstance() -> ImageSelectQuestionView {
        return Bundle.main.loadNibNamed(String(describing: self), owner: self, options: nil)?.last as! ImageSelectQuestionView
    }
}
