//
//  ProductDescriptionsViewController.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 6/26/18.
//  Copyright © 2018 Rocket Internet. All rights reserved.
//

import UIKit

class ProductDescriptionsViewController: BaseViewController {
    
    @IBOutlet private weak var wholeDescriptionTextView: UITextView!
    var productDescription: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        wholeDescriptionTextView.font = Theme.font(kFontVariationRegular, size: 12)
        wholeDescriptionTextView.isEditable = false
        wholeDescriptionTextView.isMultipleTouchEnabled = false
        wholeDescriptionTextView.showsVerticalScrollIndicator = false
        
        if let desc = productDescription {
            self.updateWithDescription(description: desc)
        }
    }

    private func updateWithDescription(description: String) {
        wholeDescriptionTextView.text = description
        wholeDescriptionTextView.setContentOffset(.zero, animated: false)
    }
}
