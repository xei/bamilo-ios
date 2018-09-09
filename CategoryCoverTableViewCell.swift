//
//  CategoryCoverTableViewCell.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 12/24/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

import UIKit
import Kingfisher

protocol CategoryCoverTableViewCellDelegate: class {
    func goBack(level: Int)
}
class CategoryCoverTableViewCell: BaseTableViewCell, BreadcrumbsViewDelegate {

    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak private var breadcrumbsView: BreadcrumbsControl!
    @IBOutlet weak private var breadcrumbsBackground: UIView!
    weak var delegate: CategoryCoverTableViewCellDelegate?
    
    private static let imageRatio: CGFloat = 2.25
    private static var maxCellHeight: CGFloat {
        return UIDevice.current.userInterfaceIdiom == .pad ? 250 : 160
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.breadcrumbsView.delegate = self
        self.breadcrumbsBackground.backgroundColor = Theme.color(kColorGray10)
        self.breadcrumbsBackground.alpha = 0.8
    }
    
    func update(coverImageUrl: URL?, historyCategories: [CategoryProduct]) {
        if coverImageUrl != nil {
            self.coverImageView.kf.setImage(with: coverImageUrl, options: [.transition(.fade(0.20))])
        }
        breadcrumbsView.breadcrumbsView?.buttonBackgroundColor = .clear
        breadcrumbsView.breadcrumbsView?.buttonTitleColor = Theme.color(kColorExtraDarkGray)
        breadcrumbsView.breadcrumbsView?.buttonTitleFont = Theme.font(kFontVariationRegular, size: 13)
        breadcrumbsView.breadcrumbsView?.contentHeight = 29
        breadcrumbsView.breadcrumbsView?.buttonVerticalMargin = 0
        breadcrumbsView.update(withModel: self.convertHistoryToBreadcrumbs(historyCategories: historyCategories))
    }
    
    private func convertHistoryToBreadcrumbs(historyCategories : [CategoryProduct]) -> [BreadcrumbsItem]? {
        return historyCategories.enumerated().map { (index, catItem) -> BreadcrumbsItem in
            let breadcrumbsItem = BreadcrumbsItem()
            breadcrumbsItem.title = catItem.name
            breadcrumbsItem.target = "\(index)"
            return breadcrumbsItem
        }
    }
    
    override class func cellHeight() -> CGFloat {
        return min(UIScreen.main.bounds.width / self.imageRatio, self.maxCellHeight)
    }
    
    //MARK: - BreadcrumbsViewDelegate
    func itemTapped(item: BreadcrumbsItem) {
        if let target = item.target, let level = Int(target) {
            self.delegate?.goBack(level: level)
        }
    }
    
    override class func nibName() -> String {
        return AppUtility.getStringFromClass(for: self)!
    }
}
