//
//  JACatalogCell.h
//  Jumia
//
//  Created by Telmo Pinto on 07/08/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JAProductInfoPriceLine.h"
#import "JAClickableView.h"
#import "UIButton+Extensions.h"

#define JACatalogCellContentCornerRadius 3.0f
#define JACatalogCellLightFont [UIFont fontWithName:kFontLightName size:9.0f]
#define JACatalogCellGrayFontColor JATextFieldColor
#define JACatalogCellPriceLabelOffsetY 2.0f
#define JACatalogCellPriceLabelOffsetX 7.0f
#define JACatalogCellPriceLabelOffsetX_ipad 6.0f

@class RIProduct;
@class RICartItem;

@interface JACatalogCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIView *backgroundContentView;
@property (weak, nonatomic) IBOutlet UIImageView *productImageView;
@property (weak, nonatomic) IBOutlet UILabel *brandLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *recentProductImageView;
@property (weak, nonatomic) IBOutlet UIButton *favoriteButton;
@property (weak, nonatomic) IBOutlet UIImageView *discountImageView;
@property (weak, nonatomic) IBOutlet UILabel *discountLabel;
@property (weak, nonatomic) IBOutlet UIButton *sizeButton;
@property (weak, nonatomic) IBOutlet UILabel *sizeLabel;
@property (weak, nonatomic) IBOutlet JAClickableView *feedbackView;
@property (strong, nonatomic)JAProductInfoPriceLine *priceLine;
@property (nonatomic) UIImageView *shopFirstLogo;
@property (nonatomic, retain) NSString * shopFirstOverlayText;

- (void)loadWithProduct:(RIProduct*)product;
- (void)loadWithCartItem:(RICartItem*)cartItem;

@end
