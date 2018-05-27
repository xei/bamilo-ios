//
//  BaseHomePageTeaserBoxTableViewCell.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 9/20/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

import UIKit

protocol BaseHomePageTeaserBoxTableViewCellDelegate: class {
    func teaserItemTappedWithTargetString(target: String, teaserId: String, index: Int?)
}

protocol HomePageTeaserHeightCalculator {
    static func teaserHeight(model: Any?) -> CGFloat
}

class BaseHomePageTeaserBoxTableViewCell: BaseTableViewCell {

    weak var delegate: BaseHomePageTeaserBoxTableViewCellDelegate?
    override class func nibName() -> String {
        return AppUtility.getStringFromClass(for: self)!
    }
}
