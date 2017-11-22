//
//  HomePageSliderTableViewCell.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 9/18/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

import UIKit
import FSPagerView
import Kingfisher

class HomePageSliderTableViewCell: BaseHomePageTeaserBoxTableViewCell, FSPagerViewDataSource, FSPagerViewDelegate, HomePageTeaserHeightCalculator {
    
    var sliderContent: HomePageSlider?
    private static let sliderRatio: CGFloat = 2.1375 //ratio:  342*160
    private static var cellSpacing: CGFloat {
        get {
            return UIDevice.current.userInterfaceIdiom == .pad ? 10 : 8
        }
    }
    private static var partialSlideWidthPrecent: CGFloat {
        get {
            return UIDevice.current.userInterfaceIdiom == .pad ? 0.1 : 0.026
        }
    }
    private static var wholeSlidesWidthRatio: CGFloat {
        get {
            return 1 + 2 * partialSlideWidthPrecent
        }
    }
    
    @IBOutlet weak var sliderPager: FSPageControl! {
        didSet{
            self.sliderPager.transform = CGAffineTransform(scaleX: -1, y: 1)
        }
    }
    @IBOutlet private weak var pagerView: FSPagerView! {
        didSet {
            self.pagerView.register(FSPagerViewCell.self, forCellWithReuseIdentifier: "cell")
            self.pagerView.backgroundColor = .clear
            self.pagerView.dataSource = self
            self.pagerView.delegate = self
            self.pagerView.isInfinite = true
            
            self.pagerView.transform = CGAffineTransform(scaleX: -1, y: 1)
        }
    }
    
    override func update(withModel model: Any!) {
        if let sliderContent = model as? HomePageSlider {
            self.sliderContent = sliderContent
            self.pagerView.reloadData()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear
        // --- The formulla of slider itemWidth calculation --
        // WidthWholeView = sliderItemWidth + 2 * (0.026) * sliderItemWidth + 2 * (interitemSpacing = 8)
        let itemWidth = (UIApplication.shared.statusBarFrame.width - HomePageSliderTableViewCell.cellSpacing * 2) / HomePageSliderTableViewCell.wholeSlidesWidthRatio
        let itemHeight = itemWidth / HomePageSliderTableViewCell.sliderRatio
        
        self.pagerView.itemSize = CGSize(width: itemWidth, height: itemHeight)
        self.pagerView.interitemSpacing = HomePageSliderTableViewCell.cellSpacing
        
        self.sliderPager.setFillColor(Theme.color(kColorGray5), for: .normal)
        self.sliderPager.setFillColor(Theme.color(kColorOrange1), for: .selected)
        
        self.sliderPager.backgroundColor = UIColor.clear
        
        self.sliderPager.setPath(UIBezierPath(ovalIn: CGRect(x: 0, y: 0, width: 6, height: 6)), for: .normal)
        self.sliderPager.setPath(UIBezierPath(ovalIn: CGRect(x: -1, y: -1, width: 8, height: 8)), for: .selected)
    }
    
    //MARK: - FSPagerViewDataSource
    
    func numberOfItems(in pagerView: FSPagerView) -> Int {
        self.sliderPager.numberOfPages = self.sliderContent?.sliders?.count ?? 0
        return self.sliderPager.numberOfPages
    }
    
    func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        let cell = pagerView.dequeueReusableCell(withReuseIdentifier: "cell", at: index)
        cell.imageView?.kf.setImage(with: self.sliderContent?.sliders?[index].imagePortraitUrl, placeholder: UIImage(named: "homepage_slider_placeholder"),options: [.transition(.fade(0.20))])
        
        cell.imageView?.layer.cornerRadius = 2
        cell.imageView?.layer.masksToBounds = true
        cell.imageView?.clipsToBounds = true
        
        cell.contentView.layer.shadowColor = UIColor.black.cgColor
        cell.contentView.layer.shadowOpacity = 0.2
        cell.contentView.layer.shadowOffset = CGSize(width:1 , height: 2)
        cell.contentView.layer.shadowRadius = 1
        cell.contentView.clipsToBounds = false
        cell.transform = CGAffineTransform(scaleX: -1, y: 1)
        
        cell.imageView?.contentMode = .scaleAspectFill
        return cell
    }
    
    func pagerViewDidScroll(_ pagerView: FSPagerView) {
        guard self.sliderPager.currentPage != pagerView.currentIndex else {
            return
        }
        self.sliderPager.currentPage = pagerView.currentIndex // Or Use KVO with property "currentIndex"
    }
    
    func pagerView(_ pagerView: FSPagerView, didSelectItemAt index: Int) {
        pagerView.deselectItem(at: index, animated: true)
        if let sliderItems = self.sliderContent?.sliders, index < sliderItems.count, let target = sliderItems[index].target, let id = self.sliderContent?.teaserId {
            self.delegate?.teaserItemTappedWithTargetString(target: target, teaserId: id)
        }
    }
    
    //MARK: - HomePageTeaserHeightCalculator
    static func teaserHeight(model: Any?) -> CGFloat {
        let itemWidth = (UIApplication.shared.statusBarFrame.width - 2 * cellSpacing) / wholeSlidesWidthRatio
        let itemHeight = itemWidth / sliderRatio
        return itemHeight + cellSpacing * 2 + 8 //8 point padding from bottom
    }
}
