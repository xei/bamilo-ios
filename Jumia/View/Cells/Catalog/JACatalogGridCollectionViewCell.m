//
//  JACatalogGridCollectionViewCell.m
//  Jumia
//
//  Created by josemota on 7/6/15.
//  Copyright (c) 2015 Rocket Internet. All rights reserved.
//

#import "JACatalogGridCollectionViewCell.h"

#define xFavOffset 16.f

@interface JACatalogGridCollectionViewCell () {
    CGFloat _lastWidth;
}

@property (nonatomic, strong)JAProductInfoPriceLine* secondPriceLine;

@end

@implementation JACatalogGridCollectionViewCell

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

- (void)initViews
{
    [self addSubview:self.secondPriceLine];
    [super initViews];
}

- (JAProductInfoPriceLine *)secondPriceLine
{
    if (!VALID_NOTEMPTY(_secondPriceLine, JAProductInfoPriceLine)) {
        _secondPriceLine = [[JAProductInfoPriceLine alloc] initWithFrame:CGRectMake(0, 0, self.width, 15)];
        [_secondPriceLine setPriceSize:kPriceSizeSmall];
        [_secondPriceLine setLineContentXOffset:0.f];
    }
    return _secondPriceLine;
}

- (void)reloadViews
{
    [super reloadViews];
    
    CGSize imageSize = JACatalogViewControllerGridCellImageSize_ipad;
    CGFloat imageY = 10.0f;
    if ([UIDevice currentDevice].userInterfaceIdiom != UIUserInterfaceIdiomPad) {
        imageSize = JACatalogViewControllerGridCellImageSize;
    }
    CGFloat xOffset = 16.f;
    CGFloat brandYOffset = imageSize.height + imageY * 2;
    CGFloat verticalMarginBetweenLabels = 2.0f;

    CGFloat textWidth = self.width - xOffset*2;
    
    CGRect productImageViewRect = CGRectMake(self.width/2 - imageSize.width/2, imageY, imageSize.width, imageSize.height);
    if (!CGRectEqualToRect(productImageViewRect, self.productImageView.frame)) {
        [self.productImageView setFrame:productImageViewRect];
        [self setForRTL:self.productImageView];
    }
    
    CGRect brandLabelRect = CGRectMake(xOffset, brandYOffset, textWidth, 15);
    if (!CGRectEqualToRect(brandLabelRect, self.brandLabel.frame)) {
        [self.brandLabel setFrame:brandLabelRect];
        [self setForRTL:self.brandLabel];
    }
    
    CGRect nameLabelRect = CGRectMake(xOffset, CGRectGetMaxY(brandLabelRect) + verticalMarginBetweenLabels, textWidth, 15);
    if (!CGRectEqualToRect(nameLabelRect, self.nameLabel.frame)) {
        [self.nameLabel setFrame:nameLabelRect];
        [self setForRTL:self.nameLabel];
    }
    
    if (VALID_NOTEMPTY(self.product.priceRange, NSString)) {
        [self.priceLine setPrice:self.product.priceRange];
        [self.priceLine setOldPrice:nil];
        [self.secondPriceLine setHidden:YES];
        [self.discountLabel setHidden:YES];
    } else {
        if (VALID_NOTEMPTY(self.product.specialPriceFormatted, NSString)) {
            [self.priceLine setPrice:self.product.specialPriceFormatted];
            [self.priceLine setOldPrice:nil];
            [self.secondPriceLine setPrice:nil];
            [self.secondPriceLine setOldPrice:self.product.priceFormatted];
            [self.secondPriceLine setHidden:NO];
        } else {
            [self.secondPriceLine setHidden:YES];
        }
    }
    
    CGRect priceLineRect = CGRectMake(xOffset, CGRectGetMaxY(nameLabelRect) + verticalMarginBetweenLabels, self.priceLine.frame.size.width, self.priceLine.height);
    if (!CGRectEqualToRect(priceLineRect, self.priceLine.frame)) {
        [self.priceLine setFrame:priceLineRect];
        [self setForRTL:self.priceLine];
    }
    
    CGRect secondPriceLineRect = CGRectMake(xOffset, CGRectGetMaxY(priceLineRect) + verticalMarginBetweenLabels, self.secondPriceLine.frame.size.width, self.secondPriceLine.height);
    if (!CGRectEqualToRect(secondPriceLineRect, self.secondPriceLine.frame)) {
        [self.secondPriceLine setFrame:secondPriceLineRect];
        [self setForRTL:self.secondPriceLine];
    }
    
    CGRect discountLabelRect = CGRectMake(self.discountLabel.superview.width - self.discountLabel.frame.size.width - xOffset, priceLineRect.origin.y, self.discountLabel.frame.size.width, self.discountLabel.frame.size.height);
    if (!CGRectEqualToRect(discountLabelRect, self.discountLabel.frame)) {
        [self.discountLabel setFrame:discountLabelRect];
        [self setForRTL:self.discountLabel];
    }
    
    CGRect shopFirstRect = CGRectMake(xOffset, CGRectGetMaxY(self.secondPriceLine.frame) + verticalMarginBetweenLabels, self.shopFirstImageView.frame.size.width, self.shopFirstImageView.frame.size.height);
    if (!CGRectEqualToRect(shopFirstRect, self.self.shopFirstImageView.frame)) {
        [self.shopFirstImageView setFrame:shopFirstRect];
        [self setForRTL:self.shopFirstImageView];
    }
    
    CGFloat ratingTopMargin = 3.0f;
    CGRect ratingRect = CGRectMake(xOffset, CGRectGetMaxY(shopFirstRect) + ratingTopMargin, textWidth, self.ratingLine.imageHeight);
    if (!CGRectEqualToRect(ratingRect, self.ratingLine.frame)) {
        [self.ratingLine setFrame:ratingRect];
    }
    [self setForRTL:self.ratingLine];
    
    CGFloat favX = self.favoriteButton.superview.width - self.favoriteButton.width - xFavOffset;
    if (self.favoriteButton.x != favX) {
        [self.favoriteButton setX:favX];
        [self setForRTL:self.favoriteButton];
    }
        
    CGRect recentProductBadgeRect = CGRectMake(self.discountLabel.superview.width - self.discountLabel.frame.size.width - xOffset, CGRectGetMaxY(discountLabelRect) + 10.0f, self.discountLabel.frame.size.width, self.discountLabel.frame.size.height);
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
    
//    if (_lastWidth != self.width) {
        [self reloadViews];
//    }
}

@end
