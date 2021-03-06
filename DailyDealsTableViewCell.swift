//
//  DailyDealsTableViewCell.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 10/8/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

import UIKit

class DailyDealsTableViewCell: BaseHomePageTeaserBoxTableViewCell, UICollectionViewDelegate, UICollectionViewDataSource, HomePageTeaserHeightCalculator {

    @IBOutlet weak private var contentContainer: UIView!
    @IBOutlet weak private var collectionView: UICollectionView!
    @IBOutlet weak private var teaserTitle: UILabel!
    @IBOutlet weak private var countDownLabel: UILabel!
    @IBOutlet weak private var moreButton: UIButton!
    @IBOutlet weak private var countDownCenterdConstraint: NSLayoutConstraint!
    @IBOutlet weak private var countDownAlignLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak private var teaserBottomPaddingConstraint: NSLayoutConstraint!
    
    @IBOutlet weak private var collectionViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak private var teaserTitleHeightConstraint: NSLayoutConstraint!
    
    private var teaserModelObject: HomePageDailyDeals?
    
    private static let titleLabelHeight: CGFloat = 45
    private static let collectionPadding: CGFloat = 8
    private static let teaserBottomPadding: CGFloat = 8
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupView()
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.collectionViewLayout = HomePageDailyDealsCollectionFlowLayout()
        self.collectionView.register(UINib(nibName: DailyDealsCollectionViewCell.nibName, bundle: nil), forCellWithReuseIdentifier: DailyDealsCollectionViewCell.nibName)
        self.teaserBottomPaddingConstraint.constant = DailyDealsTableViewCell.teaserBottomPadding
    }
    
    func setupView() {
        self.contentContainer.layer.borderColor = Theme.color(kColorExtraExtraLightGray).cgColor
        self.contentContainer.layer.borderWidth = 1
        self.contentContainer.layer.cornerRadius = 2
        self.contentContainer.clipsToBounds = true
        self.contentContainer.backgroundColor = .white
        
        self.teaserTitle.applyStyle(font: Theme.font(kFontVariationRegular, size: 12), color: UIColor.black)
        self.teaserTitleHeightConstraint.constant = DailyDealsTableViewCell.titleLabelHeight
        self.collectionViewBottomConstraint.constant = DailyDealsTableViewCell.collectionPadding
        self.countDownLabel.applyStyle(font: Theme.font(kFontVariationRegular, size: 17), color: Theme.color(kColorRed))
        self.moreButton.titleLabel?.font = Theme.font(kFontVariationRegular, size: 12)
        
        self.collectionView.backgroundColor = .clear
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear
    }
    
    //MARK: - UICollectionViewDataSource & UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: DailyDealsCollectionViewCell.nibName, for: indexPath) as! DailyDealsCollectionViewCell
        if let product = teaserModelObject?.products?[indexPath.row] {
            cell.updateWithModel(product: product)
        }
        return cell
    }
    
    @IBAction func moreButtonTapped(_ sender: Any) {
        if let target = self.teaserModelObject?.moreOption?.target, let teaserId = self.teaserModelObject?.teaserId {
            self.delegate?.teaserItemTappedWithTargetString(target: target, teaserId: teaserId, index: nil)
        }
    }
    
    //MARK: - HomePageTeaserHeightCalculator
    class func teaserHeight(model: Any?) -> CGFloat {
         return self.cellSize().height + teaserBottomPadding
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let product = teaserModelObject?.products?[indexPath.row], let sku = product.sku, let id = self.teaserModelObject?.teaserId {
            self.delegate?.teaserItemTappedWithTargetString(target: "product_detail::\(sku)", teaserId: id, index: indexPath.row)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.teaserModelObject?.products?.count ?? 0
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func update(withModel model: Any!) {
        if let dailyDeals = model as? HomePageDailyDeals {
            self.teaserModelObject = dailyDeals
            ThreadManager.execute(onMainThread: {
                self.contentContainer.backgroundColor = dailyDeals.backgroundColor ?? .white
                self.teaserTitle.text = dailyDeals.title
                self.teaserTitle.textColor = dailyDeals.titleColor ?? .black
                if let moreOption = dailyDeals.moreOption {
                    self.moreButton.setTitle(moreOption.title, for: .normal)
                    self.moreButton.setTitleColor(moreOption.color ?? Theme.color(kColorGray3), for: .normal)
                    self.countDownCenterdConstraint.priority = .defaultHigh
                    self.countDownAlignLeftConstraint.priority = .defaultLow
                } else {
                    self.countDownAlignLeftConstraint.priority = .defaultHigh
                    self.countDownCenterdConstraint.priority = .defaultLow
                }
                
                if let countDown = dailyDeals.ramainingSeconds {
                    self.countDownLabel.textColor = dailyDeals.counterColor ?? .red
                    self.updateTimer(seconds: countDown)
                } else {
                    self.countDownLabel.isHidden = true
                }
                
                self.collectionView.reloadData()
            })
            
            //Ecommerce
//            if let products = dailyDeals.products {
//                GoogleAnalyticsTracker.shared().trackProductImpression(products: products, impressionList: self.countDownLabel.isHidden ? "FeaturedBox" : "DailyDeals", impressionSource: "From HomePage")
//            }
        }
    }
    
    func updateTimer(seconds: Int) {
        self.countDownLabel.isHidden = false
        self.countDownLabel.text = Utility.timeString(seconds: seconds, allowedUnits: [.hour, .minute, .second]).convertTo(language: .arabic)
    }
    
    private class func cellSize() -> CGSize {
        let collectionWidth = UIScreen.main.bounds.width - 2 * collectionPadding
        let cellWidth = CarouselCollectionFlowLayout.itemWidth(relateTo: collectionWidth, cellSpacing: 5)
        let collectionHeight = DailyDealsCollectionViewCell.cellHeight(relateTo: cellWidth)
        return CGSize(width: cellWidth, height: collectionHeight + titleLabelHeight + collectionPadding )
    }
}
