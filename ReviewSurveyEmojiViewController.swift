//
//  ReviewSurveyEmojiViewController.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 3/3/18.
//  Copyright © 2018 Rocket Internet. All rights reserved.
//

import UIKit

class ReviewSurveyEmojiViewController: BaseViewController {

    @IBOutlet weak private var submitButton: OrangeButton!
    @IBOutlet weak private var titleLabel: UILabel!
    
    private var lastButtonTapped: UIButton?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.submitButton.setTitle(STRING_SUBMIT_LABEL, for: .normal)
    }
}
