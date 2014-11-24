//
//  JACatalogCell.h
//  Jumia
//
//  Created by Telmo Pinto on 07/08/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JAPriceView.h"
#import "JAClickableView.h"

#define JACatalogCellContentCornerRadius 3.0f
#define JACatalogCellNormalFont [UIFont fontWithName:@"HelveticaNeue" size:10.0f]
#define JACatalogCellLightFont [UIFont fontWithName:@"HelveticaNeue-Light" size:9.0f]
#define JACatalogCellRedFontColor UIColorFromRGB(0xcc0000)
#define JACatalogCellGrayFontColor UIColorFromRGB(0xcccccc)
#define JACatalogCellPriceLabelOffsetY 2.0f
#define JACatalogCellPriceLabelOffsetX 7.0f
#define JACatalogCellPriceLabelOffsetX_ipad 0.0f
#define JACatalogCellRatingsViewOffsetY 0.0f
#define JACatalogCellRatingsViewOffsetX 7.0f

@class RIProduct;
@class RICartItem;

@interface JACatalogCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIView *backgroundContentView;
@property (weak, nonatomic) IBOutlet UIImageView *productImageView;
@property (weak, nonatomic) IBOutlet UILabel *brandLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *recentProductImageView;
@property (strong, nonatomic)UILabel* recentLabel;
@property (weak, nonatomic) IBOutlet UIButton *favoriteButton;
@property (weak, nonatomic) IBOutlet UIImageView *discountImageView;
@property (weak, nonatomic) IBOutlet UILabel *discountLabel;
@property (weak, nonatomic) IBOutlet UIButton *sizeButton;
@property (weak, nonatomic) IBOutlet UILabel *sizeLabel;
@property (weak, nonatomic) IBOutlet JAClickableView *feedbackView;
@property (strong, nonatomic)JAPriceView *priceView;

- (void)loadWithProduct:(RIProduct*)product;
- (void)loadWithCartItem:(RICartItem*)cartItem;

@end
