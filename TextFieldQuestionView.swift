//
//  TextFieldQuestionView.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 5/8/18.
//  Copyright © 2018 Rocket Internet. All rights reserved.
//

import UIKit

class TextFieldQuestionView: BaseSurveyQuestionControlView, UITextViewDelegate {
    
    @IBOutlet weak private var questionTitleLabel: UILabel!
    @IBOutlet weak private var answerTextView: UITextView!
    @IBOutlet weak private var contentScrollView: UIScrollView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.questionTitleLabel.applyStyle(font: Theme.font(kFontVariationRegular, size: 13), color: Theme.color(kColorGray1))
        self.answerTextView.backgroundColor = Theme.color(kColorGray10)
        self.answerTextView.font = Theme.font(kFontVariationRegular, size: 13)
        self.answerTextView.delegate = self
        self.answerTextView.layer.cornerRadius = 4
        self.answerTextView.clipsToBounds = true
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
        //To switch back to placeholder if necessary
        if answerTextView.text == "" {
            answerTextView.textColor = .lightGray
            answerTextView.text = STRING_WRITE_COMMENT
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if answerTextView.textColor == .lightGray {
            answerTextView.text = ""
            answerTextView.textColor = Theme.color(kColorGray1)
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        //update question model
        if self.answerTextView.textColor != .lightGray {
            self.questionModel?.anwerTextMessage = textView.text
        }
    }
}
