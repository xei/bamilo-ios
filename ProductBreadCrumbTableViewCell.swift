//
//  ProductBreadCrumbTableViewCell.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 7/23/18.
//  Copyright © 2018 Rocket Internet. All rights reserved.
//

import UIKit

class ProductBreadCrumbTableViewCell: BaseProductTableViewCell {
    @IBOutlet weak private var breadCrumbView: BreadcrumbsControl!
    
    func setDelegate(delegate: BreadcrumbsViewDelegate) {
        breadCrumbView.delegate = delegate
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func update(withModel model: Any!) {
        breadCrumbView.update(withModel: model)
    }
    
}
