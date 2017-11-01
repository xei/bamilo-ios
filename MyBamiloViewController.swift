//
//  MyBamiloViewController.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 10/3/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

import UIKit
import EmarsysPredictSDK

protocol MyBamiloViewControllerDelegate: class {
    func scrollViewDidScroll(_ scrollView: UIScrollView)
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool)
    func didSelectProductSku(productSku: String)
}


class MyBamiloViewController:   BaseViewController,
                                EmarsysRecommendationsProtocol,
                                UICollectionViewDelegate,
                                UICollectionViewDataSource,
                                BaseCatallogCollectionViewCellDelegate,
                                UIScrollViewDelegate,
                                MyBamiloHeaderViewDelegate,
                                UIActionSheetDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak private var loadingIndicator: UIActivityIndicatorView!
    
    var recommendationLogic = "HOME"
    
    private let recommendationCountPerLogic :Int32 = 300
    private let categoriesCount = 6
    private let paginationThresholdPoint:CGFloat = 30
    
    private lazy var dataSource = MyBamiloModel()
    private lazy var incomingDataSource = MyBamiloModel()
    private var presentingProducts: [MyBamiloRecommendItem]?
    
    private var recommendationRequestCounts = 0
    private var visibleProductCount = 0
    private var refreshControl: UIRefreshControl?
    private var isRefreshing: Bool = false
    private let headerHeight: CGFloat = 50
    private var selectedLogicID: String?
    
    weak var delegate: MyBamiloViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = Theme.color(kColorGray10)
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
        self.collectionView.register(UINib(nibName: CatalogGridCollectionViewCell.nibName, bundle: nil), forCellWithReuseIdentifier: CatalogGridCollectionViewCell.nibName)
        self.collectionView.register(UINib(nibName: MyBamiloHeaderView.nibName(), bundle: nil), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: MyBamiloHeaderView.nibName())
        
        let flowLayout = GridCollectionViewFlowLayout()
        flowLayout.headerReferenceSize = CGSize(width: self.collectionView.frame.width, height: self.headerHeight)
        self.collectionView.collectionViewLayout = flowLayout
        EmarsysPredictManager.sendTransactions(of: self)
        
        self.refreshControl = UIRefreshControl.init()
        self.refreshControl?.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        if let refreshControl = self.refreshControl {
            self.collectionView.addSubview(refreshControl)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.collectionView.killScroll()
        
        //To prevent refresh control to be visible (and it's gap) for the next time
        self.refreshControl?.endRefreshing()
        self.collectionView.reloadData()
    }
    
    func handleRefresh() {
        self.isRefreshing = true
        self.visibleProductCount = 0
        self.incomingDataSource = MyBamiloModel()
        EmarsysPredictManager.sendTransactions(of: self)
    }
    
    //MARK: - EmarsysPredictProtocolBase
    func getRecommendations() -> [EMRecommendationRequest]! {
        var recommendsRequest = [EMRecommendationRequest]()
        for i in 0...categoriesCount - 1 {
            let recommendReq = EMRecommendationRequest.init(logic: "\(recommendationLogic)_\(i + 1)")
            recommendReq.limit = self.recommendationCountPerLogic
            
            recommendReq.excludeItemsWhere("item", isIn: self.incomingDataSource.filterById(id: "\(recommendationLogic)_\(i + 1)").map { $0.sku })
            recommendReq.completionHandler = { receivedRecs in
                self.processRecommandationResult(result: receivedRecs)
            }
            recommendsRequest.append(recommendReq)
            recommendationRequestCounts += 1
        }
        return recommendsRequest
    }
    
    func isPreventSendTransactionInViewWillAppear() -> Bool {
        return true
    }
    
    private func processRecommandationResult(result: EMRecommendationResult) {
        ThreadManager.execute(onMainThread: {
            self.recommendationRequestCounts -= 1
            let newRecommendedItems = self.incomingDataSource.embedNewRecommends(result: result)
            if newRecommendedItems.count > 0 {
                if self.recommendationRequestCounts == 0 {
                    self.dataSource.topics = self.incomingDataSource.topics
                    self.dataSource.products = self.incomingDataSource.products
                    self.filterProductListById(id: self.selectedLogicID)
                    
                    self.refreshControl?.endRefreshing()
                    
                    //Wait untill all the requests are ready
                    self.loadingIndicator.stopAnimating()
                    self.collectionView.reloadData()
                }
            }
        })
    }
    
    //MARK: - UICollectionViewDelegate, UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.presentingProducts?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: CatalogGridCollectionViewCell.nibName, for: indexPath) as! CatalogGridCollectionViewCell
        if let product = self.presentingProducts?[indexPath.row].convertToProduct() {
            cell.updateWithProduct(product: product)
        }
        cell.cellIndex = indexPath.row
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let sku = self.presentingProducts?[indexPath.row].sku {
            self.delegate?.didSelectProductSku(productSku: sku)
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let headerView = self.collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: MyBamiloHeaderView.nibName(), for: indexPath) as! MyBamiloHeaderView
        headerView.delegate = self
        headerView.setTitle(title: STRING_ALL_CATEGORIES)
        headerView.frame.size.height = self.headerHeight
        return headerView
    }
    
    //MARK: - UIScrollViewDelegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.delegate?.scrollViewDidScroll(scrollView)
        
        let bottomEdge = scrollView.contentOffset.y + scrollView.frame.size.height;
        if (bottomEdge >= (scrollView.contentSize.height - self.paginationThresholdPoint)) {
            // we are approaching at the end of scrollview
            if self.recommendationRequestCounts == 0 {
                EmarsysPredictManager.sendTransactions(of: self) //To get more recommendations
            }
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        self.delegate?.scrollViewDidEndDragging(scrollView, willDecelerate: decelerate)
    }
    
    
    //MARK: - MyBamiloHeaderViewDelegate
    func menuButtonTapped() {
        self.presentActionSheet()
    }
    
    private func presentActionSheet() {
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        //all category action filtert
        let allKeyAction = UIAlertAction(title: STRING_ALL_CATEGORIES, style: .default) { _ in
            self.filterProductListById(id: nil)
            self.collectionView.reloadData()
        }
        optionMenu.addAction(allKeyAction)
        
        //all avaiable actions
        self.dataSource.topics.forEach { (key, value) in
            let action = UIAlertAction(title: key, style: .default) { _ in
                self.filterProductListById(id: value)
                self.collectionView.reloadData()
            }
            optionMenu.addAction(action)
        }
        
        //cancel button
        let cancelAction = UIAlertAction(title: STRING_CANCEL, style: .cancel) { _ in
            print("Cancelled")
        }
        optionMenu.addAction(cancelAction)
        
        let height:NSLayoutConstraint = NSLayoutConstraint(item: optionMenu.view, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: self.view.frame.height * 0.80)
        optionMenu.view.addConstraint(height)
        self.present(optionMenu, animated: true, completion: nil)
    }
    
    private func filterProductListById(id: String?) {
        if let id = id {
            self.presentingProducts = self.dataSource.filterById(id: id)
        } else {
            self.presentingProducts = self.dataSource.products
        }
    }
    
    //MARK: - DataTrackerProtocol
    override func getScreenName() -> String! {
        return "MyBamilo"
    }
    
    //MARK: - NavigationBarProtocol
    override func navBarTitleString() -> String! {
        return STRING_MY_BAMILO
    }
}
