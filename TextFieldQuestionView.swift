//
//  TextFieldQuestionView.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 5/8/18.
//  Copyright © 2018 Rocket Internet. All rights reserved.
//

import UIKit

class TextFieldQuestionView: BaseSurveyQuestionControlView, UITextViewDelegate {
    
    @IBOutlet weak var questionTitleLabel: UILabel!
    @IBOutlet weak var answerTextView: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.questionTitleLabel.applyStyle(font: Theme.font(kFontVariationRegular, size: 13), color: Theme.color(kColorGray1))
        self.answerTextView.backgroundColor = Theme.color(kColorGray10)
        self.answerTextView.applyBorder(width: 1, color: Theme.color(kColorGray8))
        self.answerTextView.font = Theme.font(kFontVariationRegular, size: 13)
        self.answerTextView.delegate = self
    }
    
    
    override func update(model: SurveyQuestion) {
        self.questionTitleLabel.text = model.title
        if let answer = model.anwerTextMessage {
            self.answerTextView.textColor = Theme.color(kColorGray1)
            self.answerTextView.text = answer
        } else {
            self.answerTextView.textColor = .lightGray
            self.answerTextView.text = STRING_WRITE_COMMENT
        }
        self.questionModel = model
    }
    
    //MARK: - UITextViewDelegate
    func textViewDidEndEditing(_ textView: UITextView) {
        self.answerTextView.applyBorder(width: 1, color: Theme.color(kColorGray8))
        if answerTextView.text == "" {
            answerTextView.textColor = .lightGray
            answerTextView.text = STRING_WRITE_COMMENT
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        self.answerTextView.applyBorder(width: 1, color: Theme.color(kColorOrange1))
        if answerTextView.textColor == .lightGray {
            answerTextView.text = ""
            answerTextView.textColor = Theme.color(kColorGray1)
        }
    }
    
    
    func textViewDidChange(_ textView: UITextView) {
        if self.answerTextView.textColor != .lightGray {
            self.questionModel?.anwerTextMessage = textView.text
        }
    }
}
