//
//  RateStarsView.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 5/22/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

import UIKit

@objc protocol RateStarsViewDelegate: class {
    @objc optional func rateValueSelected(value:Int)
}

class RateStarsView: BaseControlView {
    
    @IBOutlet private var starButtons: [IconButton]!
    weak var delegate: RateStarsViewDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = .clear
    }
    
    func updateWithMode(rateValue: Double) {
        self.colorButtons(rateValue: rateValue)
    }
    
    func colorButtons(rateValue: Double, color: UIColor = Theme.color(kColorOrange), disabledColor: UIColor = Theme.color(kColorGray9)) {
        let roundedRate = rateValue.roundByStep(step: 0.5)
        ThreadManager.execute {
            self.starButtons.forEach { (button) in
                button.imageHeightToButtonHeightRatio = 0.95
                if button.tag <= Int(roundedRate) {
                    button.imageView?.image = #imageLiteral(resourceName: "ProductRateFullStar").withRenderingMode(.alwaysTemplate)
                    button.imageView?.tintColor = color
                } else {
                    button.imageView?.image = #imageLiteral(resourceName: "ProductRateEmptyStar").withRenderingMode(.alwaysTemplate)
                    button.imageView?.tintColor = disabledColor
                }
                if roundedRate > Double(Int(roundedRate)) && button.tag == Int(roundedRate) + 1 { //has 0.5
                    button.imageView?.image = #imageLiteral(resourceName: "ProductRateHalfStar").withRenderingMode(.alwaysTemplate)
                    button.imageView?.tintColor = color
                }
            }
        }
    }
    
    @IBAction func rateButtonTapped(_ sender: UIButton) {
        self.updateWithMode(rateValue: Double(sender.tag))
        self.delegate?.rateValueSelected?(value: sender.tag)
    }
    
    func enableButtons(enable: Bool) {
        self.starButtons.forEach { (button) in
            button.isUserInteractionEnabled = enable
        }
    }
    
    //TODO: when we migrate all BaseControlView we need to use it as this function implementation
    override class func nibInstance() -> RateStarsView {
        return Bundle.main.loadNibNamed(String(describing: self), owner: self, options: nil)?.last as! RateStarsView
    }
}
