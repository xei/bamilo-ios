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

#define JACatalogViewControllerListCellHeight_ipad 97.0f + 25.f + 10.f // +25 = new label size / +10 = new label top margin - as of NAFAMZ-15160: https://jira.rocket-internet.de/browse/NAFAMZ-15160
#define JACatalogViewControllerListCellHeight 97.0f + 25.f + 10.f // +25 = new label size / +10 = new label top margin - as of NAFAMZ-15160: https://jira.rocket-internet.de/browse/NAFAMZ-15160
#define JACatalogViewControllerListCellNewLabelX 4.0f
#define JACatalogViewControllerListCellNewLabelY 15.0f
#define JACatalogViewControllerListCellNewLabelX_ipad -2.0f
#define JACatalogViewControllerListCellNewLabelY_ipad 20.0f
#define JACatalogListCellImageSize CGSizeMake(68, 85)
#define JACatalogListCellDistXImage_ipad 32.f
#define JACatalogListCellDistXImage 6.f
#define JACatalogListCellDistXAfterImage_ipad 16.f
#define JACatalogListCellDistXAfterImage 6.f
#define JACatalogListCellBrandTextWidth_ipad 55.f
#define JACatalogListCellBrandTextWidth 40.f

@interface JACatalogListCollectionViewCell : JACatalogCollectionViewCell

@property (nonatomic) BOOL hideRating;
@property (nonatomic) BOOL showSelector;
@property (nonatomic) UIButton *selectorButton;
@property (nonatomic, readonly) JAProductInfoRatingLine *ratingLine;
@property (nonatomic) BOOL hideShopFirstLogo;

@end
