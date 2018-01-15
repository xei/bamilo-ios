//
//  OrderDetailCancellationTableViewController.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 1/15/18.
//  Copyright © 2018 Rocket Internet. All rights reserved.
//

import UIKit

class OrderDetailCancellationTableViewController: AccordionTableViewController {

    private var dataSource: [CancellingOrderProduct]?
    private var footerView: OrderCancellationFooterView?
    private var order: OrderItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //set editing mode for tableview
        self.tableView.setEditing(true, animated: false)
        self.tableView.allowsMultipleSelectionDuringEditing = true
        
        //regiter nibs for cells and header/footer
        self.tableView.register(UINib(nibName: OrderCancellationTableViewCell.nibName(), bundle: nil), forCellReuseIdentifier: OrderCancellationTableViewCell.nibName())
        self.tableView.register(UINib(nibName: PlainTableViewHeaderCell.nibName(), bundle: nil), forHeaderFooterViewReuseIdentifier: PlainTableViewHeaderCell.nibName())
        self.tableView.register(UINib(nibName: OrderCancellationFooterView.nibName(), bundle: nil), forHeaderFooterViewReuseIdentifier: OrderCancellationFooterView.nibName())
        
        //To remove floating header/footer of sections
        let dummyHeaderViewHeight = CGFloat(100)
        self.tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.bounds.size.width, height: dummyHeaderViewHeight))

        let dummyFooterViewHeight = CGFloat(500)
        self.tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.bounds.size.width, height: dummyFooterViewHeight))
        self.tableView.contentInset = UIEdgeInsetsMake(-dummyHeaderViewHeight, 0, -dummyFooterViewHeight, 0)
    }

    func bindOrder(order: OrderItem, selectedSimpleSku: String? = nil) {
        self.order = order
        self.dataSource = self.order?.packages?.map { $0.products }.flatMap { $0 }.flatMap { $0.map { $0.convertToCancelling() } }
        
        //Brign up the selected item to the first of list
        if let selectedSimpleSku = selectedSimpleSku, let selectedIndex = self.dataSource?.index(where: { $0.simpleSku == selectedSimpleSku }) {
            self.dataSource?[selectedIndex].isSelected = true
            self.dataSource?.rearrange(from: selectedIndex, to: 0)
        }
        
        ThreadManager.execute {
            self.tableView.reloadData()
            self.updateTableviewSelection()
        }
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataSource?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 300
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        super.tableView(tableView, cellForRowAt: indexPath)
        let cell = self.tableView.dequeueReusableCell(withIdentifier: OrderCancellationTableViewCell.nibName(), for: indexPath) as! OrderCancellationTableViewCell
        if let cancellingItem = self.dataSource?[indexPath.row], let cancellingReasons = self.order?.cancellationInfo?.reasons {
            cell.update(cancellingItem: cancellingItem, cancellingReasons: cancellingReasons)
        }
        cell.selectionStyle = .blue
        self.setExpandfor(cell: cell, indexPath: indexPath)
        if let cancellingItem = self.dataSource?[indexPath.row], !cancellingItem.isCancelable {
            cell.setExpanded(true, animated: false)
        }
        //To remove offset of seperator in cells
        cell.preservesSuperviewLayoutMargins = false
        cell.layoutMargins = .zero
        cell.separatorInset = .zero
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        super.tableView(tableView, didSelectRowAt: indexPath)
        self.toggleSelection(indexPath: indexPath, selected: true)
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? AccordionTableViewCell {
            toggleCell(cell, animated: shouldAnimateCellToggle)
        }
        self.toggleSelection(indexPath: indexPath, selected: false)
    }
    
    private func toggleSelection(indexPath: IndexPath, selected: Bool) {
        if let cancellingItem = self.dataSource?[indexPath.row] {
            cancellingItem.isSelected = selected
        }
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .delete
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = self.tableView.dequeueReusableHeaderFooterView(withIdentifier: PlainTableViewHeaderCell.nibName()) as! PlainTableViewHeaderCell
        headerView.titleString = STRING_CANCEL_ITEMS_DESC
        headerView.frame.size.width = UIScreen.main.bounds.width
        return headerView
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return PlainTableViewHeaderCell.cellHeight()
    }

    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        self.footerView = self.tableView.dequeueReusableHeaderFooterView(withIdentifier: OrderCancellationFooterView.nibName()) as? OrderCancellationFooterView
        self.footerView?.orderCancellationCMSLabel.text = self.order?.cancellationInfo?.refundMessage
        self.footerView?.orderCancellationNoticeMessage.text = self.order?.cancellationInfo?.noticeMessage
        self.footerView?.frame.size.width = UIScreen.main.bounds.width
        return self.footerView
    }

    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return UITableViewAutomaticDimension
    }

    override  func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
        return 100
    }
    
    private func updateTableviewSelection() {
        if let data = dataSource {
            for (index, element) in data.enumerated() {
                if element.isSelected {
                    self.tableView.selectRow(at: IndexPath(row: index, section: 0), animated: false, scrollPosition: .none)
                    super.tableView(self.tableView, didSelectRowAt: IndexPath(row: index, section: 0))
                } else {
                    self.tableView.deselectRow(at: IndexPath(row: index, section: 0), animated: false)
                }
            }
        }
    }
    
    func getCancellingOrder() -> CancellingOrder? {
        let cancellingOrder = CancellingOrder()
        cancellingOrder.items = self.dataSource?.filter { $0.isSelected }
        if cancellingOrder.items?.count == 0 {
            return nil
        }
        cancellingOrder.orderNum = self.order?.id
        cancellingOrder.description = self.footerView?.moreDescriptionTextView.text
        return cancellingOrder
    }
    
    func getCancellingProductList() ->  [CancellingOrderProduct]? {
        return self.dataSource?.filter { $0.isSelected }
    }
    
    func isMoreDescriptionFieldFirstResponder() -> Bool {
        return self.footerView?.moreDescriptionTextView.isFirstResponder ?? false
    }
}
