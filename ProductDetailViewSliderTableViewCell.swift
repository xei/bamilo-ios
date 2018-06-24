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
    func addOrRemoveFromWishList(product: Product, cell: ProductDetailViewSliderTableViewCell, add: Bool)
    func shareButtonTapped()
}

class ProductDetailViewSliderTableViewCell: BaseProductTableViewCell, FSPagerViewDelegate, FSPagerViewDataSource {
    
    weak var delegate: ProductDetailViewSliderTableViewCellDelegate?
    
    @IBOutlet weak var wishListButton: DOFavoriteButton!
    @IBOutlet weak var buttonsTopConstraint: NSLayoutConstraint!
    
    private static let sliderRatio: CGFloat = 0.94 //ratio:  320*314
    private var productImageList: [ProductImageItem]?
    private var cellIndexMapper = [Int: FSPagerViewCell]()
    private var sliderBlurView: UIVisualEffectView?
    private var product: Product?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.backgroundColor = .white
        self.clipsToBounds = true
    }
    
    @IBOutlet weak private var pagerControl: CHIPageControlJalapeno! {
        didSet {
            self.pagerControl.backgroundColor = .clear
            self.pagerControl.radius = 4
            self.pagerControl.tintColor = Theme.color(kColorGray9)
            self.pagerControl.currentPageTintColor = Theme.color(kColorOrange)
            self.pagerControl.numberOfPages = 0
        }
    }
    
    @IBOutlet weak private var sliderView: FSPagerView! {
        didSet {
            self.sliderView.register(FSPagerViewCell.self, forCellWithReuseIdentifier: "cell")
            self.sliderView.backgroundColor = .clear
            self.sliderView.dataSource = self
            self.sliderView.delegate = self
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
    
    var visibleUIImageView: UIImageView? {
        return self.cellIndexMapper[self.sliderView.currentIndex]?.imageView
    }
    
    override func update(withModel model: Any!) {
        if let product = model as? Product {
            if let imageList = product.imageList {
                self.productImageList = imageList
                self.pagerControl.numberOfPages = imageList.count
                self.sliderView.reloadData()
            }
            self.product = product
            self.wishListButton.isSelected = product.isInWishList
            
        }
    }
    
    override class func cellHeight() -> CGFloat {
        return UIScreen.main.bounds.width / sliderRatio
    }
    
    @IBAction func addToWishListButtonTapped(_ sender: DOFavoriteButton) {
        if sender.isSelected {
            sender.deselect()
        } else {
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
        cell.imageView?.kf.setImage(with: self.productImageList?[index].normal, placeholder: #imageLiteral(resourceName: "homepage_slider_placeholder"),options: [.transition(.fade(0.20))])
        cell.contentView.clipsToBounds = false
        cell.clipsToBounds = false
        cell.imageView?.layer.shadowColor = UIColor.clear.cgColor
        cell.contentView.layer.shadowColor = UIColor.clear.cgColor
        cell.layer.shadowColor = UIColor.clear.cgColor
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
        guard self.sliderView.currentIndex != pagerControl.currentPage else {
            return
        }
        self.pagerControl.set(progress: self.sliderView.currentIndex, animated: true)
    }

}
