//
//  CatalogHeaderControl.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 5/13/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

import UIKit

class CatalogHeaderControl: BaseViewControl {
    
    var headerView: CatalogHeaderView?
    weak var delegate: CatalogHeaderViewDelegate? {
        didSet {
            self.headerView?.delegate = self.delegate
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.headerView = CatalogHeaderView.nibInstance()
        self.headerView?.delegate = self.delegate
        if let view = self.headerView {
            self.addAnchorMatchedSubView(view: view)
        }
    }

    func setSortingType(type: Catalog.CatalogSortType) {
        self.headerView?.sortType = type
    }
    
    func setFilterDescription(filterDescription: String) {
        self.headerView?.setFilterDescription(description: filterDescription)
    }
    
    func setFilterButtonActive() {
        self.headerView?.setFilterButtonActive()
    }
    
    func enableFilterButton(enable: Bool) {
        self.headerView?.enableFilterButton(enable: enable)
    }
}
