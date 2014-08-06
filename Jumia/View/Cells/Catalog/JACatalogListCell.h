//
//  JACatalogListCell.h
//  Jumia
//
//  Created by Telmo Pinto on 05/08/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RIProduct;

@interface JACatalogListCell : UICollectionViewCell

- (void)loadWithProduct:(RIProduct*)product;

@end
