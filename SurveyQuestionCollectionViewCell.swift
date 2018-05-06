//
//  SurveyQuestionCollectionViewCell.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 3/6/18.
//  Copyright © 2018 Rocket Internet. All rights reserved.
//

import UIKit

class SurveyQuestionCollectionViewCell: BaseCollectionViewCellSwift {

    private var questionView: BaseSurveyQuestionControlView?
    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.backgroundColor = .white
    }
    override func update(withModel model: Any) {
        if let question = model as? SurveyQuestion, let type = question.type {
            switch type {
            case .radio:
                self.questionView = SelectOptionQuestionView.nibInstance()
            case .checkbox:
                self.questionView = SelectOptionQuestionView.nibInstance()
            case .imageSelect:
                self.questionView = ImageSelectQuestionView.nibInstance()
            case .nps:
                self.questionView = NPSQuestionView.nibInstance()
//            case .textbox:
//                break
//            case .essay:
//                break
            }
            if let view = self.questionView {
                self.contentView.addAnchorMatchedSubView(view: view)
                view.update(model: question)
            }
        }
    }
    
//    func getQuestionResponse(for orderID: String) -> [String: Any]? {
//        return self.questionView?.getQuestionResponse(for: orderID)
//    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.questionView?.removeFromSuperview()
    }
}
