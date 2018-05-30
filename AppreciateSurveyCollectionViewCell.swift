//
//  AppreciateSurveyCollectionViewCell.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 5/15/18.
//  Copyright © 2018 Rocket Internet. All rights reserved.
//

import UIKit
import M13Checkbox

class AppreciateSurveyCollectionViewCell: BaseCollectionViewCellSwift {
    @IBOutlet weak var checkMark: M13Checkbox!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.checkMark.boxType = .circle
        self.checkMark.markType = .checkmark
        self.checkMark.animationDuration = 1
        self.checkMark.stateChangeAnimation = .stroke
        self.checkMark.tintColor = UIColor.fromHexString(hex: "99c857")
        self.checkMark.isUserInteractionEnabled = false
        self.checkMark.checkState = .unchecked
        self.checkMark.checkmarkLineWidth = 5
        self.checkMark.boxLineWidth = 5
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.checkMark.setCheckState(.checked, animated: true)
    }

}
