//
//  GridCollectionViewFlowLayout.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 5/15/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

import UIKit

class GridCollectionViewFlowLayout: BaseCatalogCollectionFlowLayout {
    
    let imageRatio: CGFloat = 1.25
    let numberOfColumns: CGFloat = 2
    let otherContentOfCellHeight: CGFloat = 107
    let righLeftImagePadding: CGFloat = 18 * 2
    let cellSpacing:CGFloat = 5
    
    
    override func setupLayout() {
        minimumInteritemSpacing = cellSpacing / 2
        minimumLineSpacing = cellSpacing
        scrollDirection = .vertical
    }
    
    override func itemWidth() -> CGFloat {
        return (self.collectionView!.frame.width - (numberOfColumns - 1) * cellSpacing) / numberOfColumns
    }
    
    override func itemHeight() -> CGFloat {
        let imageWidth = itemWidth() - righLeftImagePadding
        return imageWidth * imageRatio + otherContentOfCellHeight
    }
}
