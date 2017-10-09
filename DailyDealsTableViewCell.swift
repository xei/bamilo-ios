//
//  DailyDealsTableViewCell.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 10/8/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

import UIKit

class DailyDealsTableViewCell: BaseHomePageTeaserBoxTableViewCell, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak private var collectionView: UICollectionView!
    @IBOutlet weak private var teaserTitle: UILabel!
    @IBOutlet weak private var countDownLabel: UILabel!
    @IBOutlet weak private var moreButton: UIButton!
    @IBOutlet weak private var countDownCenterdConstraint: NSLayoutConstraint!
    @IBOutlet weak private var countDownAlignLeftConstraint: NSLayoutConstraint!
    
    @IBOutlet weak private var collectionViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak private var teaserTitleHeightConstraint: NSLayoutConstraint!
    
    private var teaserModelObject: HomePageDailyDeals!
    
    private static let titleLabelHeight: CGFloat = 45
    private static let collectionPadding: CGFloat = 8
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.setupView()
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.collectionViewLayout = HomePageDailyDealsCollectionFlowLayout()
        self.collectionView.register(UINib(nibName: DailyDealsCollectionViewCell.nibName, bundle: nil), forCellWithReuseIdentifier: DailyDealsCollectionViewCell.nibName)
    }
    
    func setupView() {
        self.teaserTitle.applyStype(font: Theme.font(kFontVariationRegular, size: 12), color: UIColor.black)
        self.teaserTitleHeightConstraint.constant = DailyDealsTableViewCell.titleLabelHeight
        self.collectionViewBottomConstraint.constant = DailyDealsTableViewCell.collectionPadding
        self.countDownLabel.applyStype(font: Theme.font(kFontVariationRegular, size: 12), color: Theme.color(kColorRed))
        self.moreButton.titleLabel?.font = Theme.font(kFontVariationRegular, size: 12)
    }
    
    //MARK: - UICollectionViewDataSource & UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: DailyDealsCollectionViewCell.nibName, for: indexPath) as! DailyDealsCollectionViewCell
        if let product = teaserModelObject.products?[indexPath.row] {
            cell.updateWithModel(product: product)
        }
        return cell
    }
    
    @IBAction func moreButtonTapped(_ sender: Any) {
        if let target = self.teaserModelObject.moreOption?.target {
            self.delegate?.teaserItemTappedWithTargetString(target: target)
        }
    }
    
    override static func cellHeight() -> CGFloat {
        return self.cellSize().height
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let product = teaserModelObject.products?[indexPath.row], let target = product.target {
            self.delegate?.teaserItemTappedWithTargetString(target: target)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.teaserModelObject.products?.count ?? 0
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func update(withModel model: Any!) {
        if let dailyDeals = model as? HomePageDailyDeals {
            self.teaserModelObject = dailyDeals
            ThreadManager.execute(onMainThread: {
                self.teaserTitle.text = dailyDeals.title
                if let moreOption = dailyDeals.moreOption {
                    self.moreButton.setTitle(moreOption.title, for: .normal)
                    self.moreButton.setTitleColor(moreOption.color, for: .normal)
                    self.countDownCenterdConstraint.priority = UILayoutPriorityDefaultHigh
                    self.countDownAlignLeftConstraint.priority = UILayoutPriorityDefaultLow
                } else {
                    self.countDownAlignLeftConstraint.priority = UILayoutPriorityDefaultHigh
                    self.countDownCenterdConstraint.priority = UILayoutPriorityDefaultLow
                }
                
                if let countDown = dailyDeals.countDown {
                    self.updateTimer(seconds: countDown)
                } else {
                    self.countDownLabel.isHidden = true
                }
                
                self.collectionView.reloadData()
            })
        }
    }
    
    func updateTimer(seconds: Int) {
        self.countDownLabel.isHidden = false
        self.countDownLabel.text = timeString(seconds: seconds).convertTo(language: .arabic)
    }
    
    private static func cellSize() -> CGSize {
        let collectionWidth = UIScreen.main.bounds.width - 2 * collectionPadding
        let cellWidth = CarouselCollectionFlowLayout.itemWidth(relateTo: collectionWidth, cellSpacing: 5)
        let collectionHeight = DailyDealsCollectionViewCell.cellHeight(relateTo: cellWidth)
        return CGSize(width: cellWidth, height: collectionHeight + titleLabelHeight + collectionPadding )
    }
    
    private func timeString(seconds:Int) -> String {
        let hours = seconds / 3600
        let minutes = seconds / 60 % 60
        let seconds = seconds % 60
        return String(format:"%02i:%02i:%02i", hours, minutes, seconds)
    }
}
