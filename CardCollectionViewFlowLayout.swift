//
//  CardCollectionViewFlowLayout.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 5/16/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

import UIKit

class CardCollectionViewFlowLayout: BaseCatalogCollectionFlowLayout {
    
    let otherContentHeight: CGFloat = 90
    let cellSpacing: CGFloat = 5
    let imageRatio: CGFloat = 1.25
    let imageWidthProportionalToParentWidth: CGFloat = 176 / 348
    
    
    override func setupLayout() {
        super.setupLayout()
        minimumInteritemSpacing = 0
        minimumLineSpacing = cellSpacing
        scrollDirection = .vertical
    }
    
    override func itemWidth() -> CGFloat {
        return collectionView!.frame.width
    }
    
    override  func itemHeight() -> CGFloat {
        let imageHeight = itemWidth() * imageWidthProportionalToParentWidth * imageRatio
        return imageHeight + otherContentHeight
    }
    
    
}
