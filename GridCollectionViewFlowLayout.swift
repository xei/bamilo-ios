//
//  GridCollectionViewFlowLayout.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 5/15/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

import UIKit

class GridCollectionViewFlowLayout: BaseCollectionFlowLayout {
    
    private let imageRatio: CGFloat = 1.25
    private let numberOfColumns: CGFloat = 2
    private let otherContentOfCellHeight: CGFloat = 128
    private let righLeftImagePadding: CGFloat = 10 * 2
    
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
