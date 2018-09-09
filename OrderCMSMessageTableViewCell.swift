//
//  OrderCMSMessageTableViewCell.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 10/31/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

import UIKit

class OrderCMSMessageTableViewCell: BaseTableViewCell {

    @IBOutlet weak private var titleMessageLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.titleMessageLabel.applyStyle(font: Theme.font(kFontVariationRegular, size: 13), color: Theme.color(kColorPink3))
        self.contentView.backgroundColor = Theme.color(kColorPink10)
        self.backgroundColor = Theme.color(kColorPink10)
    }
    
    override func update(withModel model: Any!) {
        if let titleMessage = model as? String {
            self.titleMessageLabel.text = titleMessage
        }
    }

    override class func nibName() -> String {
        return AppUtility.getStringFromClass(for: self)!
    }
}
