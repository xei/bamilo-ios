//
//  SubCategoryLandingPageViewController.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 12/20/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

import UIKit

class SubCategoryLandingPageViewController: BaseViewController,
                                            UITableViewDataSource,
                                            UITableViewDelegate,
                                            UIScrollViewDelegate,
                                            CategoryCoverTableViewCellDelegate {
    
    @IBOutlet private weak var tableview: UITableView!
    
    var subcategories: [CategoryProduct]?
    var historyCategory: [CategoryProduct]?
    
    private var coverPageCell: CategoryCoverTableViewCell?
    private var coverHeight: CGFloat?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.clipsToBounds = true
        self.tableview.register(UINib(nibName: CategoryCoverTableViewCell.nibName(), bundle: nil), forCellReuseIdentifier: CategoryCoverTableViewCell.nibName())
        self.tableview.register(UINib(nibName: CategoryTableViewCell.nibName(), bundle: nil), forCellReuseIdentifier: CategoryTableViewCell.nibName())
        
        self.tableview.delegate = self
        self.tableview.dataSource = self
        self.tableview.clipsToBounds = false
        self.tableview.separatorStyle = .singleLine
        
        self.tableview.showsVerticalScrollIndicator = false
        self.tableview.showsHorizontalScrollIndicator = false
        if let histories = self.historyCategory, histories.count > 1, let _ = histories[1].coverImage {
            self.coverHeight = CategoryCoverTableViewCell.cellHeight()
        } else {
            self.coverHeight = 30 //to cover only breadcrumb (temprory)
        }
        
        //navigation title
        self.title = self.historyCategory?.last?.name
        
        //To remove extra seperators
        self.tableview.tableFooterView = UIView(frame: .zero)
    }
    
    //MARK: - UITableViewDataSource & UITableViewDelegate
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = self.tableview.dequeueReusableCell(withIdentifier: CategoryCoverTableViewCell.nibName(), for: indexPath) as! CategoryCoverTableViewCell
            self.coverPageCell = cell
            cell.delegate = self
            cell.layer.zPosition = 0
            cell.update(coverImageUrl: self.historyCategory?[1].coverImage, historyCategories: self.historyCategory ?? [])
            return cell
        } else if indexPath.section == 1 {
            let cell = self.tableview.dequeueReusableCell(withIdentifier: CategoryTableViewCell.nibName(), for: indexPath) as! CategoryTableViewCell
            if indexPath.row < self.subcategories?.count ?? 0 {
                cell.update(withModel: self.subcategories?[indexPath.row])
            }
            cell.layer.zPosition = CGFloat(indexPath.row + indexPath.section)
            return cell
        }
        return UITableViewCell()
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else if section == 1 {
            return self.subcategories?.count ?? 0
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 1, let subCats = self.subcategories, indexPath.row < subCats.count {
            if let title = subCats[indexPath.row].name {
                TrackerManager.postEvent(selector: EventSelectors.itemTappedSelector(), attributes: EventAttributes.itemTapped(categoryEvent: "Category", screenName: getScreenName(), labelEvent: title))
            }
            if let childs = subCats[indexPath.row].childern, childs.count > 0 {
                self.pushToSubCatViewByCategory(category: subCats[indexPath.row])
            } else if let target = subCats[indexPath.row].target, let screenName = getScreenName(), let title = subCats[indexPath.row].name {
                MainTabBarViewController.topNavigationController()?.openTargetString(target, purchaseInfo: BehaviourTrackingInfo.trackingInfo(category: "Category", label: title), currentScreenName: screenName)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return self.coverHeight ?? 0
        } else if indexPath.section == 1 {
            return UITableViewAutomaticDimension
        } else {
            return 0
        }
    }
    
    private func pushToSubCatViewByCategory(category: CategoryProduct) {
        let subCatViewController = ViewControllerManager.sharedInstance().loadViewController("subCategoryViewController") as! SubCategoryLandingPageViewController
        subCatViewController.subcategories = category.childern
        var history = self.historyCategory.map { $0 } //to make a copy
        history?.append(category)
        subCatViewController.historyCategory = history
        self.navigationController?.pushViewController(subCatViewController, animated: true)
    }
    
    //MARK: - UIScrollViewDelegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == self.tableview, self.tableview.contentOffset.y < 0 {
            let cellHeight = self.coverHeight ?? 0
            var coverImageRect = CGRect(x: 0, y:0, width: self.view.frame.width, height: cellHeight)
            coverImageRect.origin.y = self.tableview.contentOffset.y
            coverImageRect.size.height = -self.tableview.contentOffset.y + cellHeight
            self.coverPageCell?.coverImageView.frame = coverImageRect
        } else if let coverHeight = self.coverHeight, scrollView == self.tableview, self.tableview.contentOffset.y < coverHeight {
            let coverImageRect = CGRect(x: 0, y:self.tableview.contentOffset.y / 2, width: self.view.frame.width, height: coverHeight)
            self.coverPageCell?.coverImageView.frame = coverImageRect
        }
    }
    
    //MARK: - CategoryCoverTableViewCellDelegate
    func goBack(level: Int) {
        if let viewControllers = self.navigationController?.viewControllers, level < viewControllers.count {
            self.navigationController?.popToViewController(viewControllers[level], animated: true)
        }
    }
    
    override func getScreenName() -> String! {
        return "SubCategoriesView"
    }
    
    //MARK: - NavigationBarProtocol
    override func navBarleftButton() -> NavBarButtonType {
        return .search
    }
}
