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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
        self.collectionView.register(UINib(nibName: FeaturedStoresCollectionViewCell.nibName(), bundle: nil), forCellWithReuseIdentifier: FeaturedStoresCollectionViewCell.nibName())
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    override func update(withModel model: Any!) {
        if let receivedFeaturedStore = model as? HomePageFeaturedStores {
            self.featuredStores = receivedFeaturedStore
            self.collectionView.reloadData()
        }
    }
    
    override static func cellHeight() -> CGFloat {
        return UIDevice.current.userInterfaceIdiom == .pad ? 110 : 90
    }
    
    //MARK: - UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let target = self.featuredStores?.items?[indexPath.row].target {
            self.delegate?.teaserItemTappedWithTargetString(target: target)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: FeaturedStoresCollectionViewCell.nibName(), for: indexPath) as? FeaturedStoresCollectionViewCell, let featuredStore = self.featuredStores?.items?[indexPath.row] {
            cell.indexPath = indexPath
            cell.update(withModel: featuredStore)
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth: CGFloat = UIScreen.main.bounds.width / (UIDevice.current.userInterfaceIdiom == .pad ? 6.5 : 4.5)
        let cellHeight: CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? 110 : 90
        return CGSize(width: cellWidth, height: cellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.featuredStores?.items?.count ?? 0
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
}
