//
//  OrderDetailCancellationViewController.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 1/9/18.
//  Copyright © 2018 Rocket Internet. All rights reserved.
//

import UIKit

class OrderDetailCancellationViewController: BaseViewController,
                                            UITableViewDelegate,
                                            UITableViewDataSource,
                                            OrderCancellationTableViewCellDelegate,
                                            DataServiceProtocol {
    @IBOutlet weak private var tableView: UITableView!
    @IBOutlet weak private var cancelOrderSubmitButton: OrangeButton!
    @IBOutlet weak private var submitButtonBottomToSuperViewConstaint: NSLayoutConstraint!
    private var footerView: OrderCancellationFooterView?
    private var dataSource: [CancellingOrderProduct]?
    private var selectedCancellingItems: [CancellingOrderProduct]?
    private var tableViewInitialContentInsets: UIEdgeInsets?
    var selectedProduct: OrderProductItem?
    
    var order: OrderItem? {
        didSet {
            self.dataSource = self.order?.packages?.map { $0.products }.flatMap { $0 }.flatMap { $0.map { $0.convertToCancelling() }	}
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.tableView.backgroundColor = .clear
        //Brign up the selected item to the first of list
        if let selectedSimpleSku = selectedProduct?.simpleSku, let selectedIndex = self.dataSource?.index(where: { $0.simpleSku == selectedSimpleSku }) {
            self.dataSource?[selectedIndex].isSelected = true
            self.dataSource?.rearrange(from: selectedIndex, to: 0)
        }
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.setEditing(true, animated: false)
        self.tableView.allowsMultipleSelectionDuringEditing = true
        
        //it's possible that previous view controllers hides bottom bar so content edges will be disturbed
        //by this trick this view always shows proper boundary
        self.submitButtonBottomToSuperViewConstaint.constant = MainTabBarViewController.sharedInstance()?.tabBar.frame.height ?? 0
        
        //To remove floating header/footer of sections
        let dummyHeaderViewHeight = CGFloat(40)
        self.tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.bounds.size.width, height: dummyHeaderViewHeight))
        
        let dummyFooterViewHeight = CGFloat(400)
        self.tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.bounds.size.width, height: dummyFooterViewHeight))
        self.tableViewInitialContentInsets = UIEdgeInsetsMake(-dummyHeaderViewHeight, 0, -dummyFooterViewHeight, 0)
        self.tableView.contentInset = self.tableViewInitialContentInsets!
        
        self.tableView.register(UINib(nibName: OrderCancellationTableViewCell.nibName(), bundle: nil), forCellReuseIdentifier: OrderCancellationTableViewCell.nibName())
        self.tableView.register(UINib(nibName: PlainTableViewHeaderCell.nibName(), bundle: nil), forHeaderFooterViewReuseIdentifier: PlainTableViewHeaderCell.nibName())
        
        self.tableView.register(UINib(nibName: OrderCancellationFooterView.nibName(), bundle: nil), forHeaderFooterViewReuseIdentifier: OrderCancellationFooterView.nibName())
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown(notification:)), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden(notification:)), name: NSNotification.Name.UIKeyboardDidHide, object: nil)
    }
    
    deinit {
        //remove all observers for this view controller when it's deinitliazed
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.updateTableviewSelection()
        
    }
    
    //MARK: - UITableViewDelegate & UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataSource?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: OrderCancellationTableViewCell.nibName(), for: indexPath) as! OrderCancellationTableViewCell
        cell.delegate = self
        cell.selectionStyle = .blue
        if let cancellingItem = self.dataSource?[indexPath.row], let cancellingReasons = self.order?.cancellationInfo?.reasons {
            cell.update(cancellingItem: cancellingItem, cancellingReasons: cancellingReasons)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.toggleSelection(indexPath: indexPath, selected: true)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        self.toggleSelection(indexPath: indexPath, selected: false)
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = self.tableView.dequeueReusableHeaderFooterView(withIdentifier: PlainTableViewHeaderCell.nibName()) as! PlainTableViewHeaderCell
        headerView.titleString = STRING_CANCEL_ITEMS_DESC
        headerView.frame.size.width = UIScreen.main.bounds.width
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return PlainTableViewHeaderCell.cellHeight()
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        self.footerView = self.tableView.dequeueReusableHeaderFooterView(withIdentifier: OrderCancellationFooterView.nibName()) as? OrderCancellationFooterView
        self.footerView?.orderCancellationCMSLabel.text = self.order?.cancellationInfo?.refundMessage
        self.footerView?.orderCancellationNoticeMessage.text = self.order?.cancellationInfo?.noticeMessage
        self.footerView?.frame.size.width = UIScreen.main.bounds.width
        return self.footerView
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
        return 100
    }
    
    private func toggleSelection(indexPath: IndexPath, selected: Bool) {
        if let cancellingItem = self.dataSource?[indexPath.row] {
            CATransaction.begin()
            CATransaction.setCompletionBlock({ () -> Void in
                // 2. animate views after expanding
                self.tableView.beginUpdates()
                cancellingItem.isSelected = selected
                self.tableView.endUpdates()
            })
            if let cell = self.tableView.cellForRow(at: indexPath) as? OrderCancellationTableViewCell {
                cell.toggleView(selected: selected)
            }
            CATransaction.commit()
        }
    }
    
    private func updateTableviewSelection() {
        if let data = dataSource {
            for (index, element) in data.enumerated() {
                if element.isSelected {
                    self.tableView.selectRow(at: IndexPath(row: index, section: 0), animated: false, scrollPosition: .none)
                } else {
                    self.tableView.deselectRow(at: IndexPath(row: index, section: 0), animated: false)
                }
            }
        }
    }
    
    @IBAction func cancellationSubmitButtonTapped(_ sender: Any) {
        let cancellingOrder = CancellingOrder()
        cancellingOrder.items = self.dataSource?.filter { $0.isSelected }
        if cancellingOrder.items?.count == 0 {
            self.showNotificationBarMessage(PLEASE_SELECT_AT_LEAST_ONE_CASE, isSuccess: false)
            return
        }
        cancellingOrder.orderNum = self.order?.id
        cancellingOrder.description = self.footerView?.moreDescriptionTextView.text
        OrderDataManager.sharedInstance.cancelOrderItems(self, order: cancellingOrder) { (data, error) in
            if error == nil {
                self.bind(data, forRequestId: 0)
            } else {
                self.errorHandler(error, forRequestID: 0)
            }
        }
    }
    
    //MARK: - KeyboardNotifications
    func keyboardWasShown(notification:NSNotification) {
        let userInfo = notification.userInfo
        let keyboardFrame:NSValue? = userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue
        let keyboardRectangle = keyboardFrame?.cgRectValue
        if let keyboardHeight = keyboardRectangle?.height, let initContentInset = self.tableViewInitialContentInsets, let tabbarHeight = self.navigationController?.tabBarController?.tabBar.frame.height {
            let newContentInsets = UIEdgeInsetsMake(initContentInset.top, initContentInset.left, initContentInset.bottom + keyboardHeight - self.cancelOrderSubmitButton.frame.height - tabbarHeight, initContentInset.right)
            self.tableView.contentInset = newContentInsets
            self.tableView.scrollIndicatorInsets = newContentInsets
            
            if let footerView = footerView ,footerView.moreDescriptionTextView.isFirstResponder {
                self.tableView.scrollRectToVisible(self.tableView.convert(self.tableView.tableFooterView!.bounds, from: self.tableView.tableFooterView), animated: true)
            }
        }
    }
    
    func keyboardWillBeHidden(notification: Notification) {
        if let contentInsets = self.tableViewInitialContentInsets {
            self.tableView.contentInset = contentInsets
            self.tableView.scrollIndicatorInsets = contentInsets
        }
    }
    
    //MARK: - OrderCancellationTableViewCellDelegate
    override func navBarTitleString() -> String! {
        return STRING_CITY
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
            destinationViewCtrl?.canceledProducts = self.dataSource?.filter { $0.isSelected }
        }
    }
}
