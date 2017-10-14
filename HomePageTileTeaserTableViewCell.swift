//
//  HomePageTileTeaserTableViewCell.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 10/11/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

import UIKit
import Kingfisher

class HomePageTileTeaserTableViewCell: BaseHomePageTeaserBoxTableViewCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, HomePageTeaserHeightCalculator {

    @IBOutlet weak var collectionViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var collectionViewLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var collectionViewRightConstraint: NSLayoutConstraint!
    @IBOutlet weak private var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewTopConstraint: NSLayoutConstraint!
    
    private var validItemCount = 0
    private static let wideCellRatio:CGFloat = 2.86
    private static let smallCellRatio:CGFloat = 1.4
    private static let cellSpacing: CGFloat = 8
    
    static let collectionPadding: CGFloat = 8
    
    private var dataSource: HomePageTileTeaser? {
        didSet {
            self.validItemCount = HomePageTileTeaserTableViewCell.getVaildItemsCount(data: dataSource)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = .clear
        self.clipsToBounds = false
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
        self.collectionViewTopConstraint.constant = 0
        self.collectionViewBottomConstraint.constant = HomePageTileTeaserTableViewCell.collectionPadding
        self.collectionViewLeftConstraint.constant = HomePageTileTeaserTableViewCell.collectionPadding
        self.collectionViewRightConstraint.constant = HomePageTileTeaserTableViewCell.collectionPadding
        self.collectionView.isScrollEnabled = false
        self.collectionView.backgroundColor = .clear
        
        self.collectionView.register(UINib(nibName: TileTeaserCollectionViewCell.nibName, bundle: nil), forCellWithReuseIdentifier: TileTeaserCollectionViewCell.nibName)
    }
    
    override func update(withModel model: Any!) {
        if let tiles = model as? HomePageTileTeaser {
            self.dataSource = tiles
            self.collectionView.reloadData()
        }
    }
    
    private static func getVaildItemsCount(data: HomePageTileTeaser?) -> Int {
        let itemsCount = data?.items?.count ?? 0
        let validCount = itemsCount % 2 != 0 ? itemsCount : itemsCount - 1 //only odd items count
        return min(validCount, 5)
    }
    
    //MARK: - UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewFlowLayout
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: TileTeaserCollectionViewCell.nibName, for: indexPath) as! TileTeaserCollectionViewCell
        cell.image?.kf.indicatorType = .activity
        cell.cellIndex = indexPath.row
        cell.image.kf.setImage(with: self.dataSource?.items?[indexPath.row].imageUrl, options: [.transition(.fade(0.20))])
        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let target =  self.dataSource?.items?[indexPath.row].target {
            self.delegate?.teaserItemTappedWithTargetString(target: target)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return validItemCount
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.row == 0 && validItemCount != 5 || indexPath.row == 2 && validItemCount == 5 {
            return CGSize(width: self.collectionView.frame.width, height: self.collectionView.frame.width / HomePageTileTeaserTableViewCell.wideCellRatio)
        } else {
            let cellWidthSize = (self.collectionView.frame.width - HomePageTileTeaserTableViewCell.cellSpacing) / 2
            return CGSize(width: cellWidthSize , height: cellWidthSize / HomePageTileTeaserTableViewCell.smallCellRatio)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return HomePageTileTeaserTableViewCell.cellSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return HomePageTileTeaserTableViewCell.cellSpacing
    }
    
    //MARK: - HomePageTeaserHeightCalculator
    static func teaserHeight(model: Any?) -> CGFloat {
        if let model = model as? HomePageTileTeaser {
            let items = self.getVaildItemsCount(data: model)
            let screenWidth = UIScreen.main.bounds.width
            let collectionviewWidth = (screenWidth - collectionPadding * 2)
            let wideCellHeightWidthBottomSpace = collectionviewWidth / wideCellRatio + cellSpacing
            let smallCellHeightWidthBottomSpace = (collectionviewWidth - cellSpacing) / (2 * smallCellRatio) + cellSpacing
            var height = wideCellHeightWidthBottomSpace
            
            if items > 1 {
                height += smallCellHeightWidthBottomSpace
            }
            if items > 3 {
                height += wideCellHeightWidthBottomSpace
            }
            height -= cellSpacing //as last cellspacing
            height += collectionPadding //as bottom padding of cell
            
            return height
        }
        return 0
    }
}
