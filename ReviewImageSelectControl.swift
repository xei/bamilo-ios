//
//  ReviewImageSelectControl.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 3/5/18.
//  Copyright © 2018 Rocket Internet. All rights reserved.
//

import UIKit

class ReviewImageSelectControl: BaseViewControl, ReviewImageSelectViewDelegate {
    
    var imageSelectView: ReviewImageSelectView?
    weak var delegate: ReviewImageSelectViewDelegate?
    private var model: SurveyQuestion?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.imageSelectView = ReviewImageSelectView.nibInstance()
        self.imageSelectView?.delegate = self
        if let view = self.imageSelectView {
            self.addAnchorMatchedSubView(view: view)
        }
    }
    
    override func update(withModel model: Any!) {
        if let model  = model as? SurveyQuestion {
            self.imageSelectView?.update(model: model)
            self.model = model
        }
    }
    
    func getSelectedOption() -> SurveyQuestionOption? {
        return self.imageSelectView?.getSelectedOption()
    }
    
    //MARK: - ReviewImageSelectViewDelegate
    func onFocus(refrence: ReviewImageSelectView) {
        self.delegate?.onFocus(refrence: refrence)
    }
}
