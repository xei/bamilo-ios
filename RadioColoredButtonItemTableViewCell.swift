//
//  RadioColoredButtonItemTableViewCell.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 5/6/18.
//  Copyright © 2018 Rocket Internet. All rights reserved.
//

import UIKit

class RadioColoredButtonItemTableViewCell: SelectItemViewCell {

    @IBOutlet weak private var titleLabelView: UILabel!
    @IBOutlet weak private var greenBackgroundView: UIView!
    @IBOutlet weak private var redBackgroundView: UIView!
    @IBOutlet weak private var whiteBackgroundView: UIView!
    
    var progresIndex: Double = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.titleLabelView.applyStyle(font: Theme.font(kFontVariationRegular, size: 13), color: Theme.color(kColorGray1))
        [greenBackgroundView, redBackgroundView, whiteBackgroundView].forEach { $0?.roundCorners(.allCorners, radius: 4) } 
    }
    
    override func update(withModel model: Any!) {
        if let model = model as? SelectViewItemDataSourceProtocol {
            self.titleLabelView.text = model.title ?? ""
            self.redBackgroundView.alpha = CGFloat(progresIndex)
            self.setState(checked: model.isSelected ?? false)
            self.model = model
        }
    }
    
    override func toggle() {
        self.whiteBackgroundView.alpha = self.whiteBackgroundView.alpha == 1 ? 0.8 : 1
    }
    
    override func setSelectionType(type: SelectionType) {
        //there is nothing to do
        return
    }
    
    override func setState(checked: Bool, animated: Bool = false) {
        if animated {
            UIView.animate(withDuration: 0.15) {
                self.whiteBackgroundView.alpha = checked ? 0.8 : 1
            }
        } else {
            self.whiteBackgroundView.alpha = checked ? 0.8 : 1
        }
    }
}
