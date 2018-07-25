//
//  DeliveryTimeControl.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 8/5/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

import UIKit

class DeliveryTimeControl: BaseViewControl {
    
    weak var delegate: DeliveryTimeViewDelegate? {
        didSet {
            self.deliveryView?.delegate = delegate
        }
    }
    
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
        self.deliveryView?.delegate = delegate
        if let view = self.deliveryView {
            self.addAnchorMatchedSubView(view: view)
        }
    }
    
    func fillTheView(prefilledValue: String?) {
        self.deliveryView?.fillTheView(preDefaultValue: prefilledValue)
    }
    
    func switchTheTextAlignments(){
        self.deliveryView?.switchTheTextAlignments()
    }
}
