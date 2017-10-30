//
//  ProgressBarItemView.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 10/28/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

import UIKit

class ProgressBarItemView: BaseControlView {
    
    private let circleWidth: CGFloat = 13
    
    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak private var imageView: UIImageView!
    @IBOutlet weak private var circleView: UIView!
    @IBOutlet weak private var circleWidthConstraint: NSLayoutConstraint!
    
    var model : OrderProductHistory?
    
    let imageHistoryStepMapper: [OrderProductHistoryStep: String] = [
        .new: "orderCreated",
        .approved: "orderApproved",
        .received: "orderReceived",
        .shipped: "orderShipped",
        .delivered: "orderDelivered"
    ]
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.imageView.isHidden = true
        self.imageView.image = nil
        self.titleLabel.applyStype(font: Theme.font(kFontVariationRegular, size: 9), color: Theme.color(kColorGray8))
        self.titleLabel.text = .EMPTY
        self.circleView.layer.cornerRadius = self.circleWidth / 2
        self.circleWidthConstraint.constant = self.circleWidth
        self.backgroundColor = .clear
        self.clipsToBounds = false
        
        self.frame.size = ProgressBarItemView.getFrameSize()
        self.updateConstraints()
    }
    
    static func getFrameSize() -> CGSize {
        return CGSize(width: 50, height: 64)
    }
    
    func update(model: OrderProductHistory) {
        self.titleLabel.text = model.nameFa
        
        //title & circle color
        if model.status == .success {
            self.circleView.backgroundColor = Theme.color(kColorGreen1)
            self.titleLabel.textColor = Theme.color(kColorGreen1)
        } else if model.status == .fail {
            self.circleView.backgroundColor = Theme.color(kColorPink1)
            self.titleLabel.textColor = Theme.color(kColorPink1)
        } else {
            self.circleView.backgroundColor = Theme.color(kColorGray9)
            self.titleLabel.textColor = Theme.color(kColorGray8)
        }
        
        //set image it this level is active
        if let step = model.step, let imageName = self.imageHistoryStepMapper[step], model.status == .active {
            self.imageView.image = UIImage(named: imageName)
            self.imageView.isHidden = false
        } else if let step = model.step, step == .delivered, model.status == .success {
            self.imageView.image = UIImage(named: self.imageHistoryStepMapper[.delivered]!)
            self.imageView.isHidden = false
        }
        
        self.model = model
    }
    
    //TODO: when we migrate all BaseControlView we need to use it as this function implementation
    override static func nibInstance() -> ProgressBarItemView {
        return Bundle.main.loadNibNamed(String(describing: self), owner: self, options: nil)?.last as! ProgressBarItemView
    }
}
