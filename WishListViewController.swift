//
//  WishListViewController.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 11/18/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

import UIKit
import TBActionSheet

class WishListViewController: BaseViewController,
                                UICollectionViewDelegate,
                                UICollectionViewDataSource,
                                DataServiceProtocol,
                                UIScrollViewDelegate,
                                WishListCollectionViewCellDelegate,
                                UINavigationControllerDelegate {

    @IBOutlet weak private var collectionView: UICollectionView!
    @IBOutlet weak private var emptyViewContainer: UIView!
    
    private let perPageProductCount = 20
    private let paginationThresholdPoint: CGFloat = 100
    
    private var emptyController: EmptyViewController?
    private var refreshControl: UIRefreshControl?
    private var page: Int = 1
    private var isLoading: Bool = false {
        didSet {
            //To refresh the footerView
            self.collectionView.collectionViewLayout.invalidateLayout()
        }
    }
    private var isRefreshing: Bool = false
    private var wishList: WishList?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        CurrentUserManager.loadLocal()
        self.view.backgroundColor = Theme.color(kColorVeryLightGray)
        self.collectionView.backgroundColor = .clear
        
        self.emptyViewContainer.isHidden = true
        let flowLayout = ListCollectionViewFlowLayout()
        self.collectionView.collectionViewLayout = flowLayout
        self.collectionView.register(WishListCollectionViewCell.nibInstance, forCellWithReuseIdentifier: WishListCollectionViewCell.nibName)
        self.collectionView.register(CollectionViewLoadingFooter.nibInstance, forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: CollectionViewLoadingFooter.nibName())
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.clipsToBounds = false
        
        self.collectionView.contentInset = UIEdgeInsets(top: flowLayout.cellSpacing, left: 0, bottom: flowLayout.cellSpacing, right: 0)
        
        self.collectionView.showsVerticalScrollIndicator = false
        self.collectionView.showsHorizontalScrollIndicator = false
        
        self.refreshControl = UIRefreshControl.init()
        self.refreshControl?.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        if let refreshControl = self.refreshControl {
            self.collectionView.addSubview(refreshControl)
        }
        self.collectionView.alwaysBounceVertical = true
        NotificationCenter.default.addObserver(self, selector: #selector(userLogout(notification:)), name: NSNotification.Name(rawValue: NotificationKeys.UserLoggedOut), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !CurrentUserManager.isUserLoggedIn() {
            (self.navigationController as? JACenterNavigationController)?.requestForcedLogin(completion: {
                self.refreshAndReload {(success) in
                    //Do nothing
                }
            })
            return
        }
        self.refreshAndReload {(sucess) in
            //Do nothing
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func loadProducts(page: Int, callBack:((Bool)->Void)? = nil) {
        if isLoading { return }
        if let lastPage = self.wishList?.lastPage ,(lastPage != 0 && page > lastPage) { return }
        self.isLoading = true
        self.refreshControl?.beginRefreshing()
        ProductDataManager.sharedInstance.getWishListProducts(self, page: page, perPageCount: perPageProductCount) { (data, error) in
            self.isLoading = false
            self.refreshControl?.endRefreshing()
            if let error = error {
                callBack?(false)
                self.errorHandler(error, forRequestID: 0)
                return
            }
            self.bind(data, forRequestId: 0)
            callBack?(true)
        }
    }
    
    private func loadMore() {
        if isLoading || self.wishList == nil || self.wishList?.products.count == 0 { return }
        self.page += 1
        self.loadProducts(page: page)
    }
    
    @objc private func handleRefresh() {
        self.refreshAndReload { (success) in
        }
        self.isLoading = false
    }
    
    private func refreshAndReload(callBack: @escaping ((Bool)->Void)) {
        self.page = 1
        self.recordStartLoadTime()
        self.isRefreshing = true
        self.wishList?.products.removeAll()
        self.collectionView.reloadData()
        self.loadProducts(page: page) { (success) in
            self.publishScreenLoadTime(withName: self.getScreenName(), withLabel: "")
            callBack(success)
        }
    }
    
    //MARK: - UICollectionViewDelegate & UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: WishListCollectionViewCell.nibName, for: indexPath) as! WishListCollectionViewCell
        cell.wishListItemDelegate = self
        cell.cellIndex = indexPath.row
        if let products = self.wishList?.products, indexPath.row < products.count {
            cell.updateWithProduct(product: products[indexPath.row])
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.wishList?.products.count ?? 0
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let footerView = self.collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionFooter, withReuseIdentifier: CollectionViewLoadingFooter.nibName(), for: indexPath)
        return footerView
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize(width: self.collectionView.frame.width, height: self.isLoading ? CollectionViewLoadingFooter.viewHeight : 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let product = self.wishList?.products[indexPath.row] {
            self.performSegue(withIdentifier: "showPDVViewController", sender: product.sku)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let bottomEdge = scrollView.contentOffset.y + scrollView.frame.size.height
        if (bottomEdge >= (scrollView.contentSize.height - paginationThresholdPoint)) {
            // we are approaching at the end of scrollview
            self.loadMore()
        }
    }
    
    
    //MARK: - WishListCollectionViewCellDelegate
    func addToCart(product: Product, cell: WishListCollectionViewCell) {
        if let simples = product.simples, simples.count == 1 {
            self.addToCart(product: product, simpleSku: simples[0].sku)
        } else if let simples = product.simples, simples.count > 1 {
            self.presentActionSheet(product: product)
        }
    }
    
    func remove(product: Product, cell: WishListCollectionViewCell) {
        AlertManager.sharedInstance().confirmAlert(STRING_REMOVE_FAVOURITES, text: STRING_REMOVE_FAVOURITES_DESCRIPTION, confirm: STRING_YES, cancel: STRING_NO) { (confirm) in
            if confirm {
                self.removeFromWishList(product: product, cell: cell)
            }
        }
    }
    
    func share(product: Product, cell: WishListCollectionViewCell) {
        //we should share the product here
        if let url = product.shareURL, let name = product.name {
            Utility.shareUrl(url: url, message: name, viewController: self)
        }
    }
    
    //MARK: - Helper functions
    private func presentActionSheet(product: Product) {
        let optionMenu = TBActionSheet()
        
        var avaiableSimpleProduct: SimpleProduct?
        //all avaiable simple products
        product.simples?.forEach({ (simpleProduct) in
            if simpleProduct.quantity > 0 { //if this simple product is available
                avaiableSimpleProduct = simpleProduct
                optionMenu.addButton(withTitle: simpleProduct.variationValue, style: .default, handler: { (_) in
                    self.addToCart(product: product, simpleSku: simpleProduct.sku)
                })
            }
        })
        //if we have only one avaiable simple product
        if let avaiableProduct = avaiableSimpleProduct, optionMenu.numberOfButtons == 1 {
            self.addToCart(product: product, simpleSku: avaiableProduct.sku)
            return
        }
        optionMenu.ambientColor = .white
        optionMenu.destructiveButtonColor = Theme.color(kColorDarkGreen)
        optionMenu.tintColor = Theme.color(kColorGray1)
        optionMenu.buttonFont = Theme.font(kFontVariationRegular, size: 13)
        optionMenu.rectCornerRadius = 0
        optionMenu.buttonHeight = 45
        optionMenu.setupLayout()
        optionMenu.setupContainerFrame()
        optionMenu.setupStyle()
        optionMenu.show()
    }
    
    private func addToCart(product: Product, simpleSku: String) {
        ProductDataManager.sharedInstance.addToCart(simpleSku: simpleSku, product: product, viewCtrl: self)
    }
    
    private func removeFromWishList(product: Product, cell: WishListCollectionViewCell) {
        DeleteEntityDataManager.sharedInstance().removeFromWishList(self, sku: product.sku) { (data, error) in
            if error != nil {
                Utility.handleErrorMessages(error: error, viewController: self)
                return
            }
            if self.isRefreshing { return  }
            if let index = self.wishList?.products.index(of: product) {
                self.wishList?.products.remove(at: index)
            }
            if let indexPath = self.collectionView.indexPath(for: cell) {
                self.collectionView.performBatchUpdates({
                    self.collectionView.deleteItems(at: [indexPath])
                }, completion: {(finished) in
                    self.isLoading = false
                })
            } else {
                self.collectionView.reloadData()
            }
            
            if let receivedData = data as? [String: Any], let messages = receivedData[DataManagerKeys.DataMessages] {
                self.showMessage(self.extractSuccessMessages(messages), showMessage: true)
            }
            
            self.showEmptyViewIfItsNeeded()
            
            TrackerManager.postEvent(selector: EventSelectors.removeFromWishListSelector(), attributes: EventAttributes.removeFromWishList(product: product, screenName: self.getScreenName()))
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationKeys.WishListUpdate), object: nil, userInfo: [NotificationKeys.NotificationProduct: product, NotificationKeys.NotificationBool: false])
        }
    }
    
    @objc private func userLogout(notification: Notification) {
        self.wishList?.products.removeAll()
        self.collectionView.reloadData()
    }
    
    //MARK: - DataServiceProtocol
    func bind(_ data: Any!, forRequestId rid: Int32) {
        if isRefreshing {
            self.wishList?.products.removeAll()
        }
        if let receivedWishList = data as? WishList {
            if let products = self.wishList?.products, products.count > 0 {
                var newIndexPathes = [IndexPath]()
                for index in 0...receivedWishList.products.count - 1 {
                    let newIndex = products.count + index
                    newIndexPathes.append(IndexPath(item: newIndex, section: 0))
                    self.wishList?.products.insert(receivedWishList.products[index], at: newIndex)
                }
                self.collectionView.performBatchUpdates({
                    self.collectionView.insertItems(at: newIndexPathes)
                }, completion: {(finished) in
                    self.isLoading = false
                })
            } else {
                self.wishList = receivedWishList
                self.collectionView.reloadData()
                self.isLoading = false
                if self.isRefreshing {
                    self.isRefreshing = false
                }
                
                self.showEmptyViewIfItsNeeded()
            }
        }
    }
    func retryAction(_ callBack: RetryHandler!, forRequestId rid: Int32) {
        self.refreshAndReload { (success) in
            callBack(success)
        }
    }
    
    func errorHandler(_ error: Error!, forRequestID rid: Int32) {
        if !Utility.handleErrorMessages(error: error, viewController: self) {
            self.handleGenericErrorCodesWithErrorControlView(Int32(error.code), forRequestID: rid)
        }
    }
    
    private func showEmptyViewIfItsNeeded() {
        if self.wishList == nil || self.wishList?.products.count == 0 {
            self.emptyViewContainer.fadeIn(duration: 0.15)
            self.emptyController?.getSuggestions()
        } else {
            self.emptyViewContainer.hide()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let segueName = segue.identifier
        
        if segueName == "embedEmptyViewController" {
            let destinationViewCtrl = segue.destination as? EmptyViewController
            self.emptyController = destinationViewCtrl
            self.emptyController?.updateTitle(STRING_NO_SAVED_ITEMS_FAVOURITES)
            self.emptyController?.recommendationLogic = "POPULAR"
            self.emptyController?.parentScreenName = self.getScreenName()
            self.emptyController?.update(UIImage(named: "emptyFavoritesIcon"))
        }
        if segueName == "showPDVViewController", let pdvViewCtrl = segue.destination as? ProductDetailViewController, let sku = sender as? String {
            pdvViewCtrl.productSku = sku
            pdvViewCtrl.hidesBottomBarWhenPushed = true
        }
    }
    
    //MARK: - DataTrackerProtocol
    override func getScreenName() -> String! {
        return "WishList"
    }
    
    //MARK: - NavigationBarProtocol
    override func navBarTitleString() -> String! {
        return STRING_FAVOURITES
    }
}
