//
//  CatalogViewController.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 5/9/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

import UIKit

@objc class CatalogViewController: BaseViewController,
                                    DataServiceProtocol,
                                    JAFiltersViewControllerDelegate,
                                    CatalogHeaderViewDelegate,
                                    UICollectionViewDataSource,
                                    UICollectionViewDelegate {
    
    @IBOutlet private weak var catalogHeader: CatalogHeaderControl!
    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var noResultViewContainer: UIView!
    
    
    var searchTarget: RITarget!
    var sortingMethod: Catalog.CatalogSortType = .populaity
    var pushFilterQueryString : String?
    var activeFilters : [CatalogFilterItem]?
    var activePriceFilter: CatalogPriceFilterItem?
    private var listViewType: CatalogListViewType = .grid
    
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
        if rid == 0, let catalogData = data as? Catalog {
            self.catalogData = catalogData
            self.processCatalogData()
            
        } else if rid == 1, let catalogData = data as? Catalog, catalogData.products.count > 0 {
            self.catalogData?.products.append(contentsOf: catalogData.products)
        }
        self.collectionView.reloadData()
    }
    
    //MARK - JAFiltersViewControllerDelegate
    func updatedFilters(_ updatedFiltersArray: [Any]!) {
        self.catalogData?.filters = updatedFiltersArray as? [BaseCatalogFilterItem]
//        self.findActiveFilters()
//        self.setActiveFiltersToHeader()
    }
    
    func subCategorySelected(_ subCategoryUrlKey: String!) {
        
    }
    
    
    //MARK - CatalogHeaderViewDelegate
    func sortTypeSelected(type: Catalog.CatalogSortType) {
        self.sortingMethod = type
        self.loadData()
    }
    
    func filterButtonTapped() {
        self.performSegue(withIdentifier: "showFilterView", sender: nil)
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
        if let filters = self.catalogData?.filters, filters.count > 0 {
            
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
        self.pageNumber += 1
        CatalogDataManager.sharedInstance().getCatalog(target: self, searchTarget: searchTarget, filtersQueryString: pushFilterQueryString, sortingMethod: sortingMethod, page: self.pageNumber) { (data, errorMessages) in
            self.bind(data, forRequestId: 1)
        }
    }
    
    
    //MARK - UICollectionViewDataSource & UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
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
        return cell
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
}
