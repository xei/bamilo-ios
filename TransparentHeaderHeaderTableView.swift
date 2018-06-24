//
//  TransparentHeaderHeaderTableView.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 6/3/18.
//  Copyright © 2018 Rocket Internet. All rights reserved.
//

import UIKit

class TransparentHeaderHeaderTableView: PlainTableViewHeaderCell {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.backgroundColor = .clear
        self.backgroundColor = .clear
        self.clipsToBounds = true
        self.contentView.clipsToBounds = true
        
        self.applyStyle(Theme.font(kFontVariationRegular, size: 13), color: Theme.color(kColorGray1))
    }
    
    override class func nibName() -> String {
        return AppUtility.getStringFromClass(for: self)!
    }
}
