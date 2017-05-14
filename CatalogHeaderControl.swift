//
//  CatalogHeaderControl.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 5/13/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

import UIKit

class CatalogHeaderControl: BaseViewControl {
    
    var catalogHeaderView: CatalogHeaderView?
    var delegate: CatalogHeaderViewDelegate? {
        didSet {
            self.catalogHeaderView?.delegate = self.delegate
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.catalogHeaderView = CatalogHeaderView.nibInstance()
        self.catalogHeaderView?.delegate = self.delegate
        if let view = self.catalogHeaderView {
            self.addSubview(view)
            view.frame = self.bounds;
        }
    }

}
