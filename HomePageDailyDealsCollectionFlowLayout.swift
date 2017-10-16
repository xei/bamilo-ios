//
//  HomePageDailyDealsCollectionFlowLayout.swift
//  Bamilo
//
//  Created by Ali Saeedifar on 10/9/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

import UIKit

class HomePageDailyDealsCollectionFlowLayout: CarouselCollectionFlowLayout {
    
    override  func itemHeight() -> CGFloat {
        return DailyDealsCollectionViewCell.cellHeight(relateTo: itemWidth())
    }
    
}
