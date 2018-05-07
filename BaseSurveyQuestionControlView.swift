//
//  BaseSurveyQuestionControlView.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 3/6/18.
//  Copyright © 2018 Rocket Internet. All rights reserved.
//

import UIKit

class BaseSurveyQuestionControlView: BaseControlView {
    
    var questionModel: SurveyQuestion?
    func update(model: SurveyQuestion) {
        self.questionModel = model
    }
    
    override static func nibName() -> String {
        return AppUtility.getStringFromClass(for: self)!
    }
}
