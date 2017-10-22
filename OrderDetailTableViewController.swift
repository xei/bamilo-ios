//
//  OrderDetailTableViewController.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 10/22/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

import UIKit

class OrderDetailTableViewController: AccordionTableViewController {

    var dataSource: OrderItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.register(UINib(nibName: OrderDetailTableViewCell.nibName(), bundle: nil), forCellReuseIdentifier: OrderDetailTableViewCell.nibName())
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        let packagesCount = dataSource?.packages?.count ?? 0
        return packagesCount > 0 ? packagesCount + 2 : 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 { return 1 }
        if let packagesCount = self.dataSource?.packages?.count, section == packagesCount + 1 { return 1 }
        return self.dataSource?.packages?[section - 1].products?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            //first cell
            return UITableViewCell()
        }
        if let packagesCount = self.dataSource?.packages?.count, indexPath.section == packagesCount + 1 {
            //last cell
            return UITableViewCell()
        }
        let cell = self.tableView.dequeueReusableCell(withIdentifier: OrderDetailTableViewCell.nibName(), for: indexPath) as! OrderDetailTableViewCell
        cell.update(withModel: self.dataSource?.packages?[indexPath.section - 1].products?[indexPath.row])
        self.setExpandfor(cell: cell, indexPath: indexPath)
        return cell
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
}
