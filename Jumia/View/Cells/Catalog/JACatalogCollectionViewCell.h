//
//  JACatalogCollectionViewCell.h
//  Jumia
//
//  Created by josemota on 7/3/15.
//  Copyright (c) 2015 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIButton+Extensions.h"

#import "JAPriceView.h"
#import "JAClickableView.h"
#import "JAProductInfoPriceLine.h"
#import "JAProductInfoRatingLine.h"
#import "JADropdownControl.h"

#import "RIProduct.h"
#import "RIVariation.h"
#import "RICartItem.h"

#define JACatalogCellPriceLabelOffsetX 7.0f
#define JACatalogCellPriceLabelOffsetX_ipad 6.0f

typedef NS_ENUM(NSUInteger, JACatalogCollectionViewCellType) {
    JACatalogCollectionViewListCell = 0,
    JACatalogCollectionViewGridCell = 1,
    JACatalogCollectionViewPictureCell = 2
};

@interface JACatalogCollectionViewCell : UICollectionViewCell

@property (nonatomic) UIImageView *productImageView;
@property (nonatomic) UILabel *brandLabel;
@property (nonatomic) UILabel *nameLabel;
@property (nonatomic) UILabel *recentProductBadgeLabel;
@property (nonatomic) UIButton *favoriteButton;
@property (nonatomic) UILabel *discountLabel;
@property (nonatomic) JADropdownControl *sizeButton;
@property (nonatomic) JAClickableView *feedbackView;
@property (nonatomic) JAProductInfoPriceLine *priceLine;
@property (nonatomic) JAProductInfoRatingLine *ratingLine;
@property (nonatomic) UIImageView *shopFirstImageView;

@property (nonatomic) RIProduct *product;
@property (nonatomic) RIVariation *variation;
@property (nonatomic) RICartItem *cartItem;
@property (nonatomic) BOOL hideShopFirstLogo;
@property (nonatomic) BOOL hideRating;

- (void)initViews;
- (void)reloadViews;

- (void)setSimplePrice:(NSString *)price andOldPrice:(NSString *)oldPrice;

@end
