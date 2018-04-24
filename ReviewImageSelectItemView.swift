//
//  ReviewImageSelectItemView.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 3/4/18.
//  Copyright © 2018 Rocket Internet. All rights reserved.
//

import UIKit
import Kingfisher

protocol ReviewImageSelectItemViewDelegate: class {
    func tapped(item: ReviewImageSelectItemView)
}

class ReviewImageSelectItemView: BaseControlView {
    
    @IBOutlet weak var imageSelectButton: IconButton!
    
    weak var delegate: ReviewImageSelectItemViewDelegate?
    
    var model: SurveyQuestionOption?
    var animationDuration: TimeInterval = 0.15
    var scaledValue: CGFloat = 10
    
    private var initialButtonRect: CGRect?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.applyStyle()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if self.initialButtonRect == nil {
            self.initialButtonRect = self.imageSelectButton.frame
        }
    }
    
    private func applyStyle() {
        self.backgroundColor = .white
        imageSelectButton.applyStyle(font: Theme.font(kFontVariationRegular, size: 9), color: Theme.color(kColorExtraDarkBlue))
        imageSelectButton.layer.masksToBounds = false
    }
    
    func update(model: SurveyQuestionOption) {
        self.imageSelectButton.setTitle(model.title, for: .normal)
        self.imageSelectButton.kf.setImage(with: model.image, for: .normal, options: [.transition(.fade(0.20))])
        if let isSelected = model.isSelected {
            self.updateViewForState(selected: isSelected)
        }
        self.model = model
    }
    
    @IBAction private func buttonTapped(_ sender: Any) {
        self.setSelected(selected: true)
        self.delegate?.tapped(item: self)
    }
    
    func setSelected(selected: Bool, animated: Bool = true) {
        UIView.animate(withDuration: animated ? animationDuration : 0, animations: {
            self.updateViewForState(selected: selected)
        })
        self.model?.isSelected = selected
    }
    
    private func updateViewForState(selected: Bool) {
        if let initialButtonRect = self.initialButtonRect {
            self.imageSelectButton.frame = CGRect(
                x: initialButtonRect.origin.x + (selected ? -(self.scaledValue / 2) : (self.scaledValue / 2)),
                y: initialButtonRect.origin.y + (selected ? -(self.scaledValue / 2) : (self.scaledValue / 2)),
                width: initialButtonRect.size.width + (selected ? (self.scaledValue) : -(self.scaledValue)),
                height: initialButtonRect.size.height + (selected ? (self.scaledValue) : -(self.scaledValue))
            )
        }
        self.alpha = selected ? 1 : 0.5
    }
    
    override static func nibInstance() -> ReviewImageSelectItemView {
        return Bundle.main.loadNibNamed(String(describing: self), owner: self, options: nil)?.last as! ReviewImageSelectItemView
    }
}
