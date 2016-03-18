//
//  JACatalogPictureCollectionViewCell.m
//  Jumia
//
//  Created by miguelseabra on 30/09/15.
//  Copyright (c) 2015 Rocket Internet. All rights reserved.
//

#import "JACatalogPictureCollectionViewCell.h"
#import "JAProductInfoRatingLine.h"

// as of https://jira.rocket-internet.de/browse/NAFAMZ-14582
#define xFavOffset 16.f

@interface JACatalogPictureCollectionViewCell () {
    CGFloat _lastWidth;
}

@end

@implementation JACatalogPictureCollectionViewCell

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
    [super initViews];
}

- (void)reloadViews
{
    [super reloadViews];
    
    CGSize imageSize = CGSizeMake(228, 287);
    CGFloat imageY = 16.0f;
    CGFloat xOffset = 16.f;
    CGFloat brandYOffset = imageSize.height + imageY + 10.0f;
    CGFloat distXRecent = 16.f;
    
    CGFloat textWidth = self.width - xOffset*2;
    if (NO == self.discountLabel.hidden) {
        textWidth -= self.discountLabel.frame.size.width;
    }
    
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
    
    CGRect nameLabelRect = CGRectMake(xOffset, CGRectGetMaxY(brandLabelRect) + 2.0f, textWidth, 15);
    if (!CGRectEqualToRect(nameLabelRect, self.nameLabel.frame)) {
        [self.nameLabel setFrame:nameLabelRect];
        [self setForRTL:self.nameLabel];
    }
    
    CGRect priceLineRect = CGRectMake(xOffset, CGRectGetMaxY(nameLabelRect) + 2.0f, textWidth, self.priceLine.height);
    if (!CGRectEqualToRect(priceLineRect, self.priceLine.frame)) {
        [self.priceLine setFrame:priceLineRect];
    }
    [self setForRTL:self.priceLine];
    
    CGFloat favX = self.favoriteButton.superview.width - self.favoriteButton.width - xFavOffset;
    if (self.favoriteButton.x != favX) {
        [self.favoriteButton setX:favX];
        [self setForRTL:self.favoriteButton];
    }
    
    
    CGRect shopFirstRect = CGRectMake(xOffset, CGRectGetMaxY(self.priceLine.frame) + 5.f, self.shopFirstImageView.frame.size.width, self.shopFirstImageView.frame.size.height);
    if (!CGRectEqualToRect(shopFirstRect, self.self.shopFirstImageView.frame)) {
        [self.shopFirstImageView setFrame:shopFirstRect];
        [self setForRTL:self.shopFirstImageView];
    }
    
    CGRect ratingRect = CGRectMake(xOffset, self.frame.size.height - 12.0f - self.ratingLine.imageHeight, textWidth, self.ratingLine.imageHeight);
    if (!CGRectEqualToRect(ratingRect, self.ratingLine.frame)) {
        [self.ratingLine setFrame:ratingRect];
    }
    [self setForRTL:self.ratingLine];
    
    
    CGRect discountLabelRect = CGRectMake(self.discountLabel.superview.width - self.discountLabel.frame.size.width - xOffset, nameLabelRect.origin.y, self.discountLabel.frame.size.width, self.discountLabel.frame.size.height);
    if (!CGRectEqualToRect(discountLabelRect, self.discountLabel.frame)) {
        [self.discountLabel setFrame:discountLabelRect];
        [self setForRTL:self.discountLabel];
    }
    
    CGRect recentProductBadgeRect = CGRectMake(self.recentProductBadgeLabel.superview.width - self.recentProductBadgeLabel.frame.size.width - distXRecent, CGRectGetMaxY(discountLabelRect) + 10.0f, self.recentProductBadgeLabel.frame.size.width, self.recentProductBadgeLabel.frame.size.height);
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
    [self.priceLine setX:16];
    
    [self reloadViews];
}


@end
