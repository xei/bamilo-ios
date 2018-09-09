//
//  ProductSpecificItemTableViewCell.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 6/26/18.
//  Copyright © 2018 Rocket Internet. All rights reserved.
//

import UIKit

class ProductSpecificItemTableViewCell: BaseTableViewCell {

    @IBOutlet private weak var specificTitle: UILabel!
    @IBOutlet private weak var specificValue: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        specificTitle.applyStyle(font: Theme.font(kFontVariationRegular, size: 12), color: Theme.color(kColorGray1))
        specificValue.applyStyle(font: Theme.font(kFontVariationBold, size: 12), color: Theme.color(kColorGray1))
    }
    
    override class func nibName() -> String {
        return AppUtility.getStringFromClass(for: self)!
    }
    
    override func update(withModel model: Any!) {
        if let specificItem = model as? ProductSpecificItem, let title = specificItem.title, let value = specificItem.value {
            specificTitle.text = title
            specificValue.text = value
        }
    }
}
