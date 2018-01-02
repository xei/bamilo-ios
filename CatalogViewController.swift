//
//  CatalogViewController.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 5/9/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

import UIKit
import EmarsysPredictSDK
import SwiftyJSON

@objc class CatalogViewController: BaseViewController,
                                    DataServiceProtocol,
                                    JAFiltersViewControllerDelegate,
                                    CatalogHeaderViewDelegate,
                                    BaseCatallogCollectionViewCellDelegate,
                                    UICollectionViewDataSource,
                                    UICollectionViewDelegate,
                                    EmarsysWebExtendProtocol,
                                    UICollectionViewDelegateFlowLayout,
                                    FilteredListNoResultViewControllerDelegate,
                                    JAPDVViewControllerDelegate,
                                    SearchViewControllerDelegate,
                                    BreadcrumbsViewDelegate {
    
    @IBOutlet private weak var catalogHeaderContainer: UIView!
    @IBOutlet private weak var catalogHeaderContainerHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var catalogHeader: CatalogHeaderControl!
    @IBOutlet weak private var breadCrumbsControl: BreadcrumbsControl!
    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var noResultViewContainer: UIView!
    @IBOutlet private weak var filteredNoResultContainer: UIView!
    @IBOutlet private weak var productCountLabel: UILabel!
    @IBOutlet private weak var productCountLabelHeight: NSLayoutConstraint!
    @IBOutlet private weak var productCountLabelTopConstraint: NSLayoutConstraint!
    @IBOutlet private weak var topCollectionViewConstraint: NSLayoutConstraint!
    
    var navBarTitle: String?
    var searchTarget: RITarget!
    var sortingMethod: Catalog.CatalogSortType? = nil
    var pushFilterQueryString : String?
    var startCatalogStackIndexInNavigationViewController: Int?
    var purchaseTrackingInfo: String? //For tracking teaser (purchase) journeys (optional)
    
    private var selectedProduct: Product? //TODO: it's not necessary to keep it, but we should do it for now because
                                          // we need to know which product (may) has been changed by PDVViewController (add to wish list)
    
    private var allSubviewsHasBeenRendered = false
    private var navBarBlurView: UIVisualEffectView?
    private var listViewType: CatalogListViewType = .grid
    private var listFullyLoaded = false
    private var initialNavBarAndStatusBarHeight: CGFloat!
    private var initialTabBarHeight: CGFloat!
    private let loadingFooterViewHeight: CGFloat = 50
    private let productCountViewHeight: CGFloat = 30
    private let catalogHeaderContainerHeightWithBreadcrumb:CGFloat = 96
    private let catalogHeaderContainerHeightWithoutBreadcrumb:CGFloat = 48
    private let cardViewNewTagElementHeight: CGFloat = 16
    private var navBarScrollFollower: ScrollerBarFollower?
    private var tabBarScrollFollower: ScrollerBarFollower?
    private var searchBarScrollFollower: ScrollerBarFollower?
    
    
    //TODO: this property is only used for passing enum (swift type) property from objective c
    // so we have to remove it after migration those who wanna pass this property
    var sortingMethodString: String? {
        didSet {
            if let sortString = sortingMethodString, let sortingMethod = Catalog.CatalogSortType(rawValue: sortString) {
                self.sortingMethod = sortingMethod
            }
        }
    }
    
    private var subCategoryFilterItem: CatalogCategoryFilterItem?
    private var pageNumber: Int = 1
    private var catalogData: Catalog?
    private var noResultViewController: CatalogNoResultViewController?
    private let paginationThresholdPoint: CGFloat = 100
    private var loadingDataInProgress = true {
        didSet {
            //To refresh the footerView
            self.collectionView.collectionViewLayout.invalidateLayout()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = Theme.color(kColorVeryLightGray)
        self.catalogHeaderContainerHeightConstraint.constant = self.catalogHeaderContainerHeightWithoutBreadcrumb
        self.productCountLabel.applyStype(font: Theme.font(kFontVariationRegular, size: 11), color: UIColor.black)
        
        if let savedListViewType = UserDefaults.standard.string(forKey: "CatalogListViewType") {
            self.listViewType = CatalogListViewType(rawValue: savedListViewType) ?? .grid
            self.catalogHeader.headerView?.listViewType = self.listViewType
        }
        
        self.breadCrumbsControl.delegate = self
        self.catalogHeader.delegate = self
        self.setSortingMethodToHeader()
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.register(CatalogListCollectionViewCell.nibInstance, forCellWithReuseIdentifier: CatalogListCollectionViewCell.nibName)
        self.collectionView.register(CatalogCardCollectionViewCell.nibInstance, forCellWithReuseIdentifier: CatalogCardCollectionViewCell.nibName)
        self.collectionView.register(CatalogGridCollectionViewCell.nibInstance, forCellWithReuseIdentifier: CatalogGridCollectionViewCell.nibName)
        self.collectionView.setCollectionViewLayout(self.getProperCollectionViewFlowLayout(), animated: true)
        self.loadData()
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateListWithUserLoginNotification(notification:)), name: NSNotification.Name(NotificationKeys.UserLogin), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateProductStatusFromWishList(notification:)), name: NSNotification.Name(NotificationKeys.WishListUpdate), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(resetBarFollowers(animated:)), name: NSNotification.Name(NotificationKeys.EnterForground), object: true)
        
        if let navBar = self.navigationController?.navigationBar {
            self.initialNavBarAndStatusBarHeight = navBar.frame.height + UIApplication.shared.statusBarFrame.height
            
            self.topCollectionViewConstraint.constant = navBar.frame.height-(self.navigationController?.navigationBar.frame.size.height ?? navBar.frame.height)
        }
        
        if let tabBar = self.tabBarController?.tabBar {
            self.initialTabBarHeight = tabBar.frame.height
        }
        self.productCountLabelHeight.constant = self.productCountViewHeight
    }
    
    deinit {
        //remove all observers for this view controller when it's deinitliazed
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let navTitle = self.navBarTitle {
            self.title = navTitle
        }
        
        self.navBarScrollFollower?.resumeFollowing()
        self.tabBarScrollFollower?.resumeFollowing()
        self.searchBarScrollFollower?.resumeFollowing()
        
        self.navBarBlurView = self.navigationController?.navigationBar.addBlurView()
        self.navBarBlurView?.alpha = 0
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if  !allSubviewsHasBeenRendered {
            //asign scroll followers in this view
            self.catalogHeaderContainer.translatesAutoresizingMaskIntoConstraints = true
            self.searchBarScrollFollower = ScrollerBarFollower(barView: catalogHeaderContainer, moveDirection: .top)
            if let navBar = self.navigationController?.navigationBar {
                self.navBarScrollFollower = ScrollerBarFollower(barView: navBar, moveDirection: .top)
                self.navBarScrollFollower?.followScrollView(scrollView: collectionView, delay: productCountViewHeight, permittedMoveDistance: navBar.frame.height)
                self.searchBarScrollFollower?.followScrollView(scrollView: collectionView, delay: productCountViewHeight, permittedMoveDistance: navBar.frame.height)
            }
            if let tabBar = self.tabBarController?.tabBar {
                self.tabBarScrollFollower = ScrollerBarFollower(barView: tabBar, moveDirection: .down)
                self.tabBarScrollFollower?.followScrollView(scrollView: self.collectionView, delay: productCountViewHeight, permittedMoveDistance: tabBar.frame.height)
            }
            
            self.allSubviewsHasBeenRendered = true
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        //reset all states of tabbar and navBar, status bar
        self.resetBarFollowers(animated:true)
        
        self.navBarScrollFollower?.pauseFollowing()
        self.tabBarScrollFollower?.pauseFollowing()
        self.searchBarScrollFollower?.pauseFollowing()
        
        self.setNavigationBarAlpha(alpha: 0, animated: true)
        self.navBarBlurView?.removeFromSuperview()
        self.collectionView.killScroll()
    }
    
    private func refreshBarFollower() {
        self.navBarScrollFollower?.refreshForFrameSize()
        self.tabBarScrollFollower?.refreshForFrameSize()
        self.searchBarScrollFollower?.refreshForFrameSize()
    }
    
    @objc private func resetBarFollowers(animated: Bool) {
        self.navBarScrollFollower?.resetBarFrame(animated: animated)
        self.tabBarScrollFollower?.resetBarFrame(animated: animated)
        self.searchBarScrollFollower?.resetBarFrame(animated: animated)
    }
    
    func updateNavBar() {
        if let navTitle = self.catalogData?.title {
            self.navBarTitle = navTitle
            self.title = navTitle
        }
    }
    
    //MARK: - DataServiceProtocol
    func bind(_ data: Any!, forRequestId rid: Int32) {
        ThreadManager.execute(onMainThread: {
            if let receivedCatalogData = data as? Catalog {
                if rid == 0 {
                    self.catalogData = receivedCatalogData
                    self.processCatalogData()
                    EmarsysPredictManager.sendTransactions(of: self)
                    self.collectionView.reloadData()
                    if let receivedCatalogData = data as? Catalog, let totalProducts = receivedCatalogData.totalProductsCount {
                        if totalProducts <= receivedCatalogData.products.count {
                            self.listFullyLoaded = true
                        }
                        self.productCountLabel.text = "\(totalProducts) \(STRING_FOUND_PRODUCT_COUNT)".convertTo(language: .arabic)
                    }
                    self.loadingDataInProgress = false
                    if let breadcrumb = self.catalogData?.breadcrumbs, false { //for now
                        UIView.animate(withDuration: 0.15, animations: {
                            self.catalogHeaderContainerHeightConstraint.constant = self.catalogHeaderContainerHeightWithBreadcrumb
                        }, completion: { (finished) in
                            self.refreshBarFollower()
                            if let navBar = self.navigationController?.navigationBar {
                                self.searchBarScrollFollower?.distance = navBar.frame.height + self.catalogHeaderContainerHeightWithoutBreadcrumb
                            }
                            self.breadCrumbsControl.update(withModel: breadcrumb)
                            self.productCountLabelTopConstraint.constant = self.catalogHeaderContainer.frame.height
                        })
                    } else {
                        UIView.animate(withDuration: 0.15, animations: {
                            self.catalogHeaderContainerHeightConstraint.constant = self.catalogHeaderContainerHeightWithoutBreadcrumb
                        }, completion: { (finished) in
                            self.refreshBarFollower()
                            self.productCountLabelTopConstraint.constant = self.catalogHeaderContainer.frame.height
                        })
                    }
                } else if rid == 1, receivedCatalogData.products.count > 0 {
                    if let visibleProductCount = self.catalogData?.products.count {
                        var newIndexPathes = [IndexPath]()
                        for index in 0...receivedCatalogData.products.count - 1 {
                            let newIndex = visibleProductCount + index
                            newIndexPathes.append(IndexPath(item: newIndex, section: 0))
                            self.catalogData?.products.insert(receivedCatalogData.products[index], at: newIndex)
                        }
                        
                        if let totalProducts = receivedCatalogData.totalProductsCount, let updateVisibleProductCount = self.catalogData?.products.count, totalProducts <= updateVisibleProductCount {
                            self.listFullyLoaded = true
                        }
                        
                        self.collectionView.performBatchUpdates({
                            self.collectionView.insertItems(at: newIndexPathes)
                        }, completion: {(finished) in
                            self.loadingDataInProgress = false
                        })
                    }
                }
            }

        })
    }
    
    func retryAction(_ callBack: RetryHandler!, forRequestId rid: Int32) {
        if rid == 0 {
            self.loadData { (success) in
                callBack(success)
            }
        }
    }
    
    func errorHandler(_ error: Error!, forRequestID rid: Int32) {
        if rid == 0 {
            if error.code != 200 {
                self.handleGenericErrorCodesWithErrorControlView(Int32(error.code), forRequestID: rid)
            } else {
                self.showNoResultView()
            }
        } else if rid == 1 {
//            if !Utility.handleErrorMessages(error: error, viewController: self) {
//                self.showNotificationBarMessage(STRING_SERVER_ERROR_MESSAGE, isSuccess: false)
//            }
        }
    }
    
    //MARK: - FilteredListNoResultViewControllerDelegate
    func editFilterByNoResultView() {
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: - JAFiltersViewControllerDelegate
    func updatedFilters(_ updatedFiltersArray: [Any]!) {
        let activeFilters = self.findActiveFilters(filters: updatedFiltersArray as? [BaseCatalogFilterItem])
        let queryFilters = self.getQueryOfActiveFilters(activeFilters: activeFilters)
        trackSearchFilter(activeFilterQuery: queryFilters)
        
        if let startIndex = self.startCatalogStackIndexInNavigationViewController, queryFilters.count == 0 {
            if let arrayOfViewControllers = self.navigationController?.viewControllers {
                self.navigationController?.popToViewController(arrayOfViewControllers[startIndex], animated: false)
            }
        } else if queryFilters != self.pushFilterQueryString && queryFilters.count != 0 {
            self.pushToSearchByFilterQuery(query: queryFilters)
        }
    }
    
    func subCategorySelected(_ subCategoryUrlKey: String!) {
        self.pushToSearchByCateory(catalogUrl: subCategoryUrlKey)
    }
    
    //MARK: - CatalogHeaderViewDelegate
    func sortTypeSelected(type: Catalog.CatalogSortType) {
        TrackerManager.postEvent(
            selector: EventSelectors.catalogSortChangedSelector(),
            attributes: EventAttributes.catalogSortChanged(sortMethod: type)
        )
        self.sortingMethod = type
        self.setSortingMethodToHeader()
        self.resetBarFollowers(animated: true)
        self.loadData()
    }
    
    func filterButtonTapped() {
        if let _ = self.catalogData?.filters {
            self.performSegue(withIdentifier: "showFilterView", sender: nil)
        }
    }
    
    func changeListViewType(type: CatalogListViewType) {
        self.listViewType = type
        UserDefaults.standard.set(type.rawValue, forKey: "CatalogListViewType")
        TrackerManager.postEvent(
            selector: EventSelectors.catalogViewChangedSelector(),
            attributes: EventAttributes.catalogViewChanged(listViewType: type)
        )
        self.collectionView.reloadData()
        self.resetBarFollowers(animated: true)
        self.collectionView.collectionViewLayout.invalidateLayout()
        self.collectionView.setCollectionViewLayout(self.getProperCollectionViewFlowLayout(), animated: true)
    }
    
    //MARK: - helpers 
    private func setSortingMethodToHeader() {
        if self.sortingMethod != nil {
            self.catalogHeader.setSortingType(type: self.sortingMethod ?? .popularity)
        }
    }
    
    private(set) lazy var gridFlowLayout: GridCollectionViewFlowLayout = {
       return GridCollectionViewFlowLayout()
    }()
    private(set) lazy var listFlowLayout: ListCollectionViewFlowLayout = {
        return ListCollectionViewFlowLayout()
    }()
    private(set) lazy var cardFlowLayout: CardCollectionViewFlowLayout = {
        return CardCollectionViewFlowLayout()
    }()
    private func getProperCollectionViewFlowLayout () -> BaseCollectionFlowLayout {
        if self.listViewType == .grid {
            return gridFlowLayout
        } else if self.listViewType == .list {
            return listFlowLayout
        } else  {
            return cardFlowLayout
        }
    }
    
    private func getQueryOfActiveFilters(activeFilters: [BaseCatalogFilterItem]) -> String {
        var filterQuery = ""
        let filtersToString = activeFilters.map({ (filterItem) -> String in
            if let catalogFilter = filterItem as? CatalogFilterItem {
                return catalogFilter.id + "/" + (catalogFilter.options?.filter { $0.selected }.map { $0.value! }.joined(separator: filterItem.filterSeparator!))!
            } else if let priceFilter = filterItem as? CatalogPriceFilterItem {
                var priceQuery = ""
                if (priceFilter.lowerValue != priceFilter.minPrice || priceFilter.upperValue != priceFilter.maxPrice) {
                    priceQuery += "price/\(priceFilter.lowerValue)-\(priceFilter.upperValue)"
                }
                if (priceFilter.discountOnly) {
                    if (priceQuery.count > 0) {
                        priceQuery += "/special_price/1"
                    } else {
                        priceQuery = "special_price/1"
                    }
                }
                return priceQuery
            } else {
                return ""
            }
        }).joined(separator: "/")
        
        if filtersToString.count > 0 {
            filterQuery = filtersToString + "/"
        }
        return filterQuery
    }
    
    private func trackSearchFilter(activeFilterQuery: String) {
        TrackerManager.postEvent(
            selector: EventSelectors.searchFilteredSelector(),
            attributes: EventAttributes.filterSearch(filterQueryString: activeFilterQuery)
        )
    }
    
    private func processCatalogData() {
        self.updateNavBar()
        
        if self.catalogData == nil || self.catalogData?.products.count == 0 {
            self.showNoResultView()
            return
        }
        
        if self.pageNumber == 1 {
            self.trackSearch(searchTarget: self.searchTarget)
        }
        
        //Sequence of these functions are important
        let activeFilters = self.findActiveFilters(filters: self.catalogData?.filters)
        self.setActiveFiltersToHeader(activeFilters: activeFilters)
    }
    
    private func showNoResultView() {
        if let _ = self.pushFilterQueryString {
            self.filteredNoResultContainer.isHidden = false
        } else {
            if self.searchTarget.type.contains("catalog_") {
                self.noResultViewController?.searchQuery = self.searchTarget.node
            }
            self.noResultViewController?.getSuggestions()
            self.noResultViewContainer.isHidden = false
        }
    }
    
    func updateListWithUserLoginNotification(notification: Notification) {
        if let wishlistSkuArray = notification.object as? [String] {
            self.catalogData?.products.forEach({ (product) in
                product.isInWishList = wishlistSkuArray.contains(product.sku)
            })
        }
        self.collectionView.reloadData()
    }
    
    func updateProductStatusFromWishList(notification: Notification) {
        if let product = notification.userInfo?[NotificationKeys.NotificationProduct] as? Product ,let isInWishlist = notification.userInfo?[NotificationKeys.NotificationBool] as? Bool {
            let targetProduct = self.catalogData?.products.filter { $0.sku == product.sku }.first
            if let targetProduct = targetProduct {
                targetProduct.isInWishList = isInWishlist
                if let index = self.catalogData?.products.index(of: targetProduct) {
                    self.collectionView.reloadItems(at: [IndexPath(row: index, section: 0)])
                }
            }
        }
    }
    
    private func setNavigationBarAlpha(alpha: CGFloat, animated: Bool) {
        let navigationBackgroundView = self.navBarBlurView
        if animated {
            UIView.animate(withDuration: 0.15, animations: {
                navigationBackgroundView?.alpha = alpha
                navigationBackgroundView?.layoutIfNeeded()
            }, completion: nil)
        } else {
            navigationBackgroundView?.alpha = alpha
        }
    }
    
    private func findActiveFilters(filters: [BaseCatalogFilterItem]?) -> [BaseCatalogFilterItem] {
        return  filters?.filter({ (filterItem) -> Bool in
            if let catalogFilter = filterItem as? CatalogFilterItem {
                let activeFilterOptions = catalogFilter.options?.filter({ (filterOption) -> Bool in
                    return filterOption.selected
                })
                return activeFilterOptions != nil ?  activeFilterOptions!.count > 0 : false
            } else if let priceFilter = filterItem as? CatalogPriceFilterItem,
                priceFilter.lowerValue != 0 || priceFilter.upperValue != priceFilter.maxPrice || priceFilter.discountOnly {
                return true
            } else {
                return false
            }
        }) ?? []
    }
    
    private func setActiveFiltersToHeader(activeFilters: [BaseCatalogFilterItem]?) {
        if let avaiebleFilters = self.catalogData?.filters, avaiebleFilters.count > 0 {
            self.catalogHeader.enableFilterButton(enable: true)
        } else {
            self.catalogHeader.enableFilterButton(enable: false)
        }
        
        var activeFilterString = ""
        if let filters = activeFilters, filters.count > 0 {
             activeFilterString = filters.map { (filter) -> String in
                return filter.name
                }.joined(separator: "، ");
        }
        if activeFilterString.count > 0 {
            self.catalogHeader.setFilterDescription(filterDescription: activeFilterString)
            self.catalogHeader.setFilterButtonActive()
        }
    }
    
    private func resetAndClear() {
        self.pageNumber = 0
        self.catalogData = nil
    }
    
    private func pushToSearchByFilterQuery(query: String) {
        let newCatalogViewController = ViewControllerManager.sharedInstance().loadViewController("catalogViewController") as! CatalogViewController
        newCatalogViewController.searchTarget = self.searchTarget
        newCatalogViewController.sortingMethod = self.sortingMethod
        newCatalogViewController.startCatalogStackIndexInNavigationViewController = self.startCatalogStackIndexInNavigationViewController ?? self.navigationController!.viewControllers.count - 1
        newCatalogViewController.pushFilterQueryString = query
        self.navigationController?.pushViewController(newCatalogViewController, animated: true)
    }
    
    private func pushToSearchByCateory(catalogUrl: String) {
        let newCatalogViewController = ViewControllerManager.sharedInstance().loadViewController("catalogViewController") as! CatalogViewController
        //TODO: if we redefined the Target in swift with better structure these type of code must be changed e.g. not proper initlizer for RITarget
        newCatalogViewController.searchTarget = RITarget.parseTarget("catalog_category::\(catalogUrl)")
        self.navigationController?.pushViewController(newCatalogViewController, animated: true)
    }
    
    private func loadData(callBack: ((Bool)->Void)? = nil) {
        self.pageNumber = 1
        CatalogDataManager.sharedInstance.getCatalog(self, searchTarget: searchTarget, filtersQueryString: pushFilterQueryString, sortingMethod: sortingMethod) { (data, errorMessages) in
            if let error = errorMessages {
                self.errorHandler(error, forRequestID: 0)
                callBack?(false)
            } else {
                self.bind(data, forRequestId: 0)
                callBack?(true)
            }
            self.resetBarFollowers(animated: true)
        }
        self.loadAvaiableSubCategories()
    }
    
    private func trackSearch(searchTarget: RITarget) {
        TrackerManager.postEvent(
            selector: EventSelectors.searchActionSelector(),
            attributes: EventAttributes.searchAction(searchTarget: searchTarget)
        )
    }
    
    func loadAvaiableSubCategories() {
        if self.searchTarget.targetType == .CATALOG_CATEGORY {
            CatalogDataManager.sharedInstance.getSubCategoriesFilter(self, categoryUrlKey: self.searchTarget.node, completion: { (data, errorMessages) in
                if errorMessages == nil {
                    self.subCategoryFilterItem = data as? CatalogCategoryFilterItem
                } else {
//                    Utility.handleError(error: errorMessages, viewController: self)
                }
            })
        }
    }
    
    private func loadMore() {
        if self.loadingDataInProgress || self.listFullyLoaded { return }
        self.pageNumber += 1
        self.loadingDataInProgress = true
        CatalogDataManager.sharedInstance.getCatalog(self, searchTarget: searchTarget, filtersQueryString: pushFilterQueryString, sortingMethod: sortingMethod, page: self.pageNumber) { (data, errorMessages) in
            if errorMessages == nil {
                self.bind(data, forRequestId: 1)
            } else {
                self.loadingDataInProgress = false
                self.errorHandler(errorMessages, forRequestID: 1)
            }
        }
    }
    
    private func showProductPage(product: Product) {
        self.selectedProduct = product
        self.performSegue(withIdentifier: "pushPDVViewController", sender: nil)
    }
    
    //MARK: - UICollectionViewDataSource & UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        if let product = self.catalogData?.products[indexPath.row] {
            self.showProductPage(product: product)
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(self.catalogHeaderContainer.frame.height + self.productCountViewHeight , 0, 0, 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell: BaseCatallogCollectionViewCell!
        if self.listViewType == .grid {
            cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: CatalogGridCollectionViewCell.nibName, for: indexPath) as! CatalogGridCollectionViewCell
        } else if self.listViewType == .list {
            cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: CatalogListCollectionViewCell.nibName, for: indexPath) as! CatalogListCollectionViewCell
        } else {
            cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: CatalogCardCollectionViewCell.nibName, for: indexPath) as! CatalogCardCollectionViewCell
        }
        cell.delegate = self
        if let products = self.catalogData?.products, indexPath.row < products.count {
            cell.updateWithProduct(product: products[indexPath.row])
        }
        cell.cellIndex = indexPath.row
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.catalogData?.products.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionFooter, withReuseIdentifier: "FooterView", for: indexPath)
        return footerView
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize(width: self.collectionView.frame.width, height: self.loadingDataInProgress ? loadingFooterViewHeight : 0)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if (self.listViewType == .card && self.catalogData!.products[indexPath.row].isNew) {
            let normalCellSize = self.getProperCollectionViewFlowLayout().itemSize
            return CGSize(width: normalCellSize.width, height: normalCellSize.height + cardViewNewTagElementHeight)
        } else {
            return self.getProperCollectionViewFlowLayout().itemSize
        }
    }
    
    //MARK: -ScrollViewDelegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.navBarScrollFollower?.scrollViewDidScroll(scrollView)
        self.tabBarScrollFollower?.scrollViewDidScroll(scrollView)
        self.searchBarScrollFollower?.scrollViewDidScroll(scrollView)
        
        let bottomEdge = scrollView.contentOffset.y + scrollView.frame.size.height
        if (bottomEdge >= (scrollView.contentSize.height - paginationThresholdPoint)) {
            // we are approaching at the end of scrollview
            if !self.listFullyLoaded {
                self.loadMore()
            }
        }

        if (scrollView.contentOffset.y < productCountViewHeight) {
            self.setNavigationBarAlpha(alpha: 0, animated: false)
            self.productCountLabel.alpha = 1
            return
        }
        self.productCountLabel.alpha = 0
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        self.navBarScrollFollower?.scrollViewDidEndDragging(scrollView, willDecelerate: decelerate)
        self.searchBarScrollFollower?.scrollViewDidEndDragging(scrollView, willDecelerate: decelerate)
        self.tabBarScrollFollower?.scrollViewDidEndDragging(scrollView, willDecelerate: decelerate)
    }
    
    //MARK: - JAPDVViewControllerDelegate
    func add(toWishList sku: String!, add: Bool) {
        self.selectedProduct?.isInWishList = add
        self.collectionView.reloadData()
    }
    
    //MARK: - BaseCatallogCollectionViewCellDelegate
    func addOrRemoveFromWishList(product: Product, cell: BaseCatallogCollectionViewCell, add: Bool) {
        
        if !RICustomer.checkIfUserIsLogged() {
            product.isInWishList.toggle()
            cell.updateWithProduct(product: product)
        }
        
        (self.navigationController as? JACenterNavigationController)?.performProtectedBlock({ (userHadSession) in
            let translatedProduct = RIProduct()
            translatedProduct.sku = product.sku
            if let price = product.price {
                translatedProduct.price = NSNumber(value: price)
            }
            if add {
                ProductDataManager.sharedInstance.addToWishList(self, sku: product.sku, completion: { (data, error) in
                    if error != nil {
                        product.isInWishList.toggle()
                        cell.updateWithProduct(product: product)
//                        if !Utility.handleErrorMessages(error: error, viewController: self) {
//                            self.showNotificationBarMessage(STRING_SERVER_CONNECTION_ERROR_MESSAGE, isSuccess: false)
//                        }
                        return
                    }
                    if product.isInWishList != true {
                        product.isInWishList.toggle()
                        cell.updateWithProduct(product: product)
                    }
                    self.showNotificationBar(error, isSuccess: false)
                })
                
                TrackerManager.postEvent(
                    selector: EventSelectors.addToWishListSelector(),
                    attributes: EventAttributes.addToWishList(product: translatedProduct, screenName: self.getScreenName(), success: true)
                )
                
            } else {
                DeleteEntityDataManager.sharedInstance().removeFromWishList(self, sku: product.sku, completion: { (data, error) in
                    if error != nil {
                        product.isInWishList.toggle()
                        cell.updateWithProduct(product: product)
//                        if !Utility.handleErrorMessages(error: error, viewController: self) {
//                            self.showNotificationBarMessage(STRING_SERVER_CONNECTION_ERROR_MESSAGE, isSuccess: false)
//                        }
                        TrackerManager.postEvent(
                            selector: EventSelectors.removeFromWishListSelector(),
                            attributes: EventAttributes.removeFromWishList(product: translatedProduct, screenName: self.getScreenName())
                        )
                        return
                    }
                    
                    if product.isInWishList != false {
                        product.isInWishList.toggle()
                        cell.updateWithProduct(product: product)
                    }
                    self.showNotificationBar(error, isSuccess: false)
                })
            }
            
            //Inform others if it's needed
            NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationKeys.WishListUpdate), object: nil, userInfo: [NotificationKeys.NotificationProduct: product, NotificationKeys.NotificationBool: add])
        })
    }
    
    //MARK: - prepareForSegue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let segueName = segue.identifier
        if segueName == "embedCatalogNoResult", let noResultViewCtrl = segue.destination as? CatalogNoResultViewController {
            self.noResultViewController = noResultViewCtrl
        } else if segueName == "showFilterView" {
            let destinationViewCtrl = segue.destination as? JAFiltersViewController
            destinationViewCtrl?.filtersArray = self.catalogData?.copyFilters() //?.filters
            destinationViewCtrl?.subCatsFilter = subCategoryFilterItem
            if let index = self.catalogData?.priceFilterIndex {
                destinationViewCtrl?.priceFilterIndex = Int32(index);
            }
            destinationViewCtrl?.delegate = self;
        } else if segueName == "embedFilteredListNoResult" {
            let destinationViewCtrl = segue.destination as? FilteredListNoResultViewController
            destinationViewCtrl?.delegate = self
        } else if segueName == "pushPDVViewController" {
            let destinationViewCtrl = segue.destination as? JAPDVViewController
            destinationViewCtrl?.purchaseTrackingInfo = self.purchaseTrackingInfo
            destinationViewCtrl?.productSku = self.selectedProduct?.sku
            destinationViewCtrl?.delegate = self
        }
        
    }
    
    //MARK: - BreadcrumbsViewDelegate
    func itemTapped(item: BreadcrumbsItem) {
        if let target = item.target {
            MainTabBarViewController.topNavigationController()?.openTargetString(target, purchaseInfo: nil)
        }
    }
    
    //MARK: - EmarsysWebExtendProtocol
    func getDataCollection(_ transaction: EMTransaction!) -> EMTransaction! {
        if self.searchTarget.targetType == .CATALOG_SEARCH {
            transaction.setSearchTerm(self.searchTarget.node)
        }
        if let breadcrumbsFullPath = self.catalogData?.breadcrumbsFullPath {
            transaction.setCategory(breadcrumbsFullPath)
        }
        
        return transaction
    }
    
    func isPreventSendTransactionInViewWillAppear() -> Bool {
        return true
    }
    
    //MARK: -DataTrackerProtocol
    override func getScreenName() -> String! {
        return "Catalog"
    }
    
    //MARK: -NavigationBarProtocol
    override func navBarTitleString() -> String {
        return STRING_SEARCHING;
    }
    override func navBarleftButton() -> NavBarLeftButtonType {
        return .search
    }
}
