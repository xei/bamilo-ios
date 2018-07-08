//
//  ProductSpecificsTableViewController.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 6/26/18.
//  Copyright © 2018 Rocket Internet. All rights reserved.
//

import UIKit

class ProductSpecificsTableViewController: BaseViewController {
    
    @IBOutlet private weak var tableView: UITableView!
    var model: [ProductSpecificsTableSection]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        
        self.tableView.register(UINib(nibName: ProductSpecificItemTableViewCell.nibName(), bundle: nil), forCellReuseIdentifier: ProductSpecificItemTableViewCell.nibName())
        self.tableView.register(UINib(nibName: ProductSpecificsTitleTableHeaderView.nibName(), bundle: nil), forHeaderFooterViewReuseIdentifier: ProductSpecificsTitleTableHeaderView.nibName())
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.tableView.tableFooterView = UIView(frame: .zero)
        
        if let model = model {
            self.updateWith(sepecifics: model)
        }
    }

    private func updateWith(sepecifics: [ProductSpecificsTableSection]) {
        self.model = sepecifics
        self.tableView.reloadData()
    }
    
}

extension ProductSpecificsTableViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return model?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model?[section].body?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: ProductSpecificItemTableViewCell.nibName(), for: indexPath) as! ProductSpecificItemTableViewCell
        cell.update(withModel: model?[indexPath.section].body?[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return ProductSpecificsTitleTableHeaderView.cellHeight()
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = self.tableView.dequeueReusableHeaderFooterView(withIdentifier: ProductSpecificsTitleTableHeaderView.nibName()) as! ProductSpecificsTitleTableHeaderView
        headerView.titleString = self.model?[section].header
        headerView.frame.size.width = self.tableView.frame.width
        return headerView
    }
}
