//
//  JACatalogListCollectionViewCell.m
//  Jumia
//
//  Created by josemota on 7/2/15.
//  Copyright (c) 2015 Rocket Internet. All rights reserved.
//

#import "JACatalogListCollectionViewCell.h"
#import "RIProduct.h"
#import "RIImage.h"
#import "UIImageView+WebCache.h"

#define xFavOffset 16.f

@interface JACatalogListCollectionViewCell () {
    CGFloat _lastWidth;
    BOOL _ratingRefresh;
}

@end

@implementation JACatalogListCollectionViewCell

- (UIButton *)selectorButton
{
    if (!VALID_NOTEMPTY(_selectorButton, UIButton)) {
        _selectorButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_selectorButton setImage:[UIImage imageNamed:@"check_empty"] forState:UIControlStateNormal];
        [_selectorButton setImage:[UIImage imageNamed:@"check"] forState:UIControlStateSelected];
        [_selectorButton setImage:[UIImage imageNamed:@"check"] forState:UIControlStateHighlighted];
        [_selectorButton setFrame:CGRectMake(self.favoriteButton.x, 8, 30, 30)];
        if (RI_IS_RTL) {
            [_selectorButton flipViewImage];
        }
    }
    return _selectorButton;
}

- (void)setShowSelector:(BOOL)showSelector
{
    _showSelector = showSelector;
    [self.favoriteButton setHidden:YES];
    [self addSubview:self.selectorButton];
}

- (instancetype)init
{
    //    NSLog(@"init");
    self = [super init];
    if (self) {
        [self initViews];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    //    NSLog(@"initWithCoder");
    self = [super initWithCoder:coder];
    if (self) {
        [self initViews];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    //    NSLog(@"initWithFrame");
    self = [super initWithFrame:frame];
    if (self) {
        [self initViews];
    }
    return self;
}

- (void)setTag:(NSInteger)tag
{
    [super setTag:tag];
    [self.selectorButton setTag:tag];
}

- (void)initViews
{
    [super initViews];
}

- (void)reloadViews
{
    [super reloadViews];
    
    CGFloat distXImage = JACatalogListCellDistXImage_ipad;
    CGFloat marginAfterImage = JACatalogListCellDistXAfterImage_ipad;
    CGFloat maxTextWidth = JACatalogListCellBrandTextWidth_ipad;
    if ([UIDevice currentDevice].userInterfaceIdiom != UIUserInterfaceIdiomPad) {
        distXImage = JACatalogListCellDistXImage;
        marginAfterImage = JACatalogListCellDistXAfterImage;
        maxTextWidth = JACatalogListCellBrandTextWidth;
    }
    CGFloat distXAfterImage = JACatalogListCellImageSize.width + distXImage + marginAfterImage;
    CGFloat brandTextWidth = self.width - distXAfterImage - maxTextWidth;
    CGFloat textWidth = self.width - distXAfterImage - distXImage;

    
    if (self.showSelector) {
        brandTextWidth -= 10;
        textWidth = brandTextWidth;
    }
    
    CGRect brandLabelRect = CGRectMake(distXAfterImage, 16, brandTextWidth, 15);
    if (!CGRectEqualToRect(brandLabelRect, self.brandLabel.frame)) {
        [self.brandLabel setFrame:brandLabelRect];
        [self setForRTL:self.brandLabel];
    }
    
    CGRect nameLabelRect = CGRectMake(distXAfterImage, CGRectGetMaxY(brandLabelRect) + 2.0f, textWidth, self.hideRating?100:15);
    if (!CGRectEqualToRect(nameLabelRect, self.nameLabel.frame)) {
        [self.nameLabel setFrame:nameLabelRect];
        if (self.hideRating) {
            [self.nameLabel sizeToFit];
            nameLabelRect = self.nameLabel.frame;
        }
        [self setForRTL:self.nameLabel];
    }
    
    CGRect priceLineRect = CGRectMake(distXAfterImage, CGRectGetMaxY(nameLabelRect) + 2.0f, textWidth, 15);
    if (!CGRectEqualToRect(priceLineRect, self.priceLine.frame)) {
        [self.priceLine setFrame:priceLineRect];
    }
    [self setForRTL:self.priceLine];
    
    CGRect ratingRect = CGRectMake(distXAfterImage, CGRectGetMaxY(priceLineRect) + 8.f, self.width - distXAfterImage, self.ratingLine.imageHeight);
    if (!CGRectEqualToRect(ratingRect, self.ratingLine.frame)) {
        [self.ratingLine setFrame:ratingRect];
    }
    [self setForRTL:self.ratingLine];
    
    CGRect shopFirstRect = CGRectMake(distXAfterImage, CGRectGetMaxY(ratingRect) + 8.f, self.shopFirstImageView.frame.size.width, self.shopFirstImageView.frame.size.height);
    if (!CGRectEqualToRect(shopFirstRect, self.self.shopFirstImageView.frame)) {
        [self.shopFirstImageView setFrame:shopFirstRect];
        [self setForRTL:self.shopFirstImageView];
    }
    
    CGRect productImageViewRect = CGRectMake(distXImage, 13.f, JACatalogListCellImageSize.width, JACatalogListCellImageSize.height);
    if (!CGRectEqualToRect(productImageViewRect, self.productImageView.frame)) {
        [self.productImageView setFrame:productImageViewRect];
        [self setForRTL:self.productImageView];
    }
    
    CGRect discountLabelRect = CGRectMake(self.discountLabel.superview.width - self.discountLabel.frame.size.width - distXImage, self.priceLine.frame.origin.y, self.discountLabel.frame.size.width, self.discountLabel.frame.size.height);
    if (!CGRectEqualToRect(discountLabelRect, self.discountLabel.frame)) {
        [self.discountLabel setFrame:discountLabelRect];
        [self setForRTL:self.discountLabel];
    }
    
    CGRect sizeButtonRect = CGRectMake(distXAfterImage, CGRectGetMaxY(priceLineRect), self.sizeButton.width, 20);
    if (!CGRectEqualToRect(sizeButtonRect, self.sizeButton.frame)) {
        [self.sizeButton setFrame:sizeButtonRect];
        self.sizeButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        if (RI_IS_RTL) {
            [self.sizeButton flipViewPositionInsideSuperview];
        }
    }
    
    CGFloat favX =  self.favoriteButton.superview.width - self.favoriteButton.width - xFavOffset;
    if (self.favoriteButton.x != favX) {
        [self.favoriteButton setX:favX];
        [self setForRTL:self.favoriteButton];
    }
    
    CGFloat selX = self.width - self.selectorButton.width - distXImage;
    if (self.selectorButton.x != selX) {
        [self.selectorButton setX:selX];
        [self setForRTL:self.selectorButton];
    }
    
    CGRect recentProductBadgeRect = CGRectMake(self.discountLabel.superview.width - self.discountLabel.frame.size.width - distXImage, CGRectGetMaxY(discountLabelRect) + 10.0f, self.discountLabel.frame.size.width, self.discountLabel.frame.size.height);
    if (!CGRectEqualToRect(recentProductBadgeRect, self.recentProductBadgeLabel.frame)) {
        [self.recentProductBadgeLabel setFrame:recentProductBadgeRect];
    }
    [self setForRTL:self.recentProductBadgeLabel];

    _lastWidth = self.width;
}

- (void)setForRTL:(UIView *)view
{
    if (RI_IS_RTL) {
        [view flipViewPositionInsideSuperview];
        [view flipAllSubviews];
        if ([view isKindOfClass:[UILabel class]] && [(UILabel *)view textAlignment] != NSTextAlignmentCenter) {
            [(UILabel *)view setTextAlignment:NSTextAlignmentRight];
        } else if ([view isKindOfClass:[UIButton class]] && [(UIButton*)view contentHorizontalAlignment] != UIControlContentHorizontalAlignmentCenter)
        {
            ((UIButton*)view).contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        }
    }
}

- (void)prepareForReuse
{
    [super prepareForReuse];
}

- (void)loadWithProduct:(RIProduct*)product
{
    [super loadWithProduct:product];
    
    [self reloadViews];
}

- (void)loadWithVariation:(RIVariation *)variation
{
    [super loadWithVariation:variation];
    self.sizeButton.hidden = YES;
    [self reloadViews];
}

@end
