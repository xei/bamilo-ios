//
//  OrderDetailViewController.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 10/22/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

import UIKit

class OrderDetailViewController: BaseViewController {

    let orderTableViewCtrl = OrderDetailTableViewController()
    var order: OrderItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.order = OrderItem()
        let orderPackage = OrderPackage()
        orderPackage.title = "بسته اول"
        orderPackage.deliveryTime = "چهارشنبه ۲۲ فروردین ۱۳۹۹"
        let product = OrderProductItem()
        product.name = "تقسیم کننده کشو"
        product.deliveryTime = "یکشنبه ۱۵ مرداد ۱۳۹۶"
        product.quantity = 1
        product.seller = "bamilo"
        product.size = "3"
        product.price = 3000000
        product.imageUrl = URL(string: "http://staging-img.bamilo.com/p/luxineh-4864-1283681-1-cart.jpg")
        product.sku = "LU392HL07N4Y2NAFAMZ"
        orderPackage.products = [product, product, product, product, product, product]
        self.order?.customerFirstName = "علی"
        self.order?.customerLastName = "سعیدی فر"
        self.order?.deliveryCost = "30000"
        self.order?.packages = [orderPackage]
        
        
        orderTableViewCtrl.addInto(viewController: self, containerView: self.view)
        orderTableViewCtrl.bindOrder(order: self.order!)
    }
    
}
