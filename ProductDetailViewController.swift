//
//  ProductDetailViewController.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 5/21/18.
//  Copyright © 2018 Rocket Internet. All rights reserved.
//

import UIKit

class ProductDetailViewController: BaseViewController,
                                    UITableViewDelegate,
                                    UITableViewDataSource,
                                    DataServiceProtocol {

    var product: Product?
    @IBOutlet weak private var tableView: UITableView!
    private var sliderCell: ProductDetailViewSliderTableViewCell?

    enum CellType {
        case slider
    }
    
    fileprivate var availableSections = [Int: [CellType]]()
    let cellIdentifiers : [CellType: String] = [
        .slider:   ProductDetailViewSliderTableViewCell.nibName()
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.clipsToBounds = true
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.separatorStyle = .none
        self.tableView.clipsToBounds = false
        
        cellIdentifiers.forEach { (cellId) in
            self.tableView.register(UINib(nibName: cellId.value, bundle: nil), forCellReuseIdentifier: cellId.value)
        }
        
        self.tableView.tableFooterView = UIView(frame: .zero)
        self.getContent()
    }
    
    //MARK : -  UITableViewDelegate && UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.availableSections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.availableSections[section]?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellType = (self.availableSections[indexPath.section])![indexPath.row]
        let cellIdentifier = self.cellIdentifiers[cellType]!
        switch cellType {
            case .slider:
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! ProductDetailViewSliderTableViewCell
            cell.update(withModel: self.product?.imageList ?? [])
            cell.delegate = self
            cell.clipsToBounds = false
            self.sliderCell = cell
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cellType = (self.availableSections[indexPath.section])![indexPath.row]
        if let cellNibName = cellIdentifiers[cellType], let cellClass = AppUtility.getClassFromName(name: cellNibName) {
            return cellClass.cellHeight()
        }
        return 0
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == self.tableView {
            //stretch slider when bounce up
            let cellSliderHeight = ProductDetailViewSliderTableViewCell.cellHeight() + 23
            var sliderRect = CGRect(x: 0, y:0, width: self.view.frame.width, height: cellSliderHeight)
            if self.tableView.contentOffset.y < 0 {
                self.sliderCell?.blurView?.alpha = 0
                sliderRect.origin.y = self.tableView.contentOffset.y
                sliderRect.size.height = -self.tableView.contentOffset.y + cellSliderHeight
            }
            self.sliderCell?.visibleUIImageView?.frame = sliderRect
            
            //change alpha of slider's blur view
            if self.tableView.contentOffset.y >= 0 && self.tableView.contentOffset.y < cellSliderHeight {
                self.sliderCell?.blurView?.alpha = self.tableView.contentOffset.y / cellSliderHeight
            }
        }
    }
    
    
    private func getContent(completion: ((Bool)-> Void)? = nil) {
        ProductDataManager.sharedInstance.getProductDetailInfo(self, sku: self.product?.sku ?? "") { (data, error) in
            if (error == nil) {
                completion?(true)
                self.bind(data, forRequestId: 0)
            } else {
                completion?(false)
                self.errorHandler(error, forRequestID: 0)
            }
        }
    }
    
    private func updateAvaibleSections() {
        self.availableSections.removeAll()
        if let product = self.product {
            if let imageList = product.imageList, imageList.count > 0 {
                self.availableSections[self.availableSections.count] = [.slider]
            }
        }
    }
    
    override func getScreenName() -> String! {
        return "ProductDetailView"
    }
    
    //MARK: - DataServiceProtocol
    func bind(_ data: Any!, forRequestId rid: Int32) {
        if let product = data as? Product {
            self.product = product
            ThreadManager.execute {
                self.updateAvaibleSections()
                self.tableView.reloadData()
            }
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
        self.getContent { (succes) in
            callBack?(succes)
        }
    }
}

extension ProductDetailViewController: ProductDetailViewSliderTableViewCellDelegate {
    
    func selectSliderItem(item: ProductImageItem, cell: ProductDetailViewSliderTableViewCell) {
        
    }
}
