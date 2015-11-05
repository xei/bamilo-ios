//
//  JACatalogCollectionViewCell.h
//  Jumia
//
//  Created by josemota on 7/3/15.
//  Copyright (c) 2015 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RIProduct.h"
#import "JAPriceView.h"
#import "JAClickableView.h"
#import "UIButton+Extensions.h"
#import "RIVariation.h"
#import "JAProductInfoPriceLine.h"

#define JACatalogCellContentCornerRadius 3.0f
#define JACatalogCellNormalFont [UIFont fontWithName:kFontRegularName size:10.0f]
#define JACatalogCellLightFont [UIFont fontWithName:kFontLightName size:9.0f]
#define JACatalogCellRedFontColor UIColorFromRGB(0xcc0000)
#define JACatalogCellGrayFontColor UIColorFromRGB(0xcccccc)
#define JACatalogCellPriceLabelOffsetY 2.0f
#define JACatalogCellPriceLabelOffsetX 7.0f
#define JACatalogCellPriceLabelOffsetX_ipad 6.0f
#define JACatalogCellRatingsViewOffsetY 0.0f
#define JACatalogCellRatingsViewOffsetX 7.0f

typedef NS_ENUM(NSUInteger, JACatalogCollectionViewCellType) {
    JACatalogCollectionViewListCell = 0,
    JACatalogCollectionViewGridCell = 1,
    JACatalogCollectionViewPictureCell = 2
};

@interface JACatalogCollectionViewCell : UICollectionViewCell

@property (nonatomic) UIImageView *productImageView;
@property (nonatomic) UILabel *brandLabel;
@property (nonatomic) UILabel *nameLabel;
@property (nonatomic) UIImageView *recentProductImageView;
@property (nonatomic) UIButton *favoriteButton;
@property (nonatomic) UILabel *discountLabel;
@property (nonatomic) UIButton *sizeButton;
@property (nonatomic) JAClickableView *feedbackView;
@property (nonatomic) JAProductInfoPriceLine *priceLine;

@property (nonatomic) RIProduct *product;
@property (nonatomic) RIVariation *variation;

- (void)initViews;
- (void)reloadViews;
- (void)loadWithProduct:(RIProduct*)product;
- (void)loadWithVariation:(RIVariation*)variation;

- (void)setSimplePrice:(NSString *)price andOldPrice:(NSString *)oldPrice;

@end
