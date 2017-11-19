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
                                WishListCollectionViewCellDelegate {

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
        self.refreshControl?.addTarget(self, action: #selector(refreshAndReload), for: .valueChanged)
        if let refreshControl = self.refreshControl {
            self.collectionView.addSubview(refreshControl)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !RICustomer.checkIfUserIsLogged() {
            (self.navigationController as? JACenterNavigationController)?.requestForcedLogin()
            return
        }
        self.refreshAndReload()
    }
    
    
    private func loadProducts(page: Int) {
        if isLoading { return }
        if let lastPage = self.wishList?.lastPage ,page > lastPage { return }
        self.isLoading = true
        ProductDataManager.sharedInstance.getWishListProducts(self, page: page, perPageCount: perPageProductCount) { (data, error) in
            if let error = error {
                Utility.handleError(error: error, viewController: self)
                return
            }
            self.bind(data, forRequestId: 0)
        }
    }
    
    private func loadMore() {
        if isLoading || self.wishList == nil || self.wishList?.products.count == 0 { return }
        self.page += 1
        self.loadProducts(page: page)
    }
    
    @objc private func refreshAndReload() {
        self.page = 1
        self.isRefreshing = true
        self.loadProducts(page: page)
    }
    
    //MARK: - UICollectionViewDelegate & UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: WishListCollectionViewCell.nibName, for: indexPath) as! WishListCollectionViewCell
        cell.wishListItemDelegate = self
        cell.cellIndex = indexPath.row
        if let product = self.wishList?.products[indexPath.row] {
            cell.updateWithProduct(product: product)
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
        AlertManager.sharedInstance().confirmAlert(STRING_REMOVE_FAVOURITES, text: STRING_REMOVE_FAVOURITES_DESCRIPTION, confirm: STRING_OK, cancel: STRING_CANCEL) { (confirm) in
            if confirm {
                self.removeFromWishList(product: product, cell: cell)
            }
        }
    }
    
    func share(product: Product, cell: WishListCollectionViewCell) {
        //we should share the product here
    }
    
    //MARK: - Helper functions
    private func presentActionSheet(product: Product) {
        let optionMenu = TBActionSheet()
        //all avaiable simple products
        product.simples?.forEach({ (simpleProduct) in
            if simpleProduct.quantity > 0 { //if this simple product is available
                optionMenu.addButton(withTitle: simpleProduct.variationValue, style: .default, handler: { (_) in
                    self.addToCart(product: product, simpleSku: simpleProduct.sku)
                })
            }
        })
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
        CartDataManager.sharedInstance.addProductToCart(self, simpleSku: simpleSku) { (data, error) in
            if error != nil {
                Utility.handleError(error: error, viewController: self)
                return
            }
            
            //TODO: temprory code, when we migrate RIProduct to Product these code must be removed
            let convertedProduct = RIProduct()
            convertedProduct.sku = product.sku
            convertedProduct.price = NSNumber(value: product.price ?? 0)
            
            //EVENT: ADD TO CART
            TrackerManager.postEvent(selector: EventSelectors.addToCartEventSelector(), attributes: EventAttributes.addToCard(product: convertedProduct, screenName: self.getScreenName(), success: true))
            
            if let receivedData = data as? [String: Any], let messages = receivedData[DataManagerKeys.DataMessages] {
                self.showMessage(self.extractSuccessMessages(messages), showMessage: true)
            }
            
            if let receivedData = data as? [String: Any], let cart = receivedData[DataManagerKeys.DataContent] as? RICart {
                NotificationCenter.default.post(name: NSNotification.Name(NotificationKeys.UpdateCart), object: nil, userInfo: ["NOTIFICATION_UPDATE_CART_VALUE" : cart])
            }
        }
    }
    
    private func removeFromWishList(product: Product, cell: WishListCollectionViewCell) {
        DeleteEntityDataManager.sharedInstance().removeFromWishList(self, sku: product.sku) { (data, error) in
            if error != nil {
                Utility.handleError(error: error, viewController: self)
                return
            }
            
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
            
            //TODO: temprory code, when we migrate RIProduct to Product these code must be removed
            let convertedProduct = RIProduct()
            convertedProduct.sku = product.sku
            convertedProduct.price = NSNumber(value: product.price ?? 0)
            
            TrackerManager.postEvent(selector: EventSelectors.removeFromWishListSelector(), attributes: EventAttributes.removeFromWishList(product: convertedProduct, screenName: self.getScreenName()))
        }
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
                    self.refreshControl?.endRefreshing()
                    self.isRefreshing = false
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let segueName = segue.identifier
        if segueName == "embedEmptyViewController" {
            let destinationViewCtrl = segue.destination as? EmptyViewController
            self.emptyController = destinationViewCtrl
        }
        if segueName == "showPDVViewController", let pdvViewCtrl = segue.destination as? JAPDVViewController, let sku = sender as? String {
            pdvViewCtrl.productSku = sku
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
