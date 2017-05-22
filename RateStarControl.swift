//
//  RateStarControl.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 5/22/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

import UIKit

class RateStarControl: BaseViewControl {

    private var rateView: RateStarsView?
    weak var delegate: RateStarsViewDelegate? {
        didSet {
            self.rateView?.delegate = self.delegate
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.rateView = RateStarsView.nibInstance()
        self.rateView?.delegate = self.delegate
        if let view = self.rateView {
            self.addSubview(view)
            view.frame = self.bounds;
        }
    }
    
    override func update(withModel model: Any!) {
        if let rateValue = model as? Double {
            self.rateView?.updateWithMode(rateValue: rateValue)
        }
    }
    
    func enableButtons(enable:Bool) {
        self.rateView?.enableButtons(enable: enable)
    }
}
