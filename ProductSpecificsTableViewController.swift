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
    var product: NewProduct?
    var isLoaded = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        
        self.tableView.register(UINib(nibName: ProductSpecificItemTableViewCell.nibName(), bundle: nil), forCellReuseIdentifier: ProductSpecificItemTableViewCell.nibName())
        self.tableView.register(UINib(nibName: ProductSpecificsTitleTableHeaderView.nibName(), bundle: nil), forHeaderFooterViewReuseIdentifier: ProductSpecificsTitleTableHeaderView.nibName())
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.tableView.tableFooterView = UIView(frame: .zero)
        
        if let model = product?.specifications {
            isLoaded = true
            self.updateWith(sepecifics: model)
        }
    }

    private func updateWith(sepecifics: [ProductSpecificsTableSection]) {
        tableView.reloadData()
    }
    
    private var gettinSpecificationBussy = false
    func getContent(completion: ((Bool)-> Void)? = nil) {
        if let sku = product?.sku, !gettinSpecificationBussy, !isLoaded {
            gettinSpecificationBussy = true
            ProductDataManager.sharedInstance.getSpecifications(self, sku: sku) { (data, error) in
                self.gettinSpecificationBussy = false
                if (error == nil) {
                    self.bind(data, forRequestId: 0)
                    completion?(true)
                } else {
                    self.errorHandler(error, forRequestID: 0)
                    completion?(false)
                }
            }
        }
    }
    
}

extension ProductSpecificsTableViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return product?.specifications?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return product?.specifications?[section].body?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: ProductSpecificItemTableViewCell.nibName(), for: indexPath) as! ProductSpecificItemTableViewCell
        cell.update(withModel: product?.specifications?[indexPath.section].body?[indexPath.row])
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
        headerView.titleString = self.product?.specifications?[section].header
        headerView.frame.size.width = self.tableView.frame.width
        return headerView
    }
}

//MARK: - DataServiceProtocol
extension ProductSpecificsTableViewController : DataServiceProtocol {
    
    func bind(_ data: Any!, forRequestId rid: Int32) {
        if let model = data as? ProductSpecifics {
            product?.specifications = model.items
            isLoaded = true
            tableView.reloadData()
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
        self.getContent() { (succes) in
            callBack?(succes)
        }
    }
}
