//
//  OptionalUpdateViewController.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 9/12/18.
//  Copyright © 2018 Rocket Internet. All rights reserved.
//

import UIKit

class OptionalUpdateViewController: BaseViewController {

    var configs: AppConfigurations?
    
    @IBOutlet private weak var titleUpdateLabel: UILabel!
    @IBOutlet private weak var messageUpdateLabel: UILabel!
    @IBOutlet private weak var updateButton: IconButton!
    @IBOutlet private weak var refuseButton: UIButton!
    @IBOutlet private weak var updateButtonHeightConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        applyStyle()
        
        titleUpdateLabel.text = configs?.updateTitle
        messageUpdateLabel.text = configs?.updateMessage
    }
    
    private func applyStyle() {
        view.backgroundColor = .clear
        titleUpdateLabel.applyStyle(font: Theme.font(kFontVariationBold, size: 14), color: Theme.color(kColorGray1))
        messageUpdateLabel.applyStyle(font: Theme.font(kFontVariationMedium, size: 13), color: Theme.color(kColorGray1))
        updateButton.applyStyle(font: Theme.font(kFontVariationMedium, size: 12), color: .white)
        updateButton.layer.cornerRadius = updateButtonHeightConstraint.constant / 2
        updateButton.setTitle(STRING_UPDATE_NOW, for: .normal)
        refuseButton.applyStyle(font: Theme.font(kFontVariationMedium, size: 12), color: Theme.color(kColorBlue))
        refuseButton.setTitle(STRING_NOT_NOW, for: .normal)
        updateButton.applyGradient(colours: [
            UIColor(red:1, green:0.65, blue:0.05, alpha:1),
            UIColor(red:0.97, green:0.42, blue:0.11, alpha:1)
            ])
        updateButton.clipsToBounds = true
    }
    
    @IBAction func updateButtonTapped(_ sender: Any) {
        if let store = configs?.storeUrl {
            Utility.openExternalUrlOnBrowser(urlString: store)
        }
    }
    
    @IBAction func refuseButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
