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
    weak var delegate: OrderDetailTableViewCellDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.register(UINib(nibName: OrderDetailTableViewCell.nibName(), bundle: nil), forCellReuseIdentifier: OrderDetailTableViewCell.nibName())
        self.tableView.register(UINib(nibName: MutualTitleHeaderCell.nibName(), bundle: nil), forHeaderFooterViewReuseIdentifier: MutualTitleHeaderCell.nibName())
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
            cell.update(withModel: self.dataSource)
            
            //to remove seperator for this cell
            cell.separatorInset = UIEdgeInsetsMake(0, cell.bounds.size.width, 0, 0);
            return cell
        }
        let cell = self.tableView.dequeueReusableCell(withIdentifier: OrderDetailTableViewCell.nibName(), for: indexPath) as! OrderDetailTableViewCell
        cell.delegate = self
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
        
        let cell = self.tableView.dequeueReusableHeaderFooterView(withIdentifier: MutualTitleHeaderCell.nibName()) as! MutualTitleHeaderCell
        cell.frame = CGRect(x: 0, y: 0, width: self.tableView.frame.width, height: 40)
        cell.backgroundView = UIView(frame: cell.frame)
        cell.backgroundView?.backgroundColor = Theme.color(kColorGray9)
        
        cell.leftTitleString = self.dataSource?.packages?[section - 1].deliveryTime
        cell.titleString = self.dataSource?.packages?[section - 1].title?.convertTo(language: .arabic)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if let packagesCount = self.dataSource?.packages?.count {
            if section == 0 || section == packagesCount + 1 { return 0 }
        } else { return 0 }
        
        return 40
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 300
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
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
    
}
