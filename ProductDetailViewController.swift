//
//  ProductDetailViewController.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 5/21/18.
//  Copyright © 2018 Rocket Internet. All rights reserved.
//

import UIKit
import ImageViewer
import Kingfisher

extension UIImageView: DisplaceableView {}

class ProductDetailViewController: BaseViewController, DataServiceProtocol {
    
    var purchaseTrackingInfo: String?
    var product: Product?
    var productSku: String?
    var animator: ZFModalTransitionAnimator?
    
    @IBOutlet weak private var tableView: UITableView!
    @IBOutlet weak private var addToCartButton: IconButton!
    
    
    private var sliderCell: ProductDetailViewSliderTableViewCell?
    private let headerCellIdentifier = "Header"

    enum CellType {
        case slider
        case primaryInfo
        case variation
        case warranty
        case seller
    }
    
    private var availableSections = [Int: [CellType]]()
    let cellIdentifiers : [CellType: String] = [
        .slider:        ProductDetailViewSliderTableViewCell.nibName(),
        .primaryInfo:   ProductDetailPrimaryInfoTableViewCell.nibName(),
        .variation:     ProductVariationTableViewCell.nibName(),
        .warranty:      ProductWarrantyTableViewCell.nibName(),
        .seller:        ProductOldSellerViewTableViewCell.nibName()
    ]
    
    private let sectionNames: [Int: String] = [
        1: STRING_OPTIONS,
        3: STRING_VENDOR
    ]
    
    private lazy var isSectionNameVisible = [Int: Bool]()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.clipsToBounds = true
        self.view.backgroundColor = Theme.color(kColorGray10)
        self.tableView.backgroundColor = Theme.color(kColorGray10)
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.separatorStyle = .none
        self.tableView.clipsToBounds = false
        self.tableView.showsVerticalScrollIndicator = false
        self.tableView.showsHorizontalScrollIndicator = false
        
        self.addToCartButton.applyStyle(font: Theme.font(kFontVariationRegular, size: 13), color: .white)
        self.addToCartButton.setTitle(STRING_ADD_TO_SHOPPING_CART, for: .normal)
        self.addToCartButton.backgroundColor = Theme.color(kColorOrange1)
        
        // remove extra white gaps between sections & top and bottom of tableview
        self.tableView.sectionFooterHeight = 0
        
        cellIdentifiers.forEach { (cellId) in
            self.tableView.register(UINib(nibName: cellId.value, bundle: nil), forCellReuseIdentifier: cellId.value)
        }

        self.tableView.register(UINib(nibName: TransparentHeaderHeaderTableView.nibName(), bundle: nil), forHeaderFooterViewReuseIdentifier: headerCellIdentifier)
        self.tableView.tableFooterView = UIView(frame: .zero)
        
        if let product = product, product.loadedComprehensively {
            updateViewByProduct(product: product)
        } else {
            self.getContent()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
        self.tabBarController?.tabBar.layer.zPosition = -1
        self.hidesBottomBarWhenPushed = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
        self.tabBarController?.tabBar.layer.zPosition = 0
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == self.tableView {
            //stretch slider when bounce up
            let cellSliderHeight = ProductDetailViewSliderTableViewCell.cellHeight() + 23 //bottom gap under the cell (slider)
            var sliderRect = CGRect(x: 0, y:0, width: self.view.frame.width, height: cellSliderHeight - 20) //slider image vertical gap
            if self.tableView.contentOffset.y < 0 {
                sliderCell?.blurView?.alpha = 0
                sliderRect.origin.y = self.tableView.contentOffset.y
                sliderRect.size.height = -self.tableView.contentOffset.y + cellSliderHeight - 20 //slider image vertical gap
                sliderCell?.buttonsTopConstraint.constant = 10 + self.tableView.contentOffset.y
            } else {
                sliderCell?.buttonsTopConstraint.constant = 10
            }
            
            if self.tableView.contentOffset.y >= 0 && self.tableView.contentOffset.y < cellSliderHeight {
                //parallax behaviour for slider image
                sliderRect.origin.y = self.tableView.contentOffset.y / 2
                
                //change alpha of slider's blur view
                self.sliderCell?.blurView?.alpha = self.tableView.contentOffset.y / cellSliderHeight
            }
            sliderCell?.visibleUIImageView?.frame = sliderRect
            sliderCell?.blurView?.frame = sliderRect
        }
    }
    
    
    private func getContent(completion: ((Bool)-> Void)? = nil) {
        ProductDataManager.sharedInstance.getProductDetailInfo(self, sku: product?.sku ?? productSku ??  "") { (data, error) in
            if (error == nil) {
                self.bind(data, forRequestId: 0)
                completion?(true)
            } else {
                self.errorHandler(error, forRequestID: 0)
                completion?(false)
            }
        }
    }
    
    private func updateAvaibleSections() {
        self.availableSections.removeAll()
        if let product = self.product {
            
            //Slider & Primary informations
            if let imageList = product.imageList, imageList.count > 0 {
                self.availableSections[self.availableSections.count] = [.slider, .primaryInfo]
            } else {
                self.availableSections[self.availableSections.count] = [.primaryInfo]
            }
            
            //Variation of product
            self.availableSections[self.availableSections.count] = [.variation]
            self.availableSections[self.availableSections.count] = [.warranty]
            
            if let simplesCount = product.simples?.count, simplesCount > 0 {
                self.isSectionNameVisible[self.availableSections.count - 1] = true
            } else if let variationCount = product.variations?.count, variationCount > 1 {
                self.isSectionNameVisible[self.availableSections.count - 1] = true
            } else {
                self.isSectionNameVisible[self.availableSections.count - 1] = false
            }
            
            //Seller
            if let _ = product.seller {
                self.availableSections[self.availableSections.count] = [.seller]
                self.isSectionNameVisible[self.availableSections.count - 1] = true
            }
        }
    }
    
    private func updateViewByProduct(product: Product) {
        self.product = product
        self.title = product.name
        ThreadManager.execute {
            self.updateAvaibleSections()
            self.tableView.reloadData()
        }
    }
    
    override func getScreenName() -> String! {
        return "ProductDetailView"
    }
    
    //MARK: - DataServiceProtocol
    func bind(_ data: Any!, forRequestId rid: Int32) {
        if let product = data as? Product {
            product.loadedComprehensively = true
            let simple = SimpleProduct()
            simple.sku = product.sku
            simple.price = product.price
            simple.image = product.imageList?.first?.normal
            
            product.variations = product.variations ?? [SimpleProduct]()
            product.variations?.insert(simple, at: 0)
            updateViewByProduct(product: product)
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
    
    @IBAction func addToCartButtonTapped(_ sender: Any) {
        if let simples = product?.simples {
            if simples.count >= 1 {
                let selectedSimple = simples.filter { $0.isSelected }.first
                if let selectedSimple = selectedSimple {
                    requestAddToCart(simpleSku: selectedSimple.sku)
                } else {
                    self.performSegue(withIdentifier: "showAddToCartModal", sender: nil)
                }
            }
        }
    }
    
    private func requestAddToCart(simpleSku: String) {
        if let productEntity = self.product {
            ProductDataManager.sharedInstance.addToCart(simpleSku: simpleSku, product: productEntity, viewCtrl: self)
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let segueName = segue.identifier
        if segueName == "showAddToCartModal", let addToCartViewController = segue.destination as? AddToCartViewController {
            addToCartViewController.product = self.product
            self.animator = ZFModalTransitionAnimator(modalViewController: addToCartViewController)
            animator?.isDragable = true
            animator?.bounces = true
            animator?.behindViewAlpha = 0.8
            animator?.behindViewScale = 0.9
            animator?.transitionDuration = 0.7
            animator?.direction = .bottom
            addToCartViewController.modalPresentationStyle = .overCurrentContext
            addToCartViewController.delegate = self
            addToCartViewController.transitioningDelegate = animator
        }
    }
    
    
    override func navBarleftButton() -> NavBarButtonType {
        return .cart
    }
}

extension ProductDetailViewController: ProductDetailViewSliderTableViewCellDelegate {
    
    func addOrRemoveFromWishList(product: Product, cell: ProductDetailViewSliderTableViewCell, add: Bool) {
        ProductDataManager.sharedInstance.addOrRemoveFromWishList(product: product, in: self, add: add) { (success, error) in
            self.sliderCell?.wishListButton.isSelected = product.isInWishList
        }
    }
    
    func selectSliderItem(item: ProductImageItem, atIndex: Int, cell: ProductDetailViewSliderTableViewCell) {
        let galleryViewController = GalleryViewController(startIndex: atIndex, itemsDataSource: self, displacedViewsDataSource: self, configuration: self.galleryConfiguration())
        galleryViewController.landedPageAtIndexCompletion = { self.sliderCell?.selectIndex(index: $0, animated: false) }
        self.presentImageGallery(galleryViewController)
    }
    
    func shareButtonTapped() {
        if let url = self.product?.shareURL, let name = product?.name {
            Utility.shareUrl(url: url, message: name, viewController: self)
        }
    }
}


extension ProductDetailViewController: UITableViewDataSource, UITableViewDelegate {
    
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
            cell.delegate = self
            cell.clipsToBounds = false
            cell.update(withModel: product)
            cell.layer.zPosition = -100
            self.sliderCell = cell
            return cell
            
        case .primaryInfo, .variation, .warranty, .seller:
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! BaseProductTableViewCell
            cell.update(withModel: product)
            
            if cellType == .variation {
                (cell as? ProductVariationTableViewCell)?.delegate = self
            }
            
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
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let name = self.sectionNames[section], let isVisible = isSectionNameVisible[section], isVisible {
            let header = self.tableView.dequeueReusableHeaderFooterView(withIdentifier: headerCellIdentifier) as! TransparentHeaderHeaderTableView
            header.titleString  = name
            return header
        }
        return UIView(frame: .zero)
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if let _ = self.sectionNames[section], let isVisible = isSectionNameVisible[section], isVisible {
            return TransparentHeaderHeaderTableView.cellHeight()
        }
        
        //first section (slider) must not have height
        //minimom acceptable height for header is 1 (apple Api) (for grouped tableview)
        return section == 0 ? 1 : 10
    }
}

//Image Gallery
extension ProductDetailViewController: GalleryItemsDataSource, GalleryDisplacedViewsDataSource {
    
    func galleryConfiguration() -> GalleryConfiguration {
        return [
            GalleryConfigurationItem.closeButtonMode(.builtIn),
            GalleryConfigurationItem.pagingMode(.standard),
            GalleryConfigurationItem.presentationStyle(.displacement),
            GalleryConfigurationItem.hideDecorationViewsOnLaunch(false),
            GalleryConfigurationItem.swipeToDismissMode(.vertical),
            GalleryConfigurationItem.toggleDecorationViewsBySingleTap(false),
            GalleryConfigurationItem.activityViewByLongPress(false),
            GalleryConfigurationItem.overlayColor(.white),
            GalleryConfigurationItem.overlayColorOpacity(1),
            GalleryConfigurationItem.overlayBlurOpacity(1),
            GalleryConfigurationItem.overlayBlurStyle(UIBlurEffectStyle.light),
            GalleryConfigurationItem.videoControlsColor(.white),
            GalleryConfigurationItem.maximumZoomScale(8),
            GalleryConfigurationItem.swipeToDismissThresholdVelocity(500),
            GalleryConfigurationItem.doubleTapToZoomDuration(0.15),
            GalleryConfigurationItem.blurPresentDuration(0.5),
            GalleryConfigurationItem.blurPresentDelay(0),
            GalleryConfigurationItem.colorPresentDuration(0.25),
            GalleryConfigurationItem.colorPresentDelay(0),
            GalleryConfigurationItem.blurDismissDuration(0.1),
            GalleryConfigurationItem.blurDismissDelay(0.4),
            GalleryConfigurationItem.colorDismissDuration(0.45),
            GalleryConfigurationItem.colorDismissDelay(0),
            GalleryConfigurationItem.itemFadeDuration(0.3),
            GalleryConfigurationItem.decorationViewsFadeDuration(0.15),
            GalleryConfigurationItem.rotationDuration(0.15),
            GalleryConfigurationItem.displacementDuration(0.55),
            GalleryConfigurationItem.reverseDisplacementDuration(0.25),
            GalleryConfigurationItem.displacementTransitionStyle(.springBounce(0.7)),
            GalleryConfigurationItem.displacementTimingCurve(.linear),
            GalleryConfigurationItem.thumbnailsButtonMode(.none),
            GalleryConfigurationItem.deleteButtonMode(.none),
            GalleryConfigurationItem.statusBarHidden(true),
            GalleryConfigurationItem.displacementKeepOriginalInPlace(false),
            GalleryConfigurationItem.displacementInsetMargin(50)
        ]
    }
    
    func itemCount() -> Int {
        return self.product?.imageList?.count ?? 0
    }
    
    func provideGalleryItem(_ index: Int) -> GalleryItem {
        if let imageList = self.product?.imageList, index < imageList.count, let url = imageList[index].zoom {
            return GalleryItem.image { callback in
                KingfisherManager.shared.retrieveImage(with: url, options: [.transition(.fade(0.20))], progressBlock: nil, completionHandler: { (image, error, cacheType, url) in
                    callback(image)
                })
            }
        }
        return GalleryItem.image(fetchImageBlock: { (calback) in })
    }
    
    func provideDisplacementItem(atIndex index: Int) -> DisplaceableView? {
        return self.sliderCell?.visibleUIImageView
    }
}


extension ProductDetailViewController: AddToCartViewControllerDelegate {
    
    func didSelectVariationSku(product: SimpleProduct, completionHandler:@escaping ((_ prodcut: Product)->Void)) {
        //if we are in the same page of product
        if let sku = self.product?.sku, product.sku == sku { return }
        if let sku = self.productSku, product.sku == sku { return }

        self.productSku = product.sku
        self.product = nil
        self.getContent { (sucecss) in
            if sucecss {
                self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
                if let product = self.product {
                    completionHandler(product)
                }
            }
        }
    }
    
    func didSelectSimpleSkuFromAddToCartView(product: SimpleProduct) {
        //update cells which have the variations
        availableSections.forEach { (section, rows) in
            if let row = rows.index(of: .variation) {
                if let isInVisiableRect = tableView.indexPathsForVisibleRows?.contains(IndexPath(row: row, section: section)), isInVisiableRect {
                    tableView.reloadRows(at: [IndexPath(row: row, section: section)], with: UITableViewRowAnimation.fade)
                }
            }
        }
    }
    
    func submitAddToCartSimple(product: SimpleProduct) {
        self.requestAddToCart(simpleSku: product.sku)
    }
    
}


extension ProductDetailViewController: ProductVariationTableViewCellDelegate {
    func didSelectVariationSku(product: SimpleProduct, cell: ProductVariationTableViewCell) {
        
        //if we are in the same page of product
        if let sku = self.product?.sku, product.sku == sku { return }
        if let sku = self.productSku, product.sku == sku { return }
        
        let productDetailViewCtrl =  ViewControllerManager.sharedInstance().loadViewController("ProductDetailViewController") as! ProductDetailViewController
        productDetailViewCtrl.productSku = product.sku
        productDetailViewCtrl.purchaseTrackingInfo = self.purchaseTrackingInfo
        self.navigationController?.pushViewController(productDetailViewCtrl, animated: true)
    }
}

