//
//  HomePageFeaturedStoresTableViewCell.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 9/23/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

import UIKit

class HomePageFeaturedStoresTableViewCell: BaseHomePageTeaserBoxTableViewCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, HomePageTeaserHeightCalculator {
    
    @IBOutlet weak private var collectionViewContainer: UIView!
    @IBOutlet weak private var collectionView: UICollectionView!
    @IBOutlet weak private var collectionViewBottomConstraint: NSLayoutConstraint!
    
    
    private var featuredStores: HomePageFeaturedStores?
    private static var bottomPadding: CGFloat = 8
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.collectionViewBottomConstraint.constant = HomePageFeaturedStoresTableViewCell.bottomPadding
        
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear
        self.collectionView.layer.cornerRadius = 3
        self.collectionView.clipsToBounds = true
        
        self.collectionViewContainer.layer.shadowColor = UIColor.black.cgColor
        self.collectionViewContainer.layer.shadowOpacity = 0.1
        self.collectionViewContainer.layer.shadowRadius = 1
        self.collectionViewContainer.layer.shadowOffset = CGSize(width:1 , height: 1)
        self.collectionViewContainer.clipsToBounds = false
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
        self.collectionView.register(UINib(nibName: FeaturedStoresCollectionViewCell.nibName, bundle: nil), forCellWithReuseIdentifier: FeaturedStoresCollectionViewCell.nibName)
        
        let collectionFlowLayout = UICollectionViewFlowLayout()
        collectionFlowLayout.itemSize = HomePageFeaturedStoresTableViewCell.cellSize()
        collectionFlowLayout.minimumInteritemSpacing = 0.0
        collectionFlowLayout.minimumLineSpacing = 0.0
        collectionFlowLayout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        collectionFlowLayout.scrollDirection = .horizontal
        self.collectionView.collectionViewLayout = collectionFlowLayout
    }
    
    override func update(withModel model: Any!) {
        if let receivedFeaturedStore = model as? HomePageFeaturedStores {
            self.featuredStores = receivedFeaturedStore
            self.collectionView.reloadData()
        }
    }
 
    //MARK: - HomePageTeaserHeightCalculator
    static func teaserHeight(model: Any?) -> CGFloat {
        return HomePageFeaturedStoresTableViewCell.cellSize().height + self.bottomPadding //4 point for shadow
    }
    
    //MARK: - UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == 0 {
          MainTabBarViewController.showCategories()
        } else if let target = self.featuredStores?.items?[indexPath.row - 1].target {
            self.delegate?.teaserItemTappedWithTargetString(target: target)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: FeaturedStoresCollectionViewCell.nibName, for: indexPath) as? FeaturedStoresCollectionViewCell {
            if indexPath.row == 0 {
                cell.title = STRING_ALL_CATEGORIES
                cell.image = UIImage(named: "all_cats")
                return cell
            } else if let featuredStore = self.featuredStores?.items?[indexPath.row - 1] {
                cell.update(withModel: featuredStore)
                return cell
            }
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let itemCounts = self.featuredStores?.items?.count {
            return itemCounts + 1 //all category item
        } else {
          return 0
        }
    }
    
    private static func cellSize() -> CGSize {
        let cellWidth: CGFloat = round(UIScreen.main.bounds.width / (UIDevice.current.userInterfaceIdiom == .pad ? 6.5 :  4.5))
        let cellHeight: CGFloat = 106
        return CGSize(width: cellWidth, height: cellHeight)
    }
}
