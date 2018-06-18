//
//  ProductOldSellerViewTableViewCell.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 6/17/18.
//  Copyright © 2018 Rocket Internet. All rights reserved.
//

import UIKit

class ProductOldSellerViewTableViewCell: BaseProductTableViewCell {

    @IBOutlet weak var sellerViewControl: SellerViewControl!
    
    override func update(withModel model: Any!) {
        if let product = model as? Product, let seller = product.seller {
            sellerViewControl.update(withModel: seller)
            sellerViewControl.runDeliveryTimeCalculations(productSku: product.sku)
        }
    }
}
