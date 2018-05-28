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

class ProductDetailViewController: BaseViewController,
                                    UITableViewDelegate,
                                    UITableViewDataSource,
                                    DataServiceProtocol {

    var product: Product?
    @IBOutlet weak private var tableView: UITableView!
    private var sliderCell: ProductDetailViewSliderTableViewCell?

    enum CellType {
        case slider
        case primaryInfo
    }
    
    fileprivate var availableSections = [Int: [CellType]]()
    let cellIdentifiers : [CellType: String] = [
        .slider:        ProductDetailViewSliderTableViewCell.nibName(),
        .primaryInfo:   ProductDetailPrimaryInfoTableViewCell.nibName()
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
            cell.delegate = self
            cell.clipsToBounds = false
            cell.update(withModel: self.product)
            self.sliderCell = cell
            return cell
            
        case .primaryInfo:
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! ProductDetailPrimaryInfoTableViewCell
            cell.update(withModel: self.product)
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
                sliderCell?.buttonsTopConstraint.constant = 10 + self.tableView.contentOffset.y
            } else {
                sliderCell?.buttonsTopConstraint.constant = 10
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
    
    func addOrRemoveFromWishList(product: Product, cell: ProductDetailViewSliderTableViewCell, add: Bool) {
        
    }
    
    func selectSliderItem(item: ProductImageItem, atIndex: Int, cell: ProductDetailViewSliderTableViewCell) {
        let galleryViewController = GalleryViewController(startIndex: atIndex, itemsDataSource: self, displacedViewsDataSource: self, configuration: self.galleryConfiguration())
        galleryViewController.landedPageAtIndexCompletion = { self.sliderCell?.selectIndex(index: $0, animated: false) }
        self.presentImageGallery(galleryViewController)
    }
}


//Image Gallery
extension ProductDetailViewController: GalleryItemsDataSource, GalleryDisplacedViewsDataSource {
    
    func galleryConfiguration() -> GalleryConfiguration {
        let button = IconButton()
        button.setImage(#imageLiteral(resourceName: "view_grid_active"), for: .normal)
        button.frame.size = CGSize(width: 50, height: 50)
        return [
            GalleryConfigurationItem.closeButtonMode(.builtIn),
            GalleryConfigurationItem.pagingMode(.standard),
            GalleryConfigurationItem.presentationStyle(.displacement),
            GalleryConfigurationItem.hideDecorationViewsOnLaunch(false),
            GalleryConfigurationItem.swipeToDismissMode(.vertical),
            GalleryConfigurationItem.toggleDecorationViewsBySingleTap(false),
            GalleryConfigurationItem.activityViewByLongPress(false),
            GalleryConfigurationItem.overlayColor(UIColor(white: 0.035, alpha: 1)),
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
            GalleryConfigurationItem.thumbnailsButtonMode(.custom(button)),
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
