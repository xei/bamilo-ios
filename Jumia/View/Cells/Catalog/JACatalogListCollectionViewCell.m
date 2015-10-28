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
#import "JAProductInfoRatingLine.h"

@interface JACatalogListCollectionViewCell () {
    CGFloat _lastWidth;
    CGRect _ratingLineRect;
    
    JAProductInfoRatingLine *_ratingLine;
    BOOL _ratingRefresh;
}

@end

@implementation JACatalogListCollectionViewCell

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
    
    _ratingLine = [[JAProductInfoRatingLine alloc] initWithFrame:CGRectZero];
    _ratingLine.fashion = NO;
    _ratingLine.imageRatingSize = kImageRatingSizeSmall;
    _ratingLine.noMargin = YES;
    _ratingLine.topSeparatorVisibility = NO;
    _ratingLine.bottomSeparatorVisibility = NO;
    [self addSubview:_ratingLine];
    [_ratingLine setHidden:YES];
}

- (void)reloadViews
{
    [super reloadViews];
    [_ratingLine setFrame:CGRectMake(80,
                                    CGRectGetMaxY(self.priceView.frame) + 14.f,
                                    _ratingLineRect.size.width,
                                    _ratingLineRect.size.height)];

    if (RI_IS_RTL) {
        [_ratingLine flipViewPositionInsideSuperview];
    }
    _lastWidth = self.width;
}

- (void)prepareForReuse
{
    [super prepareForReuse];
}

- (void)loadWithProduct:(RIProduct*)product
{
    [super loadWithProduct:product];
    
    
    if (0 == [product.sum integerValue] && _ratingLine.ratingSum != 0) {
        [_ratingLine setHidden:YES];
    }else if (0 != [product.sum integerValue] && _ratingLine.ratingSum == 0) {
        [_ratingLine setHidden:NO];
    }
    
    _ratingLine.ratingAverage = product.avr;
    _ratingLine.ratingSum = product.sum;
    
    BOOL refresh = NO;
    if (0 != [product.sum integerValue]) {
        
        if (!_ratingRefresh) {
            refresh = YES;
            _ratingRefresh = YES;
        }
    }
    
    if (_lastWidth != self.width || refresh) {
        [self reloadViews];
    }
}

- (void)loadWithVariation:(RIVariation *)variation
{
    [super loadWithVariation:variation];
    
    BOOL refresh = NO;
    
    if (_lastWidth != self.width || refresh) {
        [self reloadViews];
    }
}

@end
