//
//  OrderDetailCancellationViewController.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 1/9/18.
//  Copyright © 2018 Rocket Internet. All rights reserved.
//

import UIKit

class OrderDetailCancellationViewController: BaseViewController, DataServiceProtocol {
    
    @IBOutlet weak private var contentWrapperView: UIView!
    @IBOutlet weak private var cancelOrderSubmitButton: OrangeButton!
    @IBOutlet weak private var submitButtonBottomToSuperViewConstaint: NSLayoutConstraint!
    
    var selectedProduct: OrderProductItem?
    var order: OrderItem?
    
    private let orderCancellationTableViewCtrl = OrderDetailCancellationTableViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.contentWrapperView.backgroundColor = .clear
        orderCancellationTableViewCtrl.addInto(viewController: self, containerView: self.contentWrapperView)
        
        if let order = self.order {
            orderCancellationTableViewCtrl.bindOrder(order: order, selectedSimpleSku: self.selectedProduct?.simpleSku)
        }
        
        //it's possible that previous view controllers hides bottom bar so content edges will be disturbed
        //by this trick this view always shows proper boundary
        self.submitButtonBottomToSuperViewConstaint.constant = MainTabBarViewController.sharedInstance()?.tabBar.frame.height ?? 0
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown(notification:)), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    deinit {
        //remove all observers for this view controller when it's deinitliazed
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.tabBarController?.tabBar.isHidden = false;
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.hidesBottomBarWhenPushed = false
        self.tabBarController?.tabBar.isHidden = false;
    }
    
    @IBAction func cancellationSubmitButtonTapped(_ sender: Any) {
        let avaiebleCancellingOrder = self.orderCancellationTableViewCtrl.getCancellingOrder()
        if let cancellingOrder = avaiebleCancellingOrder {
            OrderDataManager.sharedInstance.cancelOrderItems(self, order: cancellingOrder) { (data, error) in
                if error == nil {
                    self.bind(data, forRequestId: 0)
                } else {
                    self.errorHandler(error, forRequestID: 0)
                }
            }
        } else {
            self.showNotificationBarMessage(PLEASE_SELECT_AT_LEAST_ONE_CASE, isSuccess: false)
        }
    }
    
    //MARK: - KeyboardNotifications
    func keyboardWasShown(notification:NSNotification) {
        if !self.orderCancellationTableViewCtrl.isMoreDescriptionFieldFirstResponder() { return }
        let userInfo = notification.userInfo
        let keyboardFrame:NSValue? = userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue
        let keyboardRectangle = keyboardFrame?.cgRectValue
        if let keyboardHeight = keyboardRectangle?.height {
            self.submitButtonBottomToSuperViewConstaint.constant = keyboardHeight
        }
        self.orderCancellationTableViewCtrl.scrollToMoreDescriptionField()
    }
    
    func keyboardWillBeHidden(notification: Notification) {
        if let tabbarHeight = self.navigationController?.tabBarController?.tabBar.frame.height {
            self.submitButtonBottomToSuperViewConstaint.constant = tabbarHeight
        }
    }
    
    //MARK: - OrderCancellationTableViewCellDelegate
    override func navBarTitleString() -> String! {
        return STRING_SUBMIT_CANCELLATION
    }
    
    override func getScreenName() -> String! {
        return "OrderCancellation"
    }
    
    //MARK: - DataServiceProtocol
    func bind(_ data: Any!, forRequestId rid: Int32) {
        self.performSegue(withIdentifier: "showSuccessCancellationResult", sender: nil)
    }
    
    func errorHandler(_ error: Error!, forRequestID rid: Int32) {
        if !self.showNotificationBar(error, isSuccess: false) {
            self.showNotificationBarMessage(STRING_ERROR_MESSAGE, isSuccess: false)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let segueName = segue.identifier
        if segueName == "showSuccessCancellationResult" {
            let destinationViewCtrl = segue.destination as? OrderCancellationResultViewController
            destinationViewCtrl?.canceledProducts = self.orderCancellationTableViewCtrl.getCancellingProductList()
        }
    }
}
