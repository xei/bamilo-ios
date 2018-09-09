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
    weak var delegate: SellerViewDelegate? {
        didSet {
            self.sellerView?.delegate = self.delegate
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = .clear
        self.sellerView = SellerView.nibInstance()
        if let view = self.sellerView {
            self.addAnchorMatchedSubView(view: view)
        }
        self.sellerView?.delegate = self.delegate
    }
    
    override func update(withModel model: Any!) {
        if let product = model as? NewProduct, let seller = product.seller {
            self.sellerView?.update(with: seller, otherSellerCount: product.otherSellerCount ?? 0)
        }
    }

    func runDeliveryTimeCalculations(productSku: String, preValue: String?) {
        sellerView?.runDeliveryTimeCalculations(productSku: productSku, preValue: preValue)
    }
    
}
