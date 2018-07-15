
//
//  OtherSellerViewController.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 7/15/18.
//  Copyright © 2018 Rocket Internet. All rights reserved.
//

import UIKit

class OtherSellerViewController: BaseViewController, DataServiceProtocol {

    
    var product: Product?
    private var dataSource: SellerList?
    @IBOutlet private weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        [MinimalProductTableViewCell.nibName(), SellerOfferItemTableViewCell.nibName()].forEach {
            tableView.register(UINib(nibName: $0, bundle: nil), forCellReuseIdentifier: $0)
        }
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getContent()
    }
    
    private func getContent(completion: ((Bool)-> Void)? = nil) {
        if let sku = product?.sku {
            ProductDataManager.sharedInstance.getOtherSellers(self, sku: sku, cityId: DeliveryTimeView.getSelectedCityID()) { (data, error) in
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
    
    //MARK: - DataServiceProtocol
    func bind(_ data: Any!, forRequestId rid: Int32) {
        if let sellerList = data as? SellerList {
            dataSource = sellerList
            tableView.reloadData()
        }
    }
    
    func retryAction(_ callBack: RetryHandler!, forRequestId rid: Int32) {
        self.getContent { (succes) in
            callBack?(succes)
        }
    }
    
    func errorHandler(_ error: Error!, forRequestID rid: Int32) {
        if rid == 0 {
            if !Utility.handleErrorMessages(error: error, viewController: self) {
                self.handleGenericErrorCodesWithErrorControlView(Int32(error.code), forRequestID: rid)
            }
        }
    }
}


//MARK: - UITableviewDelegate & UITableViewDataSource
extension OtherSellerViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 1 : (self.dataSource?.items?.count ?? 0)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: MinimalProductTableViewCell.nibName(), for: indexPath) as! MinimalProductTableViewCell
            cell.update(withModel:  product)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: SellerOfferItemTableViewCell.nibName(), for: indexPath) as! SellerOfferItemTableViewCell
            if let listItems = dataSource?.items, indexPath.row < listItems.count {
                cell.update(withModel:  listItems[indexPath.row])
            }
            return cell
        }
    }
}
