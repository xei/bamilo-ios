//
//  ProductDetailViewSliderTableViewCell.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 5/22/18.
//  Copyright © 2018 Rocket Internet. All rights reserved.
//

import UIKit
import FSPagerView
import CHIPageControl
protocol ProductDetailViewSliderTableViewCellDelegate: class {
    func selectSliderItem(item: ProductImageItem, atIndex: Int, cell: ProductDetailViewSliderTableViewCell)
    func addOrRemoveFromWishList(product: TrackableProductProtocol, cell: ProductDetailViewSliderTableViewCell, add: Bool)
    func shareButtonTapped()
}

class ProductDetailViewSliderTableViewCell: BaseProductTableViewCell, FSPagerViewDelegate, FSPagerViewDataSource {
    
    weak var delegate: ProductDetailViewSliderTableViewCellDelegate?
    
    @IBOutlet weak var wishListButton: DOFavoriteButton!
    @IBOutlet weak private var shareButton: IconButton!
    @IBOutlet weak private var pagerControlBackrgroud: UIView!
    @IBOutlet weak private var pagerControlBackroundWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak private var pagerControlBackroundHightConstraint: NSLayoutConstraint!
    
    private static let sliderRatio: CGFloat = 1.2 ////ratio:  320*280
    private var productImageList: [ProductImageItem]?
    private var cellIndexMapper = [Int: FSPagerViewCell]()
    private var sliderBlurView: UIVisualEffectView?
    private var product: NewProduct?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        shareButton.setImage(#imageLiteral(resourceName: "share-icons").withRenderingMode(.alwaysTemplate), for: .normal)
        shareButton.imageView?.tintColor = Theme.color(kColorGray9)
        
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear
        self.clipsToBounds = true
        
        self.pagerControlBackrgroud.applyShadow(position: CGSize(width:0 , height: 1), color: .black, opacity: 0.2)
        self.pagerControlBackrgroud.layer.cornerRadius = 6
        self.pagerControlBackrgroud.backgroundColor = .white
    }
    
    @IBOutlet weak private var pagerControl: CHIPageControlJalapeno! {
        didSet {
            self.pagerControl.backgroundColor = .clear
            self.pagerControl.radius = 3
            self.pagerControl.tintColor = Theme.color(kColorGray9)
            self.pagerControl.currentPageTintColor = Theme.color(kColorOrange)
            self.pagerControl.numberOfPages = 0
        }
    }
    
    @IBOutlet weak private var sliderView: FSPagerView! {
        didSet {
            self.sliderView.register(ProductSliderCell.self, forCellWithReuseIdentifier: "cell")
            self.sliderView.backgroundColor = .clear
            self.sliderView.dataSource = self
            self.sliderView.delegate = self
            self.sliderView.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.sliderView.isInfinite = false
            self.sliderView.transformer = FSPagerViewTransformer(type: .depth)
            self.sliderBlurView = self.sliderView.addBlurView(style: .light)
            self.sliderBlurView?.alpha = 0
            //make force all of slider and it's subviews clipBounds to be false
            self.sliderView.clipsToBounds = false
            self.sliderView.subviews.forEach{
                $0.clipsToBounds = false
                $0.subviews.forEach { $0.clipsToBounds = false }
            }
        }
    }
    
    var blurView: UIVisualEffectView? {
        return self.sliderBlurView
    }
    
    func selectIndex(index: Int, animated: Bool) {
        self.sliderView.scrollToItem(at: index, animated: animated)
    }
    
    func openCurrentImage() {
        self.pagerView(self.sliderView, didSelectItemAt: self.sliderView.currentIndex)
    }
    
    var visibleUIImageView: UIImageView? {
        return self.cellIndexMapper[self.sliderView.currentIndex]?.imageView
    }
    
    override func update(withModel model: Any!) {
        if let product = model as? NewProduct {
            if let imageList = product.imageList {
                self.productImageList = imageList
                if self.pagerControl.numberOfPages != imageList.count {
                    self.pagerControl.numberOfPages = imageList.count
                    self.pagerControl.set(progress: imageList.count - 1, animated: false)
                }
                self.sliderView.reloadData()
            }
            
            self.product = product
            if wishListButton.isSelected != product.isInWishList {
                wishListButton.image = product.isInWishList ? #imageLiteral(resourceName: "addToWishlist_highlited") : #imageLiteral(resourceName: "addToWishlist")
            }
            
            wishListButton.isSelected = product.isInWishList
            pagerControlBackroundWidthConstraint.constant = pagerControl.intrinsicContentSize.width + 10
            pagerControlBackroundHightConstraint.constant = pagerControl.intrinsicContentSize.height + 6
            pagerControlBackrgroud.isHidden = pagerControl.numberOfPages <= 1
        }
    }
    
    override class func cellHeight() -> CGFloat {
        return UIScreen.main.bounds.width / sliderRatio + 40
    }
    
    @IBAction func addToWishListButtonTapped(_ sender: DOFavoriteButton) {
        if sender.isSelected {
            sender.image = #imageLiteral(resourceName: "addToWishlist")
            sender.deselect()
        } else {
            sender.image = #imageLiteral(resourceName: "addToWishlist_highlited")
            sender.select()
        }
        if let avaiableProduct = self.product {
            avaiableProduct.isInWishList.toggle()
            self.delegate?.addOrRemoveFromWishList(product: avaiableProduct, cell: self, add: avaiableProduct.isInWishList)
        }
    }
    
    @IBAction func shareButtonTapped(_ sender: Any) {
        self.delegate?.shareButtonTapped()
    }
    
    //MARK: - FSPagerViewDataSource && FSPagerViewDataSource
    func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        let cell = self.sliderView.dequeueReusableCell(withReuseIdentifier: "cell", at: index)
        cell.imageView?.contentMode = .scaleAspectFit
        cell.imageView?.kf.setImage(with: self.productImageList?[index].large, placeholder: #imageLiteral(resourceName: "homepage_slider_placeholder"),options: [.transition(.fade(0.20))])
        
        cell.setNeedsLayout()
        cell.layoutIfNeeded()
        
        self.blurView?.frame = cell.imageView?.frame ?? .zero
        cellIndexMapper[index] = cell
        return cell
    }
    
    func numberOfItems(in pagerView: FSPagerView) -> Int {
        return self.productImageList?.count ?? 0
    }
    
    func pagerView(_ pagerView: FSPagerView, didSelectItemAt index: Int) {
        pagerView.deselectItem(at: index, animated: true)
        if let imageItem = self.productImageList?[index] {
            self.delegate?.selectSliderItem(item: imageItem, atIndex: index, cell: self)
        }
    }
    
    func pagerViewDidScroll(_ pagerView: FSPagerView) {
        let targetIndex = self.pagerControl.numberOfPages - 1 - self.sliderView.currentIndex
        guard targetIndex != self.pagerControl.numberOfPages else { return }
        self.pagerControl.set(progress: targetIndex, animated: true)
    }

}


class ProductSliderCell: FSPagerViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.contentView.transform = CGAffineTransform(scaleX: -1, y: 1)
        self.contentView.clipsToBounds = false
        self.clipsToBounds = false
        self.imageView?.layer.shadowColor = UIColor.clear.cgColor
        self.contentView.layer.shadowColor = UIColor.clear.cgColor
        self.layer.shadowColor = UIColor.clear.cgColor
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
