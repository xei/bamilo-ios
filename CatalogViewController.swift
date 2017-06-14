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
                                    JAPDVViewControllerDelegate {
    
    @IBOutlet private weak var catalogHeader: CatalogHeaderControl!
    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var noResultViewContainer: UIView!
    @IBOutlet private weak var filteredNoResultContainer: UIView!
    
    var searchTarget: RITarget!
    var sortingMethod: Catalog.CatalogSortType = .populaity
    var pushFilterQueryString : String?
    var startCatalogStackIndexInNavigationViewController: Int?
    
    private var selectedProduct: Product? //TODO: it's not necessary to keep it, but we should do it for now because
                                          // we need to know which product (may) has been changed by PDVViewController (add to wish list)
    
    
    private var listViewType: CatalogListViewType = .grid
    private var listFullyLoaded = false
    private var lastContentOffset: CGFloat = 0
    
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
    private let paginationCellCountThreshold = 6
    private var loadingDataInProgress = true {
        didSet {
            //To refresh the footerView
            self.collectionView.collectionViewLayout.invalidateLayout()
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = Theme.color(kColorVeryLightGray)
    
        self.catalogHeader.delegate = self
        self.setSortingMethodToHeader()
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.register(UINib(nibName: CatalogListCollectionViewCell.nibName, bundle: nil), forCellWithReuseIdentifier: CatalogListCollectionViewCell.nibName)
        self.collectionView.register(UINib(nibName: CatalogCardCollectionViewCell.nibName, bundle: nil), forCellWithReuseIdentifier: CatalogCardCollectionViewCell.nibName)
        self.collectionView.register(UINib(nibName: CatalogGridCollectionViewCell.nibName, bundle: nil), forCellWithReuseIdentifier: CatalogGridCollectionViewCell.nibName)
        self.collectionView.setCollectionViewLayout(self.getProperCollectionViewFlowLayout(), animated: true)
        self.loadData()
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateListWithUserLoginNotification(notification:)), name: NSNotification.Name("NOTIFICATION_USER_LOGGED_IN"), object: nil)
    }
    
    deinit {
        //remove all observers for this view controller when it's deinitliazed
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //To reset the tab bar state
        changeTabBar(hidden: false, animated: false)
    }
    
    override func updateNavBar() {
        super.updateNavBar()
        self.navBarLayout.showBackButton = true
        if let navTitle = self.catalogData?.title {
            self.navBarLayout.title = navTitle
            self.requestNavigationBarReload()
        }
    }
    
    
    //MARK: - DataServiceProtocol
    func bind(_ data: Any!, forRequestId rid: Int32) {
        self.loadingDataInProgress = false
        if let receivedCatalogData = data as? Catalog {
            if rid == 0 {
                self.catalogData = receivedCatalogData
                self.processCatalogData()
                EmarsysPredictManager.sendTransactions(of: self)
            } else if rid == 1, receivedCatalogData.products.count > 0 {
                self.catalogData?.products.append(contentsOf: receivedCatalogData.products)
            }
            if let totalProducts = receivedCatalogData.totalProductsCount, totalProducts <= receivedCatalogData.products.count {
                self.listFullyLoaded = true
            }
            self.collectionView.reloadData()
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
        
        if let startIndex = self.startCatalogStackIndexInNavigationViewController, queryFilters.characters.count == 0 {
            if let arrayOfViewControllers = self.navigationController?.viewControllers {
                self.navigationController?.popToViewController(arrayOfViewControllers[startIndex], animated: false)
            }
        } else if queryFilters != self.pushFilterQueryString && queryFilters.characters.count != 0 {
            self.pushToSearchByFilterQuery(query: queryFilters)
        }
    }
    
    
    func subCategorySelected(_ subCategoryUrlKey: String!) {
        self.pushToSearchByCateory(catalogUrl: subCategoryUrlKey)
    }
    
    
    //MARK: - CatalogHeaderViewDelegate
    func sortTypeSelected(type: Catalog.CatalogSortType) {
        self.sortingMethod = type
        self.loadData()
    }
    
    func filterButtonTapped() {
        if let _ = self.catalogData?.filters {
            self.performSegue(withIdentifier: "showFilterView", sender: nil)
        }
    }
    
    func changeListViewType(type: CatalogListViewType) {
        self.listViewType = type
        self.collectionView.reloadData()
        UIView.animate(withDuration: 0.15, animations: { 
            self.collectionView.collectionViewLayout.invalidateLayout()
            self.collectionView.setCollectionViewLayout(self.getProperCollectionViewFlowLayout(), animated: true)
        }, completion: nil)
    }
    
    
    
    //MARK: - helpers 
    private func setSortingMethodToHeader() {
        if self.sortingMethod != .populaity {
            self.catalogHeader.setSortingType(type: self.sortingMethod)
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
    private func getProperCollectionViewFlowLayout () -> UICollectionViewFlowLayout {
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
                    if (priceQuery.characters.count > 0) {
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
        
        if filtersToString.characters.count > 0 {
            filterQuery = filtersToString + "/"
        }

        return filterQuery
    }
    
    private func processCatalogData() {
        self.updateNavBar()
        
        if self.catalogData == nil || self.catalogData?.products.count == 0 {
            self.showNoResultView()
            return
        }
        
        //Sequence of these functions are important
        self.sortingMethod = self.catalogData?.sortType ?? .populaity
        self.setSortingMethodToHeader()
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
            self.catalogData?.products.filter({ (product) -> Bool in
                return wishlistSkuArray.contains(product.sku)
            }).forEach({ (product) in
                product.isInWishList = true
            })
        }
        self.collectionView.reloadData()
    }
    
    //TODO: this code can be in BaseViewController
    private var isChangingTabBar = false
    private func changeTabBar(hidden:Bool, animated: Bool){
        if let tabBar = self.tabBarController?.tabBar {
            if tabBar.isHidden == hidden || self.isChangingTabBar { return }
            self.isChangingTabBar = true
            let frame = tabBar.frame
            let offset = (hidden ? (frame.size.height) : -(frame.size.height))
            tabBar.isHidden = false
            
            UIView.animate(withDuration: 0.15, animations: {
                tabBar.frame = frame.offsetBy(dx: 0, dy: offset)
                self.view.layoutIfNeeded()
            }, completion: {
                if $0 {tabBar.isHidden = hidden}
                self.isChangingTabBar = false
            })
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
        if activeFilterString.characters.count > 0 {
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
    
    private func loadData() {
        self.pageNumber = 1
        CatalogDataManager.sharedInstance.getCatalog(self, searchTarget: searchTarget, filtersQueryString: pushFilterQueryString, sortingMethod: sortingMethod) { (data, errorMessages) in
            if errorMessages == nil {
                self.bind(data, forRequestId: 0)
            } else {
                self.showNoResultView()
            }
        }
        self.loadAvaiableSubCategories()
    }
    
    func loadAvaiableSubCategories() {
        //TODO: type of Target must be enum not string (the enum of RITarget can not be reusded in swift)
        if self.searchTarget.type == "catalog_category" {
            CatalogDataManager.sharedInstance.getSubCategoriesFilter(self, categoryUrlKey: self.searchTarget.node, completion: { (data, errorMessages) in
                self.subCategoryFilterItem = data as? CatalogCategoryFilterItem
            })
        }
    }
    
    private func loadMore() {
        if self.loadingDataInProgress || self.listFullyLoaded { return }
        self.pageNumber += 1
        self.loadingDataInProgress = true
        CatalogDataManager.sharedInstance.getCatalog(self, searchTarget: searchTarget, filtersQueryString: pushFilterQueryString, sortingMethod: sortingMethod, page: self.pageNumber) { (data, errorMessages) in
            self.bind(data, forRequestId: 1)
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
        cell.updateWithProduct(product: self.catalogData!.products[indexPath.row])
        cell.cellIndex = indexPath.row
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let catalog = self.catalogData, catalog.products.count - indexPath.row < paginationCellCountThreshold {
            self.loadMore()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (self.catalogData != nil) ? self.catalogData!.products.count : 0
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
            let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionFooter, withReuseIdentifier: "FooterView", for: indexPath)
            return footerView
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize(width: self.collectionView.frame.width, height: self.loadingDataInProgress ? 50 : 0)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if self.lastContentOffset - 10 > scrollView.contentOffset.y {
            //scroll to top
            changeTabBar(hidden: false, animated: true)
        } else if self.lastContentOffset < scrollView.contentOffset.y {
            //scroll to bottom
            changeTabBar(hidden: true, animated: true)
        }
        
        self.lastContentOffset = scrollView.contentOffset.y;
    }
    
    //MARK: - JAPDVViewControllerDelegate
    func add(toWishList sku: String!, add: Bool) {
        self.selectedProduct?.isInWishList = add
        self.collectionView.reloadData()
    }
    
    //MARK: - BaseCatallogCollectionViewCellDelegate
    func addOrRemoveFromWishList(product: Product, cell: BaseCatallogCollectionViewCell, add: Bool) {
        (self.navigationController as? JACenterNavigationController)?.performProtectedBlock({ (userHadSession) in
            ProductDataManager.sharedInstance().wishListTransaction(isAdd: add, target: self, sku: product.sku) { (data, error) in
                guard error != nil else {
                    product.isInWishList.toggle()
                    cell.updateWithProduct(product: product)
                    return
                }
                
                if let error = error, let errorMessage = ((error as NSError).userInfo["errorMessages"] as? [String])?[0] {
                    self.showNotificationBarMessage(errorMessage, isSuccess: false)
                }
            }
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
            destinationViewCtrl?.productSku = self.selectedProduct?.sku
            destinationViewCtrl?.delegate = self
        }
        
    }
    
    //MARK: - EmarsysWebExtendProtocol
    func getDataCollection(_ transaction: EMTransaction!) -> EMTransaction! {
        if self.searchTarget.type == "catalog_query" {
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
}
