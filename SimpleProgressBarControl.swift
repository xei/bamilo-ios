//
//  SimpleProgressBarControl.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 4/28/18.
//  Copyright © 2018 Rocket Internet. All rights reserved.
//

import UIKit

class SimpleProgressBarControl: BaseViewControl {

    var progressView: SimpleProgressBar?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = .clear
        self.progressView = SimpleProgressBar.nibInstance()
        if let view = self.progressView {
            self.addAnchorMatchedSubView(view: view)
        }
    }
    
    override func update(withModel model: Any!) {
        if let precentage = model as? Double {
            self.progressView?.setProgressPercentage(percentage: CGFloat(precentage))
        }
    }
}
