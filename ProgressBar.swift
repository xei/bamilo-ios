//
//  ProgressBar.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 10/28/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

import UIKit

class ProgressBar: BaseViewControl {
    var barView: ProgressBarView?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.barView = ProgressBarView.nibInstance()
        if let view = self.barView {
            self.addAnchorMatchedSubView(view: view)
        }
    }
    
    override func update(withModel model: Any!) {
        if let model = model as? [OrderProductHistory] {
            self.barView?.update(model: model)
        }
    }
}
