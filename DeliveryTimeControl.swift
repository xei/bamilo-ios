//
//  DeliveryTimeControl.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 8/5/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

import UIKit

class DeliveryTimeControl: BaseViewControl {
    
    var deliveryView: DeliveryTimeView?
    var productSku: String? {
        didSet {
            self.deliveryView?.productSku = productSku
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = .clear
        self.deliveryView = DeliveryTimeView.nibInstance()
        if let view = self.deliveryView {
            self.addAnchorMatchedSubView(view: view)
        }
    }
    
    func fillTheView() {
        self.deliveryView?.fillTheView()
    }
    
    func switchTheTextAlignments(){
        self.deliveryView?.switchTheTextAlignments()
    }
}
