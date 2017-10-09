//
//  BaseHomePageTeaserBoxTableViewCell.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 9/20/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

import UIKit

protocol BaseHomePageTeaserBoxTableViewCellDelegate: class {
    func teaserItemTappedWithTargetString(target: String)
}

class BaseHomePageTeaserBoxTableViewCell: BaseTableViewCell {

    weak var delegate: BaseHomePageTeaserBoxTableViewCellDelegate?
    override static func nibName() -> String {
        return AppUtility.getStringFromClass(for: self)!
    }
}
