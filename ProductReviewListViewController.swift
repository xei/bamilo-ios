//
//  ProductReviewListViewController.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 7/3/18.
//  Copyright © 2018 Rocket Internet. All rights reserved.
//

import UIKit

class ProductReviewListViewController: BaseViewController, DataServiceProtocol {

    @IBOutlet private weak var tableview: UITableView!
    @IBOutlet private weak var submitReviewButton: IconButton!
    
    
    var product : Product?
    
    private var expandedIndexPathes = [IndexPath]()
    private var loadingDataInProgress = false
    private var listFullyLoaded = false
    private var pageNumber = 1
    
    private let paginationThresholdPoint: CGFloat = 100
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        submitReviewButton.applyStyle(font: Theme.font(kFontVariationRegular, size: 13), color: .white)
        submitReviewButton.setTitle(STRING_SUBMIT_LABEL, for: .normal)
        submitReviewButton.backgroundColor = Theme.color(kColorOrange1)
        
        let image = #imageLiteral(resourceName: "ProductComment").withRenderingMode(.alwaysTemplate)
        submitReviewButton.setImage(image, for: .normal)
        submitReviewButton.tintColor = .white
        
        
        tableview.delegate = self
        tableview.dataSource = self
        [ProductOveralRateTableViewCell.nibName(), ProductReviewItemTableViewCell.nibName()].forEach {
            tableview.register(UINib(nibName: $0, bundle: nil), forCellReuseIdentifier: $0)
        }
        
        //remove extra seperators
        tableview.tableFooterView = UIView(frame: .zero)
        tableview.showsVerticalScrollIndicator = false
        tableview.separatorStyle = .none
    }
    
    private func loadMore() {
        if self.loadingDataInProgress || self.listFullyLoaded { return }
        self.pageNumber += 1
        self.loadingDataInProgress = true
    }
    
    private func getContent(page: Int = 1) {
        
    }
    
    @IBAction func submitButtonTapped(_ sender: Any) {
        (navigationController as? JACenterNavigationController)?.performProtectedBlock({ (success) in
            self.performSegue(withIdentifier: "showSubmitProductReviewViewController", sender: nil)
        })
    }
    
    //MARK: - DataServiceProtocol
    func bind(_ data: Any!, forRequestId rid: Int32) {
        
    }
    
    func errorHandler(_ error: Error!, forRequestID rid: Int32) {
        
    }
    
    func retryAction(_ callBack: RetryHandler!, forRequestId rid: Int32) {
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let segueName = segue.identifier
        if segueName == "showSubmitProductReviewViewController", let viewCtrl = segue.destination as? SubmitProductReviewViewController {
            viewCtrl.prodcut = self.product
        }
    }
    
    //MARK: - DataTrackerProtocol
    override func getScreenName() -> String! {
        return "ProductReviewListView"
    }
    
    override func navBarTitleString() -> String! {
        return STRING_USER_REVIEWS
    }
}

extension ProductReviewListViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if !self.loadingDataInProgress && !self.listFullyLoaded {
            let bottomEdge = scrollView.contentOffset.y + scrollView.frame.size.height
            if (bottomEdge >= (scrollView.contentSize.height - paginationThresholdPoint)) {
                // we are approaching at the end of scrollview
                self.loadMore()
            }
        }
    }
}


extension ProductReviewListViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (product?.reviews?.items?.count ?? 0) + 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 { //only first cell
            let cell = tableview.dequeueReusableCell(withIdentifier: ProductOveralRateTableViewCell.nibName(), for: indexPath) as! ProductOveralRateTableViewCell
            cell.update(withModel: product?.ratings)
            return cell
        } else {
            let cell = tableview.dequeueReusableCell(withIdentifier: ProductReviewItemTableViewCell.nibName(), for: indexPath) as! ProductReviewItemTableViewCell
            if let reviewItems = product?.reviews?.items, indexPath.row < reviewItems.count {
                cell.isExpanded = expandedIndexPathes.contains(indexPath)
                cell.update(withModel: reviewItems[indexPath.row])
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? ProductReviewItemTableViewCell, !cell.isExpanded {
            expandedIndexPathes.append(indexPath)
            tableView.beginUpdates()
            cell.expand()
            tableView.endUpdates()
        }
    }
}
