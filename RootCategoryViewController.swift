//
//  RootCategoryViewController.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 12/20/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

import UIKit

class RootCategoryViewController: BaseViewController,
                                    DataServiceProtocol,
                                    UITableViewDataSource,
                                    UITableViewDelegate,
                                    UIScrollViewDelegate,
                                    UITextFieldDelegate {
    
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var tableview: UITableView!
    @IBOutlet private weak var searchbar: SearchBarControl!
    @IBOutlet private weak var searchBarHeight: NSLayoutConstraint!
    
    typealias RequestCompletion = (Bool) -> Void
    
    private var incomingCategories: Categories?
    private var incomingExternalLinks: ExternalLinks?
    private var incomingInternalLinks: InternalLinks?
    
    private var categories: Categories?
    private var externalLinks: ExternalLinks?
    private var internalLinks: InternalLinks?
    
    private let categoriesRequestID: Int32 = 0
    private let externalLinksRequestID: Int32 = 1
    private let internalLinksRequestID: Int32 = 2
    
    private var loadContentCompletion: RequestCompletion?
    private var sectionTypes: [Int:Any] = [:]
    
    private var successRequestIds: [Int32] = []
    private var requestIdsInProgress: [Int32] = [] {
        didSet {
            if self.requestIdsInProgress.count > 0 {
                self.activityIndicator.startAnimating()
                return
            }
            self.activityIndicator.stopAnimating()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.tableview.register(UINib(nibName: CategoryTableViewCell.nibName(), bundle: nil), forCellReuseIdentifier: CategoryTableViewCell.nibName())
        self.tableview.register(UINib(nibName: PlainTableViewHeaderCell.nibName(), bundle: nil), forHeaderFooterViewReuseIdentifier: PlainTableViewHeaderCell.nibName())
        
        self.tableview.delegate = self
        self.tableview.dataSource = self
        self.tableview.separatorStyle = .singleLine
        
        self.searchbar.searchView?.textField.delegate = self
        //To remove extra seperators
        self.tableview.tableFooterView = UIView(frame: .zero)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.loadContent()
    }
    
    private func loadContent(completion: RequestCompletion? = nil) {
        var hasReceivedError = false
        self.loadCategories { (success) in
            if !success, !hasReceivedError {
                hasReceivedError = true
                completion?(success)
            }
        }
        self.loadExternalLinks { (success) in
            if !success, !hasReceivedError {
                hasReceivedError = true
                completion?(success)
            }
        }
//        self.loadInternalLinks { (success) in
//            if !success, !hasReceivedError {
//                hasReceivedError = true
//                completion?(success)
//            }
//        }
        self.loadContentCompletion = completion
    }
    
    private func loadCategories(completion: RequestCompletion? = nil ) {
        if self.requestIdsInProgress.contains(self.categoriesRequestID) { return }
        if self.incomingCategories != nil {
            self.removeFromRequestIDs(rid: self.categoriesRequestID)
            completion?(true)
            return
        }
        
        self.requestIdsInProgress.append(self.categoriesRequestID)
        CategoryDataManager.sharedInstance.getWholeTree(self, requestType: .background) { (data, error) in
            self.handleRequestResponse(data: data, error: error, requestID: self.categoriesRequestID)
            completion?(error == nil)
        }
    }
    private func loadExternalLinks(completion: RequestCompletion? = nil ) {
        if self.requestIdsInProgress.contains(self.externalLinksRequestID) { return }
        if self.incomingExternalLinks != nil {
            self.removeFromRequestIDs(rid: self.externalLinksRequestID)
            completion?(true)
            return
        }
        
        self.requestIdsInProgress.append(self.externalLinksRequestID)
        CategoryDataManager.sharedInstance.getExternalLinks(self, requestType: .background) { (data, error) in
            self.handleRequestResponse(data: data, error: error, requestID: self.externalLinksRequestID)
            completion?(error == nil)
        }
    }
    private func loadInternalLinks(completion: RequestCompletion? = nil ) {
        if self.requestIdsInProgress.contains(self.internalLinksRequestID) { return }
        self.requestIdsInProgress.append(self.internalLinksRequestID)
        if self.incomingInternalLinks != nil {
            self.removeFromRequestIDs(rid: self.internalLinksRequestID)
            completion?(true)
            return
        }
        
        CategoryDataManager.sharedInstance.getInternalLinks(self, requestType: .background) { (data, error) in
            self.handleRequestResponse(data: data, error: error, requestID: self.internalLinksRequestID)
            completion?(error == nil)
        }
    }
    
    private func handleRequestResponse(data: Any?, error: NSError?, requestID: Int32) {
        self.removeFromRequestIDs(rid: requestID)
        if error == nil {
            self.successRequestIds.append(requestID)
            self.bind(data, forRequestId: requestID)
        } else {
            self.errorHandler(error, forRequestID: requestID)
            self.bind(data, forRequestId: requestID)
        }
    }
    
    private func removeFromRequestIDs(rid: Int32) {
        self.requestIdsInProgress = self.requestIdsInProgress.filter { $0 != rid }
    }
    
    private func getModelOfSection(section: Int) -> [Any]? {
        if section < self.sectionTypes.count {
            let sectionType = self.sectionTypes[section]
            if let _ = sectionType as? Categories.Type, let catTree = self.categories?.tree {
                return catTree[0].childern
            } else if let _ = sectionType as? ExternalLinks.Type {
                return externalLinks?.items
            } else if let _ = sectionType as? InternalLinks.Type {
                return self.internalLinks?.items
            }
        }
        return nil
    }
    
    private func getModelOfIndexPath(indexPath: IndexPath) -> Any? {
        if let sectionModel = self.getModelOfSection(section: indexPath.section), indexPath.row < sectionModel.count {
            return sectionModel[indexPath.row]
        }
        return nil
    }
    
    //MARK: - UITableViewDataSource, UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let model = self.getModelOfIndexPath(indexPath: indexPath) {
            if let cat = model as? CategoryProduct {
                
                //Track tapping on Cat item
                TrackerManager.postEvent(selector: EventSelectors.itemTappedSelector(), attributes: EventAttributes.itemTapped(categoryEvent: "Category", screenName: getScreenName(), labelEvent: cat.name ?? ""))
                
                if cat.childern?.count ?? 0 > 0 {
                    self.performSegue(withIdentifier: "showsubCategories", sender: cat)
                } else if let screenName = getScreenName(), let categoryName = cat.name{
                    MainTabBarViewController.topNavigationController()?.openTargetString(cat.target, purchaseInfo: BehaviourTrackingInfo.trackingInfo(category: "Category", label: categoryName), currentScreenName: screenName)
                }
            } else if let extLink = model as? ExternalLink, let browserLink = extLink.link, let validURL = URL(string: browserLink) {
                UIApplication.shared.openURL(validURL)
            } else if let link = model as? InternalLink, let screenName = getScreenName() {
                MainTabBarViewController.topNavigationController()?.openTargetString(link.target, purchaseInfo: nil, currentScreenName: screenName)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableview.dequeueReusableCell(withIdentifier: CategoryTableViewCell.nibName(), for: indexPath) as! CategoryTableViewCell
        cell.forcedAlignment = .left
        cell.update(withModel: self.getModelOfIndexPath(indexPath: indexPath))
        return cell
    }
    
    
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 { return nil }
        let header = self.tableview.dequeueReusableHeaderFooterView(withIdentifier: PlainTableViewHeaderCell.nibName()) as! PlainTableViewHeaderCell
        let sectionType = self.sectionTypes[section]
        if sectionType is ExternalLinks.Type {
            header.titleString = self.externalLinks?.title
        } else if sectionType is InternalLinks.Type {
            header.titleString = self.internalLinks?.title
        }
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 { return 0 }
        return PlainTableViewHeaderCell.cellHeight()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.sectionTypes.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.getModelOfSection(section: section)?.count ?? 0
    }
    
    //MARK: - UITextFieldDelegate
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.endEditing(true)
        self.performSegue(withIdentifier: "ShowSearchView", sender: nil)
    }
    
    //MARK: - DataServiceProtocol
    func bind(_ data: Any!, forRequestId rid: Int32) {
        if let model = data as? Categories {
            self.incomingCategories = model
        } else if let model = data as? InternalLinks {
            self.incomingInternalLinks = model
        } else if let model = data as? ExternalLinks {
            self.incomingExternalLinks = model
        }
        
        if requestIdsInProgress.count == 0 {
            self.publishScreenLoadTime(withName: self.getScreenName(), withLabel: "")
            self.categories = self.incomingCategories
            self.externalLinks = self.incomingExternalLinks
            self.internalLinks = self.incomingInternalLinks

            self.loadContentCompletion?(true)
            self.updateSectionTypes()
            
            ThreadManager.execute(onMainThread: {
                self.tableview.reloadData()
            })
        }
    }
    
    private func updateSectionTypes() {
        if let _ = self.categories {
            self.sectionTypes[self.sectionTypes.keys.count] = Categories.self
        }
        if let linkItems = self.internalLinks?.items, linkItems.count > 0 {
            self.sectionTypes[self.sectionTypes.keys.count] = InternalLinks.self
        }
        if let linkItems = self.externalLinks?.items, linkItems.count > 0 {
            self.sectionTypes[self.sectionTypes.keys.count] = ExternalLinks.self
        }
    }
    
    func errorHandler(_ error: Error!, forRequestID rid: Int32) {
        if !Utility.handleErrorMessages(error: error, viewController: self) {
            self.handleGenericErrorCodesWithErrorControlView(Int32(error.code), forRequestID: 0)
        }
    }
    
    func retryAction(_ callBack: RetryHandler!, forRequestId rid: Int32) {
        self.loadContent { (success) in
            callBack(success)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let segueName = segue.identifier
        if segueName == "showsubCategories", let subCatViewController = segue.destination as? SubCategoryLandingPageViewController, let selectedCategory = sender as? CategoryProduct, let rootCatgory = self.categories?.tree?[0] {
            subCatViewController.subcategories = selectedCategory.childern
            subCatViewController.historyCategory = [rootCatgory, selectedCategory]
        } else if segueName == "ShowSearchView", let searchViewController = segue.destination as? SearchViewController {
            searchViewController.parentScreenName = self.getScreenName()
        }
    }
    
    //MARK: - DataTrackerProtocol
    override func getScreenName() -> String! {
        return "Categories"
    }
    
    //MARK - NavigationBarProtocol
    override func navBarTitleString() -> String! {
        return STRING_CATEGORIES
    }
}
