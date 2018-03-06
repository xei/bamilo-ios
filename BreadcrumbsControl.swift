//
//  BreadcrumbsControl.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 11/22/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

import UIKit

class BreadcrumbsControl: BaseViewControl, BreadcrumbsViewDelegate {
    
    var breadcrumbsView: BreadcrumbsView?
    weak var delegate: BreadcrumbsViewDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = .clear
        self.breadcrumbsView = BreadcrumbsView.nibInstance()
        if let view = self.breadcrumbsView {
            view.delegate = self
            self.addAnchorMatchedSubView(view: view)
        }
    }
    
    override func update(withModel model: Any!) {
        if let model = model as? [BreadcrumbsItem] {
            self.breadcrumbsView?.update(model: model)
        }
    }
    
    func itemTapped(item: BreadcrumbsItem) {
        self.delegate?.itemTapped(item: item)
    }
}
