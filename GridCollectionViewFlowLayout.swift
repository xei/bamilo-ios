//
//  GridCollectionViewFlowLayout.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 5/15/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

import UIKit

class GridCollectionViewFlowLayout: UICollectionViewFlowLayout {
    
    let imageRatio: CGFloat = 1.25
    let numberOfColumns: CGFloat = 2
    let otherContentOfCellHeight: CGFloat = 107
    let righLeftImagePadding: CGFloat = 18 * 2
    let cellSpacing:CGFloat = 5
    
    override init() {
        super.init()
        setupLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupLayout()
    }
    
    func setupLayout() {
        minimumInteritemSpacing = cellSpacing / 2
        minimumLineSpacing = cellSpacing
        scrollDirection = .vertical
    }
    
    /// here we define the width of each cell, creating a 2 column layout. In case you would create 3 columns, change the number 2 to 3
    func itemWidth() -> CGFloat {
        return (self.collectionView!.frame.width - (numberOfColumns - 1) * cellSpacing) / numberOfColumns
    }
    
    func itemHeight() -> CGFloat {
        let imageWidth = itemWidth() - righLeftImagePadding
        return imageWidth * imageRatio + otherContentOfCellHeight
    }
    
    override var itemSize: CGSize {
        set {
            self.itemSize = CGSize(width: itemWidth(), height: itemHeight())
        }
        get {
            return CGSize(width: itemWidth(), height: itemHeight())
        }
    }
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint) -> CGPoint {
        return collectionView!.contentOffset
    }
    
}
