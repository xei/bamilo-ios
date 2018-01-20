//
//  OrderDetailTableViewController.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 10/22/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

import UIKit



class OrderDetailTableViewController: AccordionTableViewController, OrderDetailTableViewCellDelegate {
    
    var dataSource: OrderItem?
    private lazy var heightAtIndexPath = [IndexPath: CGFloat]()
    private lazy var headerHeightForSection = [Int: CGFloat]()
    weak var delegate: OrderDetailTableViewCellDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.shouldAnimateCellToggle = false
        self.view.backgroundColor = .clear
        self.tableView.backgroundColor = .clear
        
        self.tableView.register(UINib(nibName: OrderDetailTableViewCell.nibName(), bundle: nil), forCellReuseIdentifier: OrderDetailTableViewCell.nibName())
        self.tableView.register(UINib(nibName: OrderDetailPackageHeaderTableViewHeader.nibName(), bundle: nil), forHeaderFooterViewReuseIdentifier: OrderDetailPackageHeaderTableViewHeader.nibName())
        self.tableView.register(UINib(nibName: OrderOwnerInfoTableViewCell.nibName(), bundle: nil), forCellReuseIdentifier: OrderOwnerInfoTableViewCell.nibName())
        self.tableView.register(UINib(nibName: OrderInfoTableViewCell.nibName(), bundle: nil), forCellReuseIdentifier: OrderInfoTableViewCell.nibName())
        self.tableView.register(UINib(nibName: OrderCMSMessageTableViewCell.nibName(), bundle: nil), forCellReuseIdentifier: OrderCMSMessageTableViewCell.nibName())
        //To remove extra separators from tableview
        self.tableView.tableFooterView = UIView.init(frame: .zero)
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        let packagesCount = dataSource?.packages?.count ?? 0
        return packagesCount > 0 ? packagesCount + 2 : 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            if let cms = self.dataSource?.cms, cms.count > 0 {
                return 2
            }
            return 1
        }
        if let packagesCount = self.dataSource?.packages?.count, section == packagesCount + 1 { return 1 }
        return self.dataSource?.packages?[section - 1].products?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            //first cell
            if let cmsMessage = self.dataSource?.cms, cmsMessage.count > 0, indexPath.row == 0 {
                let cell = self.tableView.dequeueReusableCell(withIdentifier: OrderCMSMessageTableViewCell.nibName(), for: indexPath) as! OrderCMSMessageTableViewCell
                cell.update(withModel: cmsMessage)
                
                //to remove seperator for this cell
                cell.separatorInset = UIEdgeInsetsMake(0, cell.bounds.size.width, 0, 0);
                return cell
            } else {
                let cell = self.tableView.dequeueReusableCell(withIdentifier: OrderInfoTableViewCell.nibName(), for: indexPath) as! OrderInfoTableViewCell
                cell.update(withModel: self.dataSource)
                return cell
            }
        }
        if let packagesCount = self.dataSource?.packages?.count, indexPath.section == packagesCount + 1 {
            //last cell & last section
            let cell = self.tableView.dequeueReusableCell(withIdentifier: OrderOwnerInfoTableViewCell.nibName(), for: indexPath) as! OrderOwnerInfoTableViewCell
            if let dataSource = self.dataSource {
                cell.update(withModel: dataSource)
            }
            
            //to remove seperator for this cell
            cell.separatorInset = UIEdgeInsetsMake(0, cell.bounds.size.width, 0, 0);
            return cell
        }
        let cell = self.tableView.dequeueReusableCell(withIdentifier: OrderDetailTableViewCell.nibName(), for: indexPath) as! OrderDetailTableViewCell
        cell.delegate = self
        let product = self.dataSource?.packages?[indexPath.section - 1].products?[indexPath.row]
        if let isCancellable = product?.isCancelable {
            //if we have enough information for cancelling the product 
            product?.isCancelable = isCancellable && self.orderHasCancellationInfo()
        }
        cell.update(withModel: self.dataSource?.packages?[indexPath.section - 1].products?[indexPath.row])
        self.setExpandfor(cell: cell, indexPath: indexPath)
        
        //To remove offset of seperator in cells
        cell.preservesSuperviewLayoutMargins = false
        cell.layoutMargins = .zero
        cell.separatorInset = .zero
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let packagesCount = self.dataSource?.packages?.count {
            if section == 0 || section == packagesCount + 1 { return nil }
        } else {
            return nil
        }
        let header = self.tableView.dequeueReusableHeaderFooterView(withIdentifier: OrderDetailPackageHeaderTableViewHeader.nibName()) as! OrderDetailPackageHeaderTableViewHeader
        header.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 42)
        header.backgroundView = UIView(frame: header.frame)
        header.backgroundView?.backgroundColor = Theme.color(kColorGray9)

        header.leftTitleString = self.dataSource?.packages?[section - 1].deliveryTime
        header.titleString = self.dataSource?.packages?[section - 1].title?.convertTo(language: .arabic)
        if let hasDelay = self.dataSource?.packages?[section - 1].delay?.hasDelay, hasDelay {
            header.update(deviationDescription: self.dataSource?.packages?[section - 1].delay?.reason)
            header.leftTitleString = ""
        } else {
            header.update(deviationDescription: nil)
        }
        return header
    }

    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        headerHeightForSection[section] = view.frame.height
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if let packagesCount = self.dataSource?.packages?.count {
            return  (section == 0 || section == packagesCount + 1) ? 0 : self.headerHeightForSection[section] ?? UITableViewAutomaticDimension
        } else { return 0 }
    }

    override func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        if let packagesCount = self.dataSource?.packages?.count {
            return (section == 0 || section == packagesCount + 1) ? 0 : 42
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 400
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.heightAtIndexPath.removeValue(forKey: indexPath)
        super.tableView(tableView, didSelectRowAt: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.heightAtIndexPath[indexPath] ?? UITableViewAutomaticDimension
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        self.heightAtIndexPath[indexPath] = cell.frame.height
    }
    
    func bindOrder(order: OrderItem) {
        self.dataSource = order
        ThreadManager.execute {
            self.tableView.reloadData()
        }
    }
    
    // MARK: - OrderDetailTableViewCellDelegate
    func opensProductDetailWithSku(sku: String) {
        self.delegate?.opensProductDetailWithSku(sku: sku)
    }
    
    func openRateViewWithSku(sku: String) {
        self.delegate?.openRateViewWithSku(sku: sku)
    }
    
    func cancelProduct(product: OrderProductItem) {
        self.delegate?.cancelProduct(product: product)
    }
    
    private var isCancellationInfoEnough: Bool?
    private func orderHasCancellationInfo() -> Bool {
        if let hasEnough = isCancellationInfoEnough {
            return hasEnough
        }
        if let order = self.dataSource, let avaiableCancellationReasons = order.cancellationInfo?.reasons, avaiableCancellationReasons.count > 0 {
            self.isCancellationInfoEnough = true
            return true
        }
        self.isCancellationInfoEnough = false
        return false
    }
}
