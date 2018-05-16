//
//  SimpleProgressBar.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 4/28/18.
//  Copyright © 2018 Rocket Internet. All rights reserved.
//

import UIKit

class SimpleProgressBar: BaseControlView {

    @IBOutlet weak var progressBarView: UIView!
    @IBOutlet weak var progressWidthRatio: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = .clear
        self.progressBarView.backgroundColor = Theme.color(kColorBlue1)
    }
    
    func setTintColor(color: UIColor) {
        self.progressBarView.backgroundColor = color
    }
    
    func setProgressPercentage(percentage: CGFloat){
        self.progressWidthRatio = self.progressWidthRatio.setMultiplier(multiplier: min(max(percentage, 0), 1))
    }
    
    
    override static func nibName() -> String {
        return AppUtility.getStringFromClass(for: self)!
    }
}
