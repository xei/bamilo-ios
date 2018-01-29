//
//  PhoneViewController.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 1/29/18.
//  Copyright © 2018 Rocket Internet. All rights reserved.
//

import UIKit

class PhoneViewController: BaseViewController {

    @IBOutlet weak private var seperatorView: UIView!
    @IBOutlet weak private var titleMessageLabel: UILabel!
    @IBOutlet weak private var textFieldView: UITextField!
    @IBOutlet weak private var submissionButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    private func applyStyle() {
        self.titleMessageLabel.textAlignment = .right
        self.titleMessageLabel.applyStype(font: Theme.font(kFontVariationRegular, size: 13), color: Theme.color(kColorGray1))
        self.submissionButton.applyStyle(font: Theme.font(kFontVariationRegular, size: 12), color: .white)
        self.submissionButton.backgroundColor = Theme.color(kColorOrange1)
        
        self.submissionButton.setTitle(STRING_OK, for: .normal)
    }
    
    @IBAction func submissionButtonTapped(_ sender: Any) {
    }
}
