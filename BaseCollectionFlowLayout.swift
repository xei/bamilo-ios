//
//  BaseCollectionFlowLayout.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 5/24/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

import UIKit

class BaseCollectionFlowLayout: UICollectionViewFlowLayout {
    
    var cellSpacing: CGFloat = 8
    
    override init() {
        super.init()
        setupLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupLayout()
    }
    
    //must be override
    func setupLayout() {
        return
    }
    
    //must be override
    func itemWidth() -> CGFloat {
        return 0
    }
    
    //must be override
    func itemHeight() -> CGFloat {
        return 0
    }
    
    override var itemSize: CGSize {
        set {}
        get {
            return CGSize(width: itemWidth(), height: itemHeight())
        }
    }
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint) -> CGPoint {
        return collectionView?.contentOffset ?? .zero
    }
}
