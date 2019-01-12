//
//  OrderDetailViewController.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 10/22/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

import UIKit

class OrderDetailViewController: BaseViewController, OrderDetailTableViewCellDelegate, DataServiceProtocol {
    
    @IBOutlet private weak var activiryIndicator: UIActivityIndicatorView!
    let orderTableViewCtrl = OrderDetailTableViewController()
    @objc var orderId: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
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
        self.loadContent()
    }
    
    private func loadContent(completion: ((Bool)-> Void)? = nil) {
        if let orderId = self.orderId {
            self.activiryIndicator.startAnimating()
            self.recordStartLoadTime()
            OrderDataManager.sharedInstance.getOrder(self, orderId: orderId) { (data, errors) in
                self.activiryIndicator.stopAnimating()
                if let error = errors {
                    completion?(false)
                    self.errorHandler(error, forRequestID: 0)
                } else {
                    completion?(true)
                    self.bind(data, forRequestId: 0)
                    self.publishScreenLoadTime(withName: self.getScreenName(), withLabel: self.orderId)
                }
            }
        } else {
            self.handleGenericErrorCodesWithErrorControlView(Int32(NSURLErrorBadServerResponse), forRequestID: 0)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.hidesBottomBarWhenPushed = false
        self.tabBarController?.tabBar.isHidden = false;
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.tabBarController?.tabBar.isHidden = false;
    }
    
    //MARK: - OrderDetailTableViewCellDelegate
    func openRateViewWithProdcut(product: TrackableProductProtocol) {
        self.performSegue(withIdentifier: "showSubmitProductReviewViewController", sender: product)
    }
    
    func opensProductDetailWithSku(sku: String) {
        self.performSegue(withIdentifier: "pushPDVViewController", sender: sku)
    }
    
    func cancelProduct(product: OrderProductItem) {
        if let order = self.orderTableViewCtrl.dataSource, let avaiableCancellationReasons = order.cancellationInfo?.reasons, avaiableCancellationReasons.count > 0 {
            self.performSegue(withIdentifier: "pushCancellationViewController", sender: product)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let segueName = segue.identifier
        if segueName == "pushPDVViewController", let pdvViewCtrl = segue.destination as? ProductDetailViewController {
            pdvViewCtrl.productSku = sender as? String
        }
        if segueName == "pushCancellationViewController", let cancellingOrderViewCtrl = segue.destination as? OrderDetailCancellationViewController, let order = self.orderTableViewCtrl.dataSource, let avaiableCancellationReasons = order.cancellationInfo?.reasons, avaiableCancellationReasons.count > 0, let selectedProduct = sender as? OrderProductItem  {
            cancellingOrderViewCtrl.selectedProduct = selectedProduct
            cancellingOrderViewCtrl.order = order
        }
        if segueName == "showSubmitProductReviewViewController", let product = sender as? TrackableProductProtocol, let viewCtrl = segue.destination as? SubmitProductReviewViewController {
            viewCtrl.hidesBottomBarWhenPushed = true
            viewCtrl.prodcut = product
        }
    }
    
    // MARK: - DataServiceProtocol
    func bind(_ data: Any!, forRequestId rid: Int32) {
        if let orderItem = data as? OrderItem {
            self.orderTableViewCtrl.bindOrder(order: orderItem)
        }
    }
    
    func errorHandler(_ error: Error!, forRequestID rid: Int32) {
        if rid == 0 {
            if !Utility.handleErrorMessages(error: error, viewController: self) {
                self.handleGenericErrorCodesWithErrorControlView(Int32(error.code), forRequestID: rid)
            }
        }
    }
    
    func retryAction(_ callBack: RetryHandler!, forRequestId rid: Int32) {
        self.loadContent { (success) in
            callBack(success)
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
