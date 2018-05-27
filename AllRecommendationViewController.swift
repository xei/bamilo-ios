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
    
    @IBOutlet weak private var collectionViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak private var collectionView: UICollectionView!
    @objc var recommendItems: [RecommendItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = Theme.color(kColorVeryLightGray)
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.backgroundColor = .clear
        
        self.collectionView.register(UINib(nibName: CatalogGridCollectionViewCell.nibName, bundle: nil), forCellWithReuseIdentifier: CatalogGridCollectionViewCell.nibName)
        let flowLayout = GridCollectionViewFlowLayout()
        self.collectionView.contentInset = UIEdgeInsets(top: flowLayout.cellSpacing, left: 0, bottom: flowLayout.cellSpacing, right: 0)
        self.collectionView.collectionViewLayout = flowLayout
        
        if let tabbar = self.tabBarController?.tabBar {
            self.collectionViewBottomConstraint.constant = tabbar.frame.height
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.hidesBottomBarWhenPushed = false
        self.tabBarController?.tabBar.isHidden = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    //MARK: - UICollectionViewDataSource & UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: CatalogGridCollectionViewCell.nibName, for: indexPath) as! CatalogGridCollectionViewCell
        let product = self.recommendItems[indexPath.row].convertToProduct()
        cell.updateWithProduct(product: product)
        cell.hideAddToFavoriteButton(hidden: true)
        cell.cellIndex = indexPath.row
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "showPDVViewController", sender: self.recommendItems[indexPath.row].sku)
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let segueName = segue.identifier
        if segueName == "showPDVViewController", let pdvViewCtrl = segue.destination as? JAPDVViewController, let sku = sender as? String {
            pdvViewCtrl.productSku = sku
        }
    }
}
