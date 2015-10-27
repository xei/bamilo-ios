//
//  JAPDVVariationsCollectionViewCell.h
//  Jumia
//
//  Created by claudiosobrinho on 21/10/15.
//  Copyright © 2015 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JACatalogListCollectionViewCell.h"


@interface JAPDVVariationsCollectionViewCell : JACatalogListCollectionViewCell

@property (nonatomic) UIView *bottomHorizontalSeparator;
@property (nonatomic) UIView *topHorizontalSeparator;
@property (nonatomic) UIView *rightVerticalSeparator;

- (void)initViews;
- (void)reloadViews;

@end
