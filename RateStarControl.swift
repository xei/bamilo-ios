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
        self.backgroundColor = .clear
        self.rateView = RateStarsView.nibInstance()
        self.rateView?.delegate = self.delegate
        if let view = self.rateView {
            view.backgroundColor = .clear
            self.addAnchorMatchedSubView(view: view)
        }
    }
    
    func colorButtons(rateValue: Double, color: UIColor = UIColor(red:1, green:0.78, blue:0, alpha:1), disabledColor: UIColor = UIColor(red:0.85, green:0.85, blue:0.85, alpha:1)) {
        self.rateView?.colorButtons(rateValue: rateValue, color: color, disabledColor: disabledColor)
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
