//
//  AllRecommendationViewController.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 11/15/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

import UIKit

class AllRecommendationViewController: BaseViewController,
    UICollectionViewDelegate,
UICollectionViewDataSource {
    
    @IBOutlet weak private var collectionView: UICollectionView!
    var recommendItems: [RecommendItem] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
        self.collectionView.register(UINib(nibName: CatalogGridCollectionViewCell.nibName, bundle: nil), forCellWithReuseIdentifier: CatalogGridCollectionViewCell.nibName)
        self.collectionView.collectionViewLayout = GridCollectionViewFlowLayout()
    }
    
    //MARK: - UICollectionViewDataSource & UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: CatalogGridCollectionViewCell.nibName, for: indexPath) as! CatalogGridCollectionViewCell
        let product = self.recommendItems[indexPath.row].convertToProduct()
        cell.updateWithProduct(product: product)
        cell.cellIndex = indexPath.row
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.recommendItems.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self.recommendItems.count > 1 ? 1 : 0
    }
    
    override func navBarTitleString() -> String! {
        return STRING_BAMILO_RECOMMENDATION
    }
}
