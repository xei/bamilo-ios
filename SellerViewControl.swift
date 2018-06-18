//
//  SellerViewControl.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 6/17/18.
//  Copyright © 2018 Rocket Internet. All rights reserved.
//

import UIKit

class SellerViewControl: BaseViewControl {

    var sellerView: SellerView?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = .clear
        self.sellerView = SellerView.nibInstance()
        if let view = self.sellerView {
            self.addAnchorMatchedSubView(view: view)
        }
    }
    
    override func update(withModel model: Any!) {
        if let seller = model as? Seller {
            self.sellerView?.update(with: seller)
        }
    }

    func runDeliveryTimeCalculations(productSku: String) {
        sellerView?.runDeliveryTimeCalculations(productSku: productSku)
    }
    
}
