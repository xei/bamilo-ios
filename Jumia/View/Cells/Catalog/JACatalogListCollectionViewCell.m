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
#import "JARatingsView.h"

@interface JACatalogListCollectionViewCell () {
    CGFloat _lastWidth;
    CGRect _ratingsViewRect;
    
    JARatingsView *_ratingsView;
    UILabel *_numberOfReviewsLabel;
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
    
    _numberOfReviewsLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _numberOfReviewsLabel.font = JABody3Font;
    _numberOfReviewsLabel.textColor = JABlack800Color;
    [self addSubview:_numberOfReviewsLabel];
    _ratingsView = [JARatingsView getNewJARatingsView];
    _ratingsView.rating = 0;
    _ratingsViewRect = _ratingsView.frame;
    [self addSubview:_ratingsView];
    [_ratingsView setHidden:YES];
    [_numberOfReviewsLabel setHidden:YES];
}

- (void)reloadViews
{
    [super reloadViews];
    [_numberOfReviewsLabel setY:CGRectGetMaxY(self.priceView.frame) + 7.f];
    
    [_ratingsView setFrame:CGRectMake(80,
                                      _numberOfReviewsLabel.y,
                                      _ratingsViewRect.size.width,
                                      _ratingsViewRect.size.height)];
    
    [_numberOfReviewsLabel setX:CGRectGetMaxX(_ratingsView.frame) + JACatalogCellPriceLabelOffsetX + 10];
    
    [_ratingsView setY:_numberOfReviewsLabel.y];

    if (RI_IS_RTL) {
        [_numberOfReviewsLabel flipViewPositionInsideSuperview];
        [_ratingsView flipViewPositionInsideSuperview];
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
    
    
    if (0 == [product.sum integerValue] && _ratingsView.rating != 0) {
        [_ratingsView setHidden:YES];
        [_numberOfReviewsLabel setHidden:YES];
    }else if (0 != [product.sum integerValue] && _ratingsView.rating == 0) {
        [_ratingsView setHidden:NO];
        [_numberOfReviewsLabel setHidden:NO];
    }
    
    _ratingsView.rating = [product.avr integerValue];
    
    BOOL refresh = NO;
    if (0 != [product.sum integerValue]) {
        
        if (!_ratingRefresh) {
            refresh = YES;
            _ratingRefresh = YES;
        }
        
        if (1 == [product.sum integerValue]) {
            _numberOfReviewsLabel.text = @"";
        } else {
            _numberOfReviewsLabel.text = [NSString stringWithFormat:STRING_NRATINGS, [product.sum integerValue]];
        }
        [_numberOfReviewsLabel sizeToFit];
    }
    
    if (_lastWidth != self.width || refresh) {
        [self reloadViews];
    }
}

@end
