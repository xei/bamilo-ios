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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.catalogHeaderView = CatalogHeaderView.nibInstance()
        if let view = self.catalogHeaderView {
            self.addSubview(view)
            view.frame = self.bounds;
        }
    }

}
