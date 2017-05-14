//
//  CatalogViewController.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 5/9/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

import UIKit

@objc class CatalogViewController: BaseViewController, DataServiceProtocol, JAFiltersViewControllerDelegate {
    
    var searchTarget: RITarget?
    var sortingMethod: Catalog.CatalogSortType = .populaity
    var pushFilterQueryString : String?
    
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
            self.updateNavBar()
        } else if rid == 1, let catalogData = data as? Catalog, let newProductArray = catalogData.products {
            self.catalogData?.products?.append(contentsOf: newProductArray)
        }
    }
    
    //MARK - JAFiltersViewControllerDelegate
    func updatedFilters(_ updatedFiltersArray: [Any]!) {
        
    }
    
    func subCategorySelected(_ subCategoryUrlKey: String!) {
        
    }
    
    //MARK - Helpers
    private func loadData() {
        self.pageNumber = 1
        CatalogDataManager.sharedInstance().getCatalog(target: self, searchTarget: searchTarget, filtersQueryString: pushFilterQueryString, sortingMethod: sortingMethod) { (data, errorMessages) in
            self.bind(data, forRequestId: 0)
        }
    }
    
    private func loadMore() {
        self.pageNumber += 1
        CatalogDataManager.sharedInstance().getCatalog(target: self, searchTarget: searchTarget, filtersQueryString: pushFilterQueryString, sortingMethod: sortingMethod, page: self.pageNumber) { (data, errorMessages) in
            self.bind(data, forRequestId: 1)
        }
    }
    
    private func resetAndClear() {
        self.pageNumber = 0
        self.catalogData = nil
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
