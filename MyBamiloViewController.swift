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
                                UIScrollViewDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak private var loadingIndicator: UIActivityIndicatorView!
    
    private let recommendationCountPerLogic :Int32 = 300
    private let categoriesCount = 6
    private let paginationThresholdPoint:CGFloat = 30
    
    private lazy var dataSource = MyBamiloModel()
    private var recommendationRequestCounts = 0
    private var visibleProductCount = 0
    
    weak var delegate: MyBamiloViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = Theme.color(kColorGray10)
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
        self.collectionView.register(UINib(nibName: CatalogGridCollectionViewCell.nibName, bundle: nil), forCellWithReuseIdentifier: CatalogGridCollectionViewCell.nibName)
        
        self.collectionView.collectionViewLayout = GridCollectionViewFlowLayout()
        EmarsysPredictManager.sendTransactions(of: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.collectionView.killScroll()
    }
    
    //MARK: - EmarsysPredictProtocolBase
    func getRecommendations() -> [EMRecommendationRequest]! {
        var recommendsRequest = [EMRecommendationRequest]()
        for i in 0...categoriesCount - 1 {
            let recommendReq = EMRecommendationRequest.init(logic: "HOME_\(i + 1)")
            recommendReq.limit = self.recommendationCountPerLogic
            
            recommendReq.excludeItemsWhere("item", isIn: self.dataSource.filterById(id: "HOME_\(i + 1)").map { $0.sku })
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
            let newRecommendedItems = self.dataSource.embedNewRecommends(result: result)
            if newRecommendedItems.count > 0 {
                if self.recommendationRequestCounts == 0 {
                    //Wait untill all the requests are ready
                    self.loadingIndicator.stopAnimating()
                    var newIndexPathes = [IndexPath]()
                    for index in 0...self.dataSource.products.count - self.visibleProductCount - 1 {
                        let newIndex = self.visibleProductCount + index
                        newIndexPathes.append(IndexPath(item: newIndex, section: 0))
                    }
                    self.collectionView.performBatchUpdates({
                        self.collectionView.insertItems(at: newIndexPathes)
                    }, completion: { (finished) in
                        self.visibleProductCount = self.dataSource.products.count
                    })
                }
            }
        })
    }
    
    //MARK: - UICollectionViewDelegate, UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.dataSource.products.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: CatalogGridCollectionViewCell.nibName, for: indexPath) as! CatalogGridCollectionViewCell
        cell.updateWithProduct(product: self.dataSource.products[indexPath.row].convertToProduct())
        cell.cellIndex = indexPath.row
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.delegate?.didSelectProductSku(productSku: self.dataSource.products[indexPath.row].sku)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
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
    
    //MARK: - NavigationBarProtocol
    override func navBarTitleString() -> String! {
        return STRING_MY_BAMILO
    }
}
