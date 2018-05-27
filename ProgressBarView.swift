//
//  ProgressBarView.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 10/28/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

import UIKit

class ProgressBarView: BaseControlView {
    
    @IBOutlet weak private var lineView: UIView!
    @IBOutlet weak private var heighLightedPartLineView: UIView!
    @IBOutlet weak private var hightLightViewWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak private var precentageIndicator: UIView!
    
    private lazy var progressItemViews = [ProgressBarItemView]()
    private var allWeights: CGFloat = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.lineView.backgroundColor = Theme.color(kColorGray9)
        self.heighLightedPartLineView.backgroundColor = Theme.color(kColorGreen1)
        self.precentageIndicator.backgroundColor = Theme.color(kColorGreen1)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        var progressPrecentage: CGFloat = 0 //almost zero

        var itemPositionX = self.lineView.frame.origin.x + self.lineView.frame.width
        let margin: CGFloat = self.lineView.frame.width / (allWeights != 0 ? allWeights : 1)
        let marginPrecentage = 1 / (allWeights != 0 ? allWeights : 1)
        
        var index = 0
        for progressItemView in self.progressItemViews {
            progressItemView.center = CGPoint(x: itemPositionX, y: self.lineView.center.y)
            itemPositionX -= margin * CGFloat(progressItemView.model?.multiplier ?? 1)
            if index != self.progressItemViews.count - 1 { //not last item
                if let progress = progressItemView.model?.progress, progress > 0 {
                    progressPrecentage += (CGFloat(progress) / 100) * marginPrecentage * CGFloat(progressItemView.model?.multiplier ?? 1)
                }
            }
            index += 1
        }
        self.hightLightViewWidthConstraint.constant = self.lineView.frame.width * progressPrecentage
    }
    
    func update(model: [OrderProductHistory]?) {
        self.allWeights = 0
        self.progressItemViews.forEach { (itemView) in
            itemView.removeFromSuperview()
        }
        self.progressItemViews.removeAll()

        var index = 0
        model?.forEach({ (historyItem) in
            let nibView = ProgressBarItemView.nibInstance()
            nibView.update(model: historyItem, isLast: index == model!.count - 1)
            self.progressItemViews.append(nibView)
            if let model = model, index != model.count - 1 { //not last item
                self.allWeights += CGFloat(historyItem.multiplier)
            }
            index += 1
            self.addSubview(nibView)
        })
    }
    
    //TODO: when we migrate all BaseControlView we need to use it as this function implementation
    override class func nibInstance() -> ProgressBarView {
        return Bundle.main.loadNibNamed(String(describing: self), owner: self, options: nil)?.last as! ProgressBarView
    }
}
