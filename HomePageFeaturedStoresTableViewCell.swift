//
//  HomePageFeaturedStoresTableViewCell.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 9/23/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

import UIKit

class HomePageFeaturedStoresTableViewCell: BaseHomePageTeaserBoxTableViewCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var collectionView: UICollectionView!
    private var featuredStores: HomePageFeaturedStores?
    private static var bottomPadding: CGFloat = 10
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear
        
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
    
    override static func cellHeight() -> CGFloat {
        return HomePageFeaturedStoresTableViewCell.cellSize().height + 4 + self.bottomPadding //4 point for shadow
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
            cell.indexPath = indexPath
            if indexPath.row == 0 {
                cell.title = STRING_ALL_CATEGORIES
                cell.image = UIImage(named: "all_cats")
                return cell
            } else if let featuredStore = self.featuredStores?.items?[indexPath.row - 1] {
                cell.update(withModel: featuredStore)
                
                if indexPath.row == (self.featuredStores?.items?.count ?? 1) {
                    //last one
                    cell.roundCorners([.topLeft, .bottomLeft], radius: 5)
                }
                
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
