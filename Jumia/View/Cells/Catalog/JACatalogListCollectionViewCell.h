//
//  JACatalogListCollectionViewCell.h
//  Jumia
//
//  Created by josemota on 7/2/15.
//  Copyright (c) 2015 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JACatalogCollectionViewCell.h"
#import "JAProductInfoRatingLine.h"

#define JACatalogViewControllerListCellHeight_ipad 123.0f
#define JACatalogViewControllerListCellHeight 123.0f
#define JACatalogViewControllerListCellNewLabelX 4.0f
#define JACatalogViewControllerListCellNewLabelY 15.0f
#define JACatalogViewControllerListCellNewLabelX_ipad -2.0f
#define JACatalogViewControllerListCellNewLabelY_ipad 20.0f
#define JACatalogListCellImageSize CGSizeMake(78, 98)
#define JACatalogListCellDistXImage_ipad 16.f
#define JACatalogListCellDistXImage 16.f
#define JACatalogListCellDistXAfterImage_ipad 16.f
#define JACatalogListCellDistXAfterImage 16.f
#define JACatalogListCellBrandTextWidth_ipad 55.f
#define JACatalogListCellBrandTextWidth 40.f

@interface JACatalogListCollectionViewCell : JACatalogCollectionViewCell

@property (nonatomic) BOOL showSelector;
@property (nonatomic) UIButton *selectorButton;

@end
