//
//  OrderDetailViewController.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 10/22/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

import UIKit

class OrderDetailViewController: BaseViewController, OrderDetailTableViewCellDelegate {

    let orderTableViewCtrl = OrderDetailTableViewController()
    var order: OrderItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.orderTableViewCtrl.delegate = self
        
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
        self.order?.id = "4732897483274932"
        self.order?.creationDate = "چهارشنبه ۲۲ فروردین ۱۳۹۹"
        self.order?.price = "30000"
        self.order?.shippingAddress = Address()
        self.order?.shippingAddress?.address = "گلبرگ غربی، کوچه صفایی، کوچه انوار، بن بست ۲۲ ام بهمن، پلاک ۷، واحد ۷"
        self.order?.paymentMethod = "درگاه بانک پارسیان (آسان پرداخت)"
        
        orderTableViewCtrl.addInto(viewController: self, containerView: self.view)
        orderTableViewCtrl.bindOrder(order: self.order!)
    }
    
    //MARK: - OrderDetailTableViewCellDelegate
    func openRateViewWithSku(sku: String) {
        LoadingManager.showLoading()
        RIProduct.getCompleteWithSku(sku, successBlock: { (product) in
            LoadingManager.hideLoading()
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "NOTIFICATION_SHOW_PRODUCT_SPECIFICATION_SCREEN"), object: ["product": product, "product.screen": "reviews"])
        }) { (response, error) in
            LoadingManager.hideLoading()
            Utility.handleError(error: error, viewController: self)
        }
    }
    
    func opensProductDetailWithSku(sku: String) {
        self.performSegue(withIdentifier: "pushPDVViewController", sender: sku)
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let segueName = segue.identifier
        if segueName == "pushPDVViewController", let pdvViewCtrl = segue.destination as? JAPDVViewController {
            pdvViewCtrl.productSku = sender as? String
        }
    }
    
    // MARK: -DataTrackerProtocol
    override func getScreenName() -> String! {
        return "OrderDetailView"
    }
    
    // MARK - NavigationBarProtocol
    override func navBarTitleString() -> String! {
        return STRING_ORDER_STATUS
    }
}
