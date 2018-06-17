//
//  ButtonCollectionViewCell.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 6/10/18.
//  Copyright © 2018 Rocket Internet. All rights reserved.
//

import UIKit

class ButtonCollectionViewCell: BaseCollectionViewCellSwift {

    @IBOutlet weak private var buttonView: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        buttonView.applyStyle(font: Theme.font(kFontVariationLight, size: 13), color: Theme.color(kColorGray1))
        buttonView.setTitleColor(Theme.color(kColorGray8), for: .disabled)
        buttonView.applyBorder(width: 1, color: Theme.color(kColorGray1))
    }
    
    func setTitle(title: String) {
        buttonView.setTitle(title, for: .normal)
    }
    
    func setEnable(enable: Bool) {
        buttonView.isEnabled = enable
        buttonView.applyBorder(width: 1, color: Theme.color(enable ? kColorGray1 : kColorGray8))
    }
}
