//
//  OrderCancellationResultViewController.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 1/14/18.
//  Copyright © 2018 Rocket Internet. All rights reserved.
//

import UIKit

class OrderCancellationResultViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak private var tableView: UITableView!
    var canceledProducts: [CancellingOrderProduct]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(UINib(nibName: OrderCancellationResultTableViewCell.nibName(), bundle: nil), forCellReuseIdentifier: OrderCancellationResultTableViewCell.nibName())
        self.tableView.register(UINib(nibName: OrderCancellationResultHeaderTableViewCell.nibName(), bundle: nil), forCellReuseIdentifier: OrderCancellationResultHeaderTableViewCell.nibName())
        self.tableView.tableFooterView = UIView(frame: .zero)
        
        //custom back button action for this view
        self.navigationItem.hidesBackButton = true
        let newBackButton = UIBarButtonItem()
        newBackButton.image = UIImage(named: "btn_back")
        newBackButton.style = .plain
        newBackButton.target = self
        newBackButton.action = #selector(backToRoot)
        self.navigationItem.leftBarButtonItem = newBackButton
    }
    
    @objc private func backToRoot() {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    //MARK: - UITableViewDataSource & UITableViewDelegate
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            return self.tableView.dequeueReusableCell(withIdentifier: OrderCancellationResultHeaderTableViewCell.nibName(), for: indexPath)
        } else {
            let cell = self.tableView.dequeueReusableCell(withIdentifier: OrderCancellationResultTableViewCell.nibName(), for: indexPath) as! OrderCancellationResultTableViewCell
            if indexPath.row < self.canceledProducts?.count ?? 0 {
                cell.update(withModel: self.canceledProducts?[indexPath.row])
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 1 : self.canceledProducts?.count ?? 0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
}
