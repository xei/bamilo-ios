//
//  JACatalogGridCollectionViewCell.m
//  Jumia
//
//  Created by josemota on 7/6/15.
//  Copyright (c) 2015 Rocket Internet. All rights reserved.
//

#import "JACatalogGridCollectionViewCell.h"

#define xFavOffset 10.f

@interface JACatalogGridCollectionViewCell () {
    CGFloat _lastWidth;
}

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
    [super initViews];
}

- (void)reloadViews
{
    [super reloadViews];
    
    CGSize imageSize = CGSizeMake(112, 140);
    CGFloat xOffset = 16.f;
    CGFloat discountWidth = 60.f;
    CGFloat brandYOffset = 170;
    
    if ([UIDevice currentDevice].userInterfaceIdiom != UIUserInterfaceIdiomPad) {
        xOffset = 6.f;
    }
    CGFloat textWidth = self.width - xOffset*2;
    
    CGRect brandLabelRect = CGRectMake(xOffset, brandYOffset, textWidth, 15);
    if (!CGRectEqualToRect(brandLabelRect, self.brandLabel.frame)) {
        [self.brandLabel setFrame:brandLabelRect];
        [self setForRTL:self.brandLabel];
    }
    
    CGRect nameLabelRect = CGRectMake(xOffset, CGRectGetMaxY(brandLabelRect), textWidth, 15);
    if (!CGRectEqualToRect(nameLabelRect, self.nameLabel.frame)) {
        [self.nameLabel setFrame:nameLabelRect];
        [self setForRTL:self.nameLabel];
    }
    
    CGRect productImageViewRect = CGRectMake(self.width/2 - imageSize.width/2, 8, imageSize.width, imageSize.height);
    if (!CGRectEqualToRect(productImageViewRect, self.productImageView.frame)) {
        [self.productImageView setFrame:productImageViewRect];
        [self setForRTL:self.productImageView];
    }
    
    CGRect discountLabelRect = CGRectMake(self.discountLabel.superview.width - discountWidth - xOffset, CGRectGetMaxY(productImageViewRect), discountWidth, 19);
    if (!CGRectEqualToRect(discountLabelRect, self.discountLabel.frame)) {
        [self.discountLabel setFrame:discountLabelRect];
        [self setForRTL:self.discountLabel];
    }
    
    CGRect priceLineRect = CGRectMake(xOffset, CGRectGetMaxY(nameLabelRect) + 6.f, textWidth, self.priceLine.height);
    if (!CGRectEqualToRect(priceLineRect, self.priceLine.frame)) {
        [self.priceLine setFrame:priceLineRect];
    }
    [self setForRTL:self.priceLine];
    
    CGFloat favX = self.favoriteButton.superview.width - self.favoriteButton.width - xFavOffset;
    if (self.favoriteButton.x != favX) {
        [self.favoriteButton setX:favX];
        [self setForRTL:self.favoriteButton];
    }
    
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
