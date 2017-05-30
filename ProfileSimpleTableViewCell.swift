//
//  ProfileSimpleTableViewCell.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 5/29/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

import UIKit

class ProfileSimpleTableViewCell: BaseProfileTableViewCell {

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var iconImage: UIImageView!
    
    override func setupView() {
        super.setupView()
        self.titleLabel.applyStype(font: Theme.font(kFontVariationRegular, size: 12), color: Theme.color(kColorExtraDarkGray))
    }
    
    override func update(withModel model: Any!) {
        super.update(withModel: model)
//        if let dataModel = model as? ProfileSimpleTableViewCellDataModel {
//            self.titleLabel.text = dataModel.title
//            self.iconImage.image = UIImage(named: dataModel.iconName)
//        }
    }

    override static func nibName() -> String {
        return AppUtility.getStringFromClass(for: self)!
    }
    
    override static func cellHeight() -> CGFloat {
        return 48
    }
    
}
