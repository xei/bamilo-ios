//
//  ProductSpecificsTitleTableHeaderView.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 6/26/18.
//  Copyright © 2018 Rocket Internet. All rights reserved.
//

import UIKit

class ProductSpecificsTitleTableHeaderView: PlainTableViewHeaderCell {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.backgroundColor = Theme.color(kColorGray10)
        self.backgroundColor = Theme.color(kColorGray10)
        self.applyStyle(Theme.font(kFontVariationRegular, size: 11), color: Theme.color(kColorGray1))
    }
    
    override class func cellHeight() -> CGFloat {
        return 28
    }
    
    override class func nibName() -> String {
        return AppUtility.getStringFromClass(for: self)!
    }
    
}
