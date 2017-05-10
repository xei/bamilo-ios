//
//  CatalogViewController.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 5/9/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

import UIKit

@objc class CatalogViewController: BaseViewController, DataServiceProtocol, JAFiltersViewControllerDelegate {
    
    var categoryUrlKey: String?
    var searchString: String?
    var filterQueryParamsString: String?
    var subCategoryFilterItem: CatalogCategoryFilterItem?
    
    private var catalogData: Catalog?
    private var noResultViewController: CatalogNoResultViewController?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.loadData()
    }
    
    override func updateNavBar() {
        super.updateNavBar()
        
        self.navBarLayout.title = self.catalogData?.title
        self.navBarLayout.showBackButton = true
    }
    
    //MARK - DataServiceProtocol
    func bind(_ data: Any!, forRequestId rid: Int32) {
        if let catalogData = data as? Catalog {
            self.catalogData = catalogData
            self.updateNavBar()
            
            self.performSegue(withIdentifier: "showFilterView", sender: nil)
        }
    }
    
    //MARK - JAFiltersViewControllerDelegate
    func updatedFilters(_ updatedFiltersArray: [Any]!) {
        
    }
    
    func subCategorySelected(_ subCategoryUrlKey: String!) {
        
    }
    
    //MARK - Helpers
    private func loadData() {
        CatalogDataManager.sharedInstance().getCatalog(target: self) { (data, error) in
            self.bind(data, forRequestId: 0)
        }
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
