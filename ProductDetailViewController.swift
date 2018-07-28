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

@objcMembers class ProductDetailViewController: BaseViewController, DataServiceProtocol {
    
    var purchaseTrackingInfo: String?
    var product: NewProduct?
    var productSku: String?
    var animator: ZFModalTransitionAnimator?
    
    @IBOutlet weak private var tableView: UITableView!
    @IBOutlet weak private var addToCartButton: IconButton!
    
    private var sliderCell: ProductDetailViewSliderTableViewCell?
    private let headerCellIdentifier = "Header"
    private var recommendItems: [RecommendItem]?
    private var calculatedDeliveryTimeMessage: String?
    
    enum CellType {
        case slider
        case primaryInfo
        case variation
        case warranty
        case seller
        case reviewSummery
        case emptyReview
        case relatedItems
        case breadcrumbs
    }
    
    private var availableSections = [Int: [CellType]]()
    let cellIdentifiers : [CellType: String] = [
        .slider:        ProductDetailViewSliderTableViewCell.nibName(),
        .primaryInfo:   ProductDetailPrimaryInfoTableViewCell.nibName(),
        .variation:     ProductVariationTableViewCell.nibName(),
        .warranty:      ProductWarrantyTableViewCell.nibName(),
        .seller:        ProductOldSellerViewTableViewCell.nibName(),
        .reviewSummery: ProductReviewSummeryTableViewCell.nibName(),
        .relatedItems : ProductRecommendationWidgetTableViewCell.nibName(),
        .breadcrumbs:   ProductBreadCrumbTableViewCell.nibName(),
        .emptyReview:   ProductEmptyReviewTableViewCell.nibName()
    ]
    
    private var sectionNames = [Int: String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.clipsToBounds = true
        self.view.backgroundColor = Theme.color(kColorGray)
        self.tableView.backgroundColor = Theme.color(kColorGray)
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
        super.viewWillAppear(animated)
        self.hidesBottomBarWhenPushed = true
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
                
                if self.tableView.contentOffset.y < -100  {
                    self.sliderCell?.openCurrentImage()
                }
                
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
                
                //request for emarsys recommendations
                EmarsysPredictManager.sendTransactions(of: self)
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
            if let sizeProducts = product.sizeVariaionProducts, sizeProducts.count > 0 {
                self.sectionNames[self.availableSections.count] = STRING_OPTIONS
            } else if let otherVariationProducts = product.OtherVariaionProducts, otherVariationProducts.count > 0 {
                self.sectionNames[self.availableSections.count] = STRING_OPTIONS
            }
            
            self.availableSections[self.availableSections.count] = [.variation]
            self.availableSections[self.availableSections.count] = [.warranty]
            
            //Seller
            if let _ = product.seller {
                self.sectionNames[self.availableSections.count] = STRING_VENDOR
                self.availableSections[self.availableSections.count] = [.seller]
            }
            
            //rate & review
            self.sectionNames[self.availableSections.count] = STRING_RATE_AND_REVIEW
            if let _ = product.ratings, let reviewItems = product.reviews?.items, reviewItems.count > 0 {
                self.availableSections[self.availableSections.count] = [.reviewSummery]
            } else {
                self.availableSections[self.availableSections.count] = [.emptyReview]
            }
            
            //related items
            if let items = self.recommendItems, items.count > 0 {
                self.sectionNames[self.availableSections.count] = STRING_RELATED_ITEMS
                self.availableSections[self.availableSections.count] = [.relatedItems]
            }
            
            //breadcrumbs
            if let items = self.product?.breadCrumbs, items.count > 0 {
                self.availableSections[self.availableSections.count] = [.breadcrumbs]
            }
        }
    }
    
    private func updateViewByProduct(product: NewProduct) {
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
        if let product = data as? NewProduct {
            product.loadedComprehensively = true
            
            if let variations = self.product?.variations {
                //keep the previous variations to prevent refreshing the variations (view)
                product.variations = variations
            }
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
        if let variations = product?.variations, variations.count >= 1 {
            let sizeVariations = variations.filter { $0.type == .size }.first
            let selectedSize = sizeVariations?.products?.filter { $0.isSelected }.first
            if let selectedSizeSimpleSku = selectedSize?.simpleSku {
                requestAddToCart(simpleSku: selectedSizeSimpleSku, inViewCtrl: self)
            } else if let sizeVariationProducts = sizeVariations?.products, sizeVariationProducts.count > 0 {
                self.performSegue(withIdentifier: "showAddToCartModal", sender: nil)
            } else if let simpleSku = self.product?.simpleSku {
                requestAddToCart(simpleSku: simpleSku, inViewCtrl: self)
            }
        }
    }
    
    private func requestAddToCart<T: BaseViewController & DataServiceProtocol>(simpleSku: String, inViewCtrl: T) {
        if let productEntity = self.product {
            ProductDataManager.sharedInstance.addToCart(simpleSku: simpleSku, product: productEntity, viewCtrl: inViewCtrl) { (success, error) in
                if let info = self.purchaseTrackingInfo, success {
                    PurchaseBehaviourRecorder.sharedInstance.recordAddToCart(sku: productEntity.sku, trackingInfo: info)
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let segueName = segue.identifier
        if segueName == "showAddToCartModal", let addToCartViewController = segue.destination as? AddToCartViewController {
            prepareAddToCartView(addToCartViewController: addToCartViewController)
        } else if segueName == "showProductMoreInfoViewController", let viewCtrl = segue.destination as? ProductMoreInfoViewController {
            viewCtrl.selectedViewType = sender as? MoreInfoSelectedViewType ?? .description
            viewCtrl.delegate = self
            viewCtrl.product = product
            viewCtrl.hidesBottomBarWhenPushed = true
        } else if segueName == "showProductReviewListViewController", let viewCtrl = segue.destination as? ProductReviewListViewController {
            viewCtrl.productSku = product?.sku
            viewCtrl.rating = product?.ratings
            viewCtrl.signleReviewItem = sender as? ProductReviewItem
            viewCtrl.hidesBottomBarWhenPushed = true
        } else if segueName == "showSubmitProductReviewViewController", let viewCtrl = segue.destination as? SubmitProductReviewViewController {
            viewCtrl.hidesBottomBarWhenPushed = true
        }  else if segueName == "showOtherSellerViewController", let viewCtrl = segue.destination as? OtherSellerViewController {
            viewCtrl.product = self.product
            viewCtrl.hidesBottomBarWhenPushed = true
        } else if segueName == "showAllRecommendationViewController", let viewCtrl = segue.destination as? AllRecommendationViewController {
            viewCtrl.recommendItems = self.recommendItems ?? []
            viewCtrl.hidesBottomBarWhenPushed = false
        }
    }
    
    override func navBarleftButton() -> NavBarButtonType {
        return .cart
    }
    
    private func prepareAddToCartView(addToCartViewController: AddToCartViewController){
        addToCartViewController.product = self.product
        if animator == nil {
            animator = ZFModalTransitionAnimator(modalViewController: addToCartViewController)
            animator?.isDragable = true
            animator?.bounces = true
            animator?.behindViewAlpha = 0.8
            animator?.behindViewScale = 0.9
            animator?.transitionDuration = 0.7
            animator?.direction = .bottom
        }
        addToCartViewController.modalPresentationStyle = .overCurrentContext
        addToCartViewController.delegate = self
        addToCartViewController.transitioningDelegate = animator
    }
}


//MARK: - ProductDetailViewSliderTableViewCellDelegate
extension ProductDetailViewController: ProductDetailViewSliderTableViewCellDelegate {
    func addOrRemoveFromWishList(product: TrackableProductProtocol, cell: ProductDetailViewSliderTableViewCell, add: Bool) {
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

//MARK: - Tableview Datasource, Delegate
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
        case .emptyReview :
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! ProductEmptyReviewTableViewCell
            cell.delegate = self
            return cell
        case .primaryInfo, .variation, .warranty, .seller, .reviewSummery:
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! BaseProductTableViewCell
            
            if cellType == .primaryInfo {
                (cell as? ProductDetailPrimaryInfoTableViewCell)?.delegate = self
            }
            
            if cellType == .variation {
                (cell as? ProductVariationTableViewCell)?.delegate = self
            }
            
            if cellType == .seller {
                (cell as? ProductOldSellerViewTableViewCell)?.sellerViewControl.delegate = self
                (cell as? ProductOldSellerViewTableViewCell)?.preValueDeliveryTimeValue = calculatedDeliveryTimeMessage
            }
            
            if cellType == .reviewSummery {
                (cell as? ProductReviewSummeryTableViewCell)?.delegate = self
            }
            
            cell.update(withModel: product)
            return cell
        case .relatedItems:
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! ProductRecommendationWidgetTableViewCell
            if let firstSix = recommendItems?.prefix(6) {
                cell.update(withModel: Array(firstSix))
                cell.setDelegate(delegate: self)
            }
            return cell
        case .breadcrumbs:
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! ProductBreadCrumbTableViewCell
            cell.update(withModel: product?.breadCrumbs)
            cell.setDelegate(delegate: self)
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
        if let name = self.sectionNames[section] {
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
        if let _ = self.sectionNames[section] {
            return TransparentHeaderHeaderTableView.cellHeight()
        }
        
        //first section (slider) must not have height
        //minimom acceptable height for header is 1 (apple Api) (for grouped tableview)
        return section == 0 ? 1 : 10
    }
}

//MARK: - Image Gallery
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
        if let imageList = self.product?.imageList, index < imageList.count, let url = imageList[index].large {
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

//MARK: - AddToCartViewControllerDelegate
extension ProductDetailViewController: AddToCartViewControllerDelegate {
    func submitAddToCartSimple(product: NewProduct, refrence: UIViewController) {
        self.requestAddToCart(simpleSku: product.simpleSku ?? product.sku, inViewCtrl: self)
    }
    
    func didSelectOtherVariation(product: NewProduct, completionHandler: @escaping ((NewProduct) -> Void)) {
        //if we are in the same page of product
        if let sku = self.product?.sku, (product.sku == sku) { return }
        if let sku = self.productSku, product.sku == sku { return }
        if let simpleSku = self.product?.simpleSku, product.simpleSku == simpleSku { return }
        
        self.productSku = product.sku
        self.product?.sku = product.sku
        self.getContent { (sucecss) in
            if sucecss {
                self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
                if let product = self.product {
                    completionHandler(product)
                }
            }
        }
    }
    
    func didSelectSizeVariationFromAddToCartView(product: NewProduct) {
        //update cells which have the variations
        availableSections.forEach { (section, rows) in
            if let row = rows.index(of: .variation) {
                if let isInVisiableRect = tableView.indexPathsForVisibleRows?.contains(IndexPath(row: row, section: section)), isInVisiableRect {
                    tableView.reloadRows(at: [IndexPath(row: row, section: section)], with: UITableViewRowAnimation.none)
                }
            }
        }
    }
}

//MARK: - BaseProductTableViewCellDelegate
extension ProductDetailViewController: ProductDetailPrimaryInfoTableViewCellDelegate {
    func rateButtonTapped() {
        writeCommentButtonTapped()
    }
}

//MARK: - ProductVariationTableViewCellDelegate
extension ProductDetailViewController: ProductVariationTableViewCellDelegate {
    
    func didSelectOtherVariety(product: NewProduct) {
        //if we are in the same page of product
        if let sku = self.product?.sku, product.sku == sku { return }
        if let sku = self.productSku, product.sku == sku { return }

        let productDetailViewCtrl =  ViewControllerManager.sharedInstance().loadViewController("ProductDetailViewController") as! ProductDetailViewController
        productDetailViewCtrl.productSku = product.sku
        productDetailViewCtrl.purchaseTrackingInfo = self.purchaseTrackingInfo
        self.navigationController?.pushViewController(productDetailViewCtrl, animated: true)
    }
    
    func moreInfoButtonTapped(viewType: MoreInfoSelectedViewType) {
        self.performSegue(withIdentifier: "showProductMoreInfoViewController", sender: viewType)
    }

}

//MARK: - ProductReviewSummeryTableViewCell
extension ProductDetailViewController: ProductReviewSummeryTableViewCellDelegate {
    func seeAllCommentButttonTapped() {
        self.performSegue(withIdentifier: "showProductReviewListViewController", sender: nil)
    }
    
    func reviewItemSeeMoreButtonTapped(review: ProductReviewItem) {
        self.performSegue(withIdentifier: "showProductReviewListViewController", sender: review)
    }
    
    func writeCommentButtonTapped() {
        (navigationController as? JACenterNavigationController)?.performProtectedBlock({ (success) in
            self.performSegue(withIdentifier: "showSubmitProductReviewViewController", sender: nil)
        })
    }
}

//MARK: - ProductMoreInfoViewControllerDelegate
extension ProductDetailViewController: ProductMoreInfoViewControllerDelegate {

    func requestsForAddToCart<T>(sku: String, viewCtrl: T) where T : BaseViewController, T : DataServiceProtocol {
        self.requestAddToCart(simpleSku: sku, inViewCtrl: viewCtrl)
    }
    
    func needToPrepareAddToCartViewCtrl(addToCartViewCtrl: AddToCartViewController) {
        prepareAddToCartView(addToCartViewController: addToCartViewCtrl)
    }
}


//MARK: - SellerViewDelegate
extension ProductDetailViewController: SellerViewDelegate {
    func otherSellerButtonTapped() {
        self.performSegue(withIdentifier: "showOtherSellerViewController", sender: nil)
    }
    
    func refreshContent(sellerView: SellerView) {
        retryAction(nil, forRequestId: 0)
    }
    
    func goToSellerPage(target: RITarget) {
        (navigationController as? JACenterNavigationController)?.openScreenTarget(target, purchaseInfo: purchaseTrackingInfo, currentScreenName: getScreenName())
    }
    
    func updateDeliveryTimeValue(value: String?) {
        calculatedDeliveryTimeMessage = value
    }
}


//MARK: - EmarsysPredictProtocol
extension ProductDetailViewController: EmarsysPredictProtocol {
    func getRecommendations() -> [EMRecommendationRequest]! {
        let recommend = EMRecommendationRequest(logic: "RELATED")
        recommend.limit = 100
        recommend.completionHandler = { (result) in
            self.recommendItems = result.products.map { RecommendItem(item: $0)! }
            ThreadManager.execute(onMainThread: {
                self.updateAvaibleSections()
                self.tableView.reloadData()
            })
        }
        return [recommend]
    }
    
    func getDataCollection(_ transaction: EMTransaction!) -> EMTransaction! {
        if let sku = self.product?.sku {
            transaction.setView(sku)
        }
        return transaction;
    }
    
    func isPreventSendTransactionInViewWillAppear() -> Bool {
        return true
    }
}

//MARK: - BreadcrumbsViewDelegate
extension ProductDetailViewController: BreadcrumbsViewDelegate {
    func itemTapped(item: BreadcrumbsItem) {
        (self.navigationController as? JACenterNavigationController)?.openTargetString(item.target, purchaseInfo: nil, currentScreenName: self.getScreenName())
    }
}

//MARK: - FeatureBoxCollectionViewWidgetViewDelegate
extension ProductDetailViewController: FeatureBoxCollectionViewWidgetViewDelegate {
    
    func selectFeatureItem(_ item: NSObject!, widgetBox: Any!) {
        if let recommendItem = item as? RecommendItem {
            let productDetailViewCtrl =  ViewControllerManager.sharedInstance().loadViewController("ProductDetailViewController") as! ProductDetailViewController
            productDetailViewCtrl.productSku = recommendItem.sku
            self.navigationController?.pushViewController(productDetailViewCtrl, animated: true)
        }
    }
    
    func moreButtonTapped(inWidgetView widgetView: Any!) {
        self.performSegue(withIdentifier: "showAllRecommendationViewController", sender: nil)
    }
}
