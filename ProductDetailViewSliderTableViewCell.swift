//
//  ProductDetailViewSliderTableViewCell.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 5/22/18.
//  Copyright © 2018 Rocket Internet. All rights reserved.
//

import UIKit
import FSPagerView

class ProductDetailViewSliderTableViewCell: BaseProductTableViewCell, FSPagerViewDelegate, FSPagerViewDataSource {
    
    private static let sliderRatio: CGFloat = 2 //ratio:  320*114
    private var productImageList: [ProductImageItem]?
    private var cellIndexMapper = [Int: FSPagerViewCell]()
    private var sliderBlurView: UIVisualEffectView?
    
    @IBOutlet weak var sliderView: FSPagerView! {
        didSet {
            self.sliderView.register(FSPagerViewCell.self, forCellWithReuseIdentifier: "cell")
            self.sliderView.backgroundColor = .clear
            self.sliderView.dataSource = self
            self.sliderView.delegate = self
            self.sliderView.isInfinite = true
            self.sliderView.transformer = FSPagerViewTransformer(type: .invertedFerrisWheel)
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
    
    var visibleUIImageView: UIImageView? {
        return self.cellIndexMapper[self.sliderView.currentIndex]?.imageView
    }
    
    override func update(withModel model: Any!) {
        if let imageList = model as? [ProductImageItem] {
            self.productImageList = imageList
            self.sliderView.reloadData()
        }
    }
    
    override class func cellHeight() -> CGFloat {
        return UIScreen.main.bounds.width / sliderRatio
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
    
    func pagerViewDidScroll(_ pagerView: FSPagerView) {
        
    }

}
