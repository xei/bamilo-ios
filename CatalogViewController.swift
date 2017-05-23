//
//  CatalogViewController.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 5/9/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

import UIKit
import EmarsysPredictSDK

@objc class CatalogViewController: BaseViewController,
                                    DataServiceProtocol,
                                    JAFiltersViewControllerDelegate,
                                    CatalogHeaderViewDelegate,
                                    UICollectionViewDataSource,
                                    UICollectionViewDelegate,
                                    EmarsysWebExtendProtocol {
    
    @IBOutlet private weak var catalogHeader: CatalogHeaderControl!
    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var noResultViewContainer: UIView!
    
    var searchTarget: RITarget!
    var sortingMethod: Catalog.CatalogSortType = .populaity
    var pushFilterQueryString : String?
    private var activeFilters : [CatalogFilterItem]?
    private var activePriceFilter: CatalogPriceFilterItem?
    private var listViewType: CatalogListViewType = .grid
    private var listFullyLoaded = false
    
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
    private var loadingDataInProgress = false
    
    
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
    }
    
    override func updateNavBar() {
        super.updateNavBar()
        self.navBarLayout.showBackButton = true
        if let navTitle = self.catalogData?.title {
            self.navBarLayout.title = navTitle
            self.requestNavigationBarReload()
        }
    }
    
    
    //MARK - DataServiceProtocol
    func bind(_ data: Any!, forRequestId rid: Int32) {
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
    
    //MARK - JAFiltersViewControllerDelegate
    func updatedFilters(_ updatedFiltersArray: [Any]!) {
        self.catalogData?.filters = updatedFiltersArray as? [BaseCatalogFilterItem]
        self.findActiveFilters()
        self.pushToSearchByFilterQuery(query: self.getQueryOfActiveFilters())
    }
    
    func subCategorySelected(_ subCategoryUrlKey: String!) {
        self.pushToSearchByCateory(catalogUrl: subCategoryUrlKey)
    }
    
    
    //MARK - CatalogHeaderViewDelegate
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
    
    
    
    //MARK - helpers 
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
    
    private func getQueryOfActiveFilters() -> String {
        var filterQuery = ""
        let filtersToString = self.activeFilters?.map({ (filterItem) -> String in
            return filterItem.id + "/" + (filterItem.options?.filter { $0.selected }.map { $0.value! }.joined(separator: filterItem.filterSeparator!))!
        }).joined(separator: "/")
        if let activeFilterQuery = filtersToString {
            filterQuery = activeFilterQuery + "/"
        }
        
        if let priceFilter = self.activePriceFilter, priceFilter.lowerValue != priceFilter.minPrice || priceFilter.upperValue != priceFilter.maxPrice {
            filterQuery += String(priceFilter.lowerValue) + "/"
        }
        return filterQuery
    }
    
    private func processCatalogData() {
        self.updateNavBar()
        
        if self.catalogData == nil || self.catalogData?.products.count == 0 {
            self.showNoResultView()
        }
        
        //Sequence of these functions are important
        self.sortingMethod = self.catalogData?.sortType ?? .populaity
        self.setSortingMethodToHeader()
        self.findActiveFilters()
        self.setActiveFiltersToHeader()
    }
    
    private func showNoResultView() {
        if let _ = self.pushFilterQueryString {
            
        } else {
            if self.searchTarget.type.contains("catalog_") {
                self.noResultViewController?.searchQuery = self.searchTarget.node
            }
            self.noResultViewController?.getSuggestions()
            self.noResultViewContainer.isHidden = false
        }
    }
    
    private func findActiveFilters() {
        self.activeFilters = self.catalogData?.filters?.filter({ (filterItem) -> Bool in
            let activeFilterOptions = (filterItem as? CatalogFilterItem)?.options?.filter({ (filterOption) -> Bool in
                return filterOption.selected
            })
            return activeFilterOptions != nil ?  activeFilterOptions!.count > 0 : false
        }) as? [CatalogFilterItem]
        
        if let index = self.catalogData?.priceFilterIndex, let priceFilter = self.catalogData?.filters?[index] as? CatalogPriceFilterItem, priceFilter.lowerValue != 0 || priceFilter.upperValue != priceFilter.maxPrice {
            self.activePriceFilter = priceFilter
        } else {
            self.activePriceFilter = nil
        }
    }
    
    private func setActiveFiltersToHeader() {
        
        if let avaiebleFilters = self.catalogData?.filters, avaiebleFilters.count > 0 {
            self.catalogHeader.enableFilterButton(enable: true)
        }
        
        var activeFilterString = ""
        if let filters = self.activeFilters, filters.count > 0 {
             activeFilterString = filters.map { (filter) -> String in
                return filter.name
                }.joined(separator: "، ");
        }
        if let _ = self.activePriceFilter {
            activeFilterString += activeFilterString.characters.count > 0 ? "، \(STRING_PRICE)" : "\(STRING_PRICE)"
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
        CatalogDataManager.sharedInstance().getCatalog(target: self, searchTarget: searchTarget, filtersQueryString: pushFilterQueryString, sortingMethod: sortingMethod) { (data, errorMessages) in
            if errorMessages == nil {
                self.bind(data, forRequestId: 0)
            } else {
                self.showNoResultView()
            }
        }
    }
    
    private func loadMore() {
        if self.loadingDataInProgress || self.listFullyLoaded { return }
        self.pageNumber += 1
        self.loadingDataInProgress = true
        CatalogDataManager.sharedInstance().getCatalog(target: self, searchTarget: searchTarget, filtersQueryString: pushFilterQueryString, sortingMethod: sortingMethod, page: self.pageNumber) { (data, errorMessages) in
            self.loadingDataInProgress = false
            self.bind(data, forRequestId: 1)
        }
    }
    
    private func showProductPage(product: Product) {
        //TODO: transition from this controller to pdvViewController must not handle by notification!
        NotificationCenter.default.post(name: NSNotification.Name("NOTIFICATION_DID_SELECT_TEASER_WITH_PDV_URL"), object: nil, userInfo: ["sku": product.sku])
    }
    
    
    //MARK - UICollectionViewDataSource & UICollectionViewDelegate
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
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    
    //MARK - prepareForSegue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let segueName = segue.identifier
        if segueName == "embedCatalogNoResult", let noResultViewCtrl = segue.destination as? CatalogNoResultViewController {
            self.noResultViewController = noResultViewCtrl
        }
        
        if segueName == "showFilterView" {
            let destinationViewCtrl = segue.destination as? JAFiltersViewController
            destinationViewCtrl?.filtersArray = self.catalogData?.filters ?? []
            destinationViewCtrl?.subCatsFilter = subCategoryFilterItem
            if let index = self.catalogData?.priceFilterIndex {
                destinationViewCtrl?.priceFilterIndex = Int32(index);
            }
            destinationViewCtrl?.delegate = self;
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
