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
    private var footerTableViewCell: OrderCancellationFooterTableViewCell?
    private var order: OrderItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        //set editing mode for tableview
        self.tableView.setEditing(true, animated: false)
        self.tableView.allowsMultipleSelectionDuringEditing = true
        if #available(iOS 11.0, *) {
            self.tableView.insetsContentViewsToSafeArea = false
        } else {}
        
        //regiter nibs for cells and header/footer
        self.tableView.register(UINib(nibName: OrderCancellationTableViewCell.nibName(), bundle: nil), forCellReuseIdentifier: OrderCancellationTableViewCell.nibName())
        self.tableView.register(UINib(nibName: PlainTableViewHeaderCell.nibName(), bundle: nil), forHeaderFooterViewReuseIdentifier: PlainTableViewHeaderCell.nibName())
        self.tableView.register(UINib(nibName: OrderCancellationFooterTableViewCell.nibName(), bundle: nil), forCellReuseIdentifier: OrderCancellationFooterTableViewCell.nibName())

        //To remove floating header/footer of sections
        let dummyHeaderViewHeight = CGFloat(100)
        self.tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.bounds.size.width, height: dummyHeaderViewHeight))
        let dummyFooterViewHeight = CGFloat(500)
        self.tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.bounds.size.width, height: dummyFooterViewHeight))
        self.tableView.contentInset = UIEdgeInsetsMake(-dummyHeaderViewHeight, 0, -dummyFooterViewHeight, 0)
    }
    
    func bindOrder(order: OrderItem, selectedSimpleSku: String? = nil) {
        self.order = order
        self.dataSource = self.order?.packages?.map { $0.products }.compactMap { $0 }.flatMap { $0.map { $0.convertToCancelling() } }
        
        //Brign up the selected item to the first of list
        if let selectedSimpleSku = selectedSimpleSku, let selectedIndex = self.dataSource?.index(where: { $0.simpleSku == selectedSimpleSku && $0.isCancelable }) {
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
        if let dataSourceCount = self.dataSource?.count {
            return dataSourceCount + 1
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 300
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let dataSource = self.dataSource, indexPath.row < dataSource.count {
            super.tableView(tableView, cellForRowAt: indexPath)
            let cell = self.tableView.dequeueReusableCell(withIdentifier: OrderCancellationTableViewCell.nibName(), for: indexPath) as! OrderCancellationTableViewCell
            if let cancellingItem = self.dataSource?[indexPath.row], let cancellingReasons = self.order?.cancellationInfo?.reasons {
                cell.update(cancellingItem: cancellingItem, cancellingReasons: cancellingReasons)
            }
            cell.selectionStyle = .blue
            self.setExpandfor(cell: cell, indexPath: indexPath)
            if !dataSource[indexPath.row].isCancelable {
                cell.setExpanded(true, animated: false)
            }
            //To remove offset of seperator in cells
            cell.preservesSuperviewLayoutMargins = false
            cell.layoutMargins = .zero
            cell.separatorInset = .zero
            
            return cell
        } else {
            let cell = self.tableView.dequeueReusableCell(withIdentifier: OrderCancellationFooterTableViewCell.nibName(), for: indexPath) as! OrderCancellationFooterTableViewCell
            self.footerTableViewCell = cell
            
            if let CMSRefundMessage = self.order?.cancellationInfo?.refundMessage {
                cell.setCMSMessage(message: CMSRefundMessage)
            }
            if let noticeMessage = self.order?.cancellationInfo?.noticeMessage {
                cell.setNoticeMessage(message: noticeMessage)
            }
            
            cell.selectionStyle = .none
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == self.dataSource?.count ?? 0 { return }
        super.tableView(tableView, didSelectRowAt: indexPath)
        self.toggleSelection(indexPath: indexPath, selected: true)
        self.setWhiteBackground(cell: self.tableView.cellForRow(at: indexPath))
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if indexPath.row == self.dataSource?.count ?? 0 { return }
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
    
    override func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return indexPath.row != (self.dataSource?.count ?? 0)
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return indexPath.row != (self.dataSource?.count ?? 0)
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        if indexPath.row == (self.dataSource?.count ?? 0) {
            return .none
        }
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
    
    private func updateTableviewSelection() {
        if let data = dataSource {
            for (index, element) in data.enumerated() {
                if element.isSelected {
                    self.tableView.selectRow(at: IndexPath(row: index, section: 0), animated: false, scrollPosition: .none)
                    super.tableView(self.tableView, didSelectRowAt: IndexPath(row: index, section: 0))
                    
                    //prevent blue background selection
                    self.setWhiteBackground(cell: self.tableView.cellForRow(at: IndexPath(row: index, section: 0)))
                } else {
                    self.tableView.deselectRow(at: IndexPath(row: index, section: 0), animated: false)
                }
            }
        }
    }
    
    private func setWhiteBackground(cell: UITableViewCell?) {
        //prevent blue background selection
        let backgroundView = UIView()
        backgroundView.backgroundColor = .white
        cell?.selectedBackgroundView = backgroundView
    }
   
    func getCancellingOrder() -> CancellingOrder? {
        let cancellingOrder = CancellingOrder()
        cancellingOrder.items = self.getCancellingProductList()
        if cancellingOrder.items?.count == 0 {
            return nil
        }
        cancellingOrder.orderNum = self.order?.id
        cancellingOrder.description = self.footerTableViewCell?.moreDescriptionTextView.text
        return cancellingOrder
    }
    
    func getCancellingProductList() ->  [CancellingOrderProduct]? {
        return self.dataSource?.filter { $0.isSelected && $0.isCancelable }
    }
    
    func isMoreDescriptionFieldFirstResponder() -> Bool {
        return self.footerTableViewCell?.moreDescriptionTextView.isFirstResponder ?? false
    }
    
    func scrollToMoreDescriptionField() {
        ThreadManager.execute {
            var moreDescriptionFeildRect = self.getRectOfTextField()
            moreDescriptionFeildRect.size.height += 20  //More description
            self.tableView.scrollRectToVisible(moreDescriptionFeildRect, animated: true)
        }
    }
    
    private func getRectOfTextField() -> CGRect {
        if let textFieldFrame = self.footerTableViewCell?.moreDescriptionTextView.frame {
            return self.tableView.convert(textFieldFrame, from: self.footerTableViewCell)
        }
        return .zero
    }
}
