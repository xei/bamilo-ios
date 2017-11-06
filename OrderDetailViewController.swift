//
//  OrderDetailViewController.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 10/22/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

import UIKit

class OrderDetailViewController: BaseViewController, OrderDetailTableViewCellDelegate, DataServiceProtocol {

    let orderTableViewCtrl = OrderDetailTableViewController()
    var orderId: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.orderTableViewCtrl.delegate = self
        orderTableViewCtrl.addInto(viewController: self, containerView: self.view)
        
        //update the bottom constraint with tabbar height
        orderTableViewCtrl.view.superview?.constraints.forEach { (constraint) in
            if constraint.firstAttribute == .bottom {
                if let height = MainTabBarViewController.sharedInstance()?.tabBar.frame.height {
                    constraint.constant = height
                }
            }
        }
        
        if let orderId = self.orderId {
            OrderDataManager.sharedInstance.getOrder(self, orderId: orderId) { (data, errors) in
                if errors == nil {
                    self.bind(data, forRequestId: 0)
                } else {
                    Utility.handleError(error: errors, viewController: self)
                }
            }
        }
        self.hidesBottomBarWhenPushed = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.tabBarController?.tabBar.isHidden = false;
    }
    
    //MARK: - OrderDetailTableViewCellDelegate
    func openRateViewWithSku(sku: String) {
        LoadingManager.showLoading()
        RIProduct.getCompleteWithSku(sku, successBlock: { (product) in
            LoadingManager.hideLoading()
            if let product = product {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "NOTIFICATION_SHOW_PRODUCT_SPECIFICATION_SCREEN"), object: nil, userInfo: ["product": product, "product.screen": "reviews"])
            }
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
    
    // MARK: - DataServiceProtocol
    func bind(_ data: Any!, forRequestId rid: Int32) {
        if let orderItem = data as? OrderItem {
            self.orderTableViewCtrl.bindOrder(order: orderItem)
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
