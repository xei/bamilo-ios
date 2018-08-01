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
    
    var productSku : String?
    var rating: ProductRate?
    var review: ProductReview?
    var signleReviewItem: ProductReviewItem?
    
    private var expandedIndexPathes = [IndexPath]()
    private var loadingDataInProgress = false
    private var listFullyLoaded = false
    private var pageNumber = 1
    
    private let paginationThresholdPoint: CGFloat = 100
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        submitReviewButton.applyStyle(font: Theme.font(kFontVariationRegular, size: 13), color: .white)
        submitReviewButton.setTitle(STRING_ADD_COMMENT, for: .normal)
        submitReviewButton.backgroundColor = Theme.color(kColorOrange1)
        
        submitReviewButton.setImage(#imageLiteral(resourceName: "ProductComment").withRenderingMode(.alwaysTemplate), for: .normal)
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
        if let _ = signleReviewItem {
            expandedIndexPathes = [IndexPath(row: 0, section: 1)]
        } else {
            getContent()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.hidesBottomBarWhenPushed = true
    }
    
    private func loadMore() {
        if loadingDataInProgress || listFullyLoaded { return }
        self.pageNumber += 1
        getContent(page: pageNumber)
    }
    
    private func getContent(page: Int = 1, completion: ((Bool)-> Void)? = nil) {
        if let sku = productSku, !loadingDataInProgress {
            loadingDataInProgress = true
            ProductDataManager.sharedInstance.getReviewsList(self, sku: sku, pageNumber: page, type: page == 1 ? .foreground : .background) { (data, error) in
                if (error == nil) {
                    self.bind(data, forRequestId: page == 1 ? 0 : 1)
                    completion?(true)
                } else {
                    self.errorHandler(error, forRequestID: 0)
                    completion?(false)
                }
                self.loadingDataInProgress = false
            }
        }
    }
    
    @IBAction func submitButtonTapped(_ sender: Any) {
        (navigationController as? JACenterNavigationController)?.performProtectedBlock({ (success) in
            self.performSegue(withIdentifier: "showSubmitProductReviewViewController", sender: nil)
        })
    }
    
    //MARK: - DataServiceProtocol
    func bind(_ data: Any!, forRequestId rid: Int32) {
        if let review = data as? ProductReview {
            if rid == 0 {
                self.review = review
            } else if let items = review.items {
                self.review?.items?.append(contentsOf: items)
            }
            if let lastPageNum = self.review?.pagination?.totalPage {
                listFullyLoaded = lastPageNum == pageNumber
            }
            self.tableview.reloadData()
        }
    }
    
    func retryAction(_ callBack: RetryHandler!, forRequestId rid: Int32) {
        self.getContent(page: pageNumber) { (succes) in
            callBack?(succes)
        }
    }
    
    func errorHandler(_ error: Error!, forRequestID rid: Int32) {
        if rid == 0 {
            if !Utility.handleErrorMessages(error: error, viewController: self) {
                self.handleGenericErrorCodesWithErrorControlView(Int32(error.code), forRequestID: rid)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let segueName = segue.identifier
        if segueName == "showSubmitProductReviewViewController", let viewCtrl = segue.destination as? SubmitProductReviewViewController {
            viewCtrl.prodcutSku = self.productSku
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
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 1 : (signleReviewItem != nil ? 1 : (review?.items?.count ?? 0))
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 && indexPath.row == 0 { //only first cell
            let cell = tableview.dequeueReusableCell(withIdentifier: ProductOveralRateTableViewCell.nibName(), for: indexPath) as! ProductOveralRateTableViewCell
            cell.update(withModel: rating)
            return cell
        } else {
            let cell = tableview.dequeueReusableCell(withIdentifier: ProductReviewItemTableViewCell.nibName(), for: indexPath) as! ProductReviewItemTableViewCell
            if let reviewItems = review?.items, indexPath.row < reviewItems.count {
                cell.isExpanded = expandedIndexPathes.contains(indexPath)
                cell.update(withModel: reviewItems[indexPath.row])
            } else if let reviewItems = signleReviewItem {
                cell.isExpanded = true
                cell.update(withModel: reviewItems)
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
