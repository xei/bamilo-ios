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
//            case .radio:
//                break
//            case .checkbox:
//                break
//            case .essay:
//                break
            case .imageSelect:
                let view = ImageSelectQuestionView.nibInstance()
                self.contentView.addAnchorMatchedSubView(view: view)
                view.update(model: question)
                self.questionView = view
            case .nps:
                let view = NPSQuestionView.nibInstance()
                self.contentView.addAnchorMatchedSubView(view: view)
                view.update(model: question)
                self.questionView = view
                break
//            case .textbox:
//                break
            }
        }
    }
    
    func getQuestionResponse(for orderID: String) -> [String: Any]? {
        return self.questionView?.getQuestionResponse(for: orderID)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.questionView?.removeFromSuperview()
    }
}
