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
#define xFavOffset 20.f

@interface JACatalogPictureCollectionViewCell () {
    CGFloat _lastWidth;
    CGRect _ratingLineRect;
    BOOL _ratingRefresh;
}

@property (nonatomic) JAProductInfoRatingLine *ratingLine;

@end

@implementation JACatalogPictureCollectionViewCell

- (JAProductInfoRatingLine *)ratingLine
{
    if (!VALID_NOTEMPTY(_ratingLine, JAProductInfoRatingLine)) {
        _ratingLine = [[JAProductInfoRatingLine alloc] initWithFrame:CGRectZero];
        _ratingLine.fashion = NO;
        _ratingLine.imageRatingSize = kImageRatingSizeSmall;
        _ratingLine.lineContentXOffset = 0.f;
        _ratingLine.topSeparatorVisibility = NO;
        _ratingLine.bottomSeparatorVisibility = NO;
    }
    return _ratingLine;
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

- (void)initViews
{
    [super initViews];
    [self addSubview:self.ratingLine];
}

- (void)reloadViews
{
    [super reloadViews];
    
    CGSize imageSize = CGSizeMake(268, 340);
    CGFloat xOffset = 32.f;
    CGFloat discountWidth = 60.f;
    CGFloat brandYOffset = 355;
    CGFloat distXRecent = 16.f;
    
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
    
    [self.priceLine setFrame:CGRectMake(xOffset, CGRectGetMaxY(nameLabelRect) + 6.f, textWidth, 15)];
    
    CGRect productImageViewRect = CGRectMake(self.width/2 - imageSize.width/2, 8, imageSize.width, imageSize.height);
    if (!CGRectEqualToRect(productImageViewRect, self.productImageView.frame)) {
        [self.productImageView setFrame:productImageViewRect];
        [self setForRTL:self.productImageView];
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
    
    CGRect ratingLineRect = CGRectMake(xOffset, CGRectGetMaxY(self.priceLine.frame) + 14.f, textWidth, self.ratingLine.imageHeight);
    if (!CGRectEqualToRect(ratingLineRect, self.ratingLine.frame)) {
        [self.ratingLine setFrame:ratingLineRect];
    }
        [self setForRTL:self.ratingLine];
    //    }
    
    CGRect discountLabelRect = CGRectMake(self.discountLabel.superview.width - discountWidth - xOffset, CGRectGetMaxY(nameLabelRect), discountWidth, 19);
    if (!CGRectEqualToRect(discountLabelRect, self.discountLabel.frame)) {
        [self.discountLabel setFrame:discountLabelRect];
        [self setForRTL:self.discountLabel];
    }
    
    CGFloat recentX = distXRecent;
    if (self.recentProductBadgeLabel.x != recentX) {
        [self.recentProductBadgeLabel setX:recentX];
        [self setForRTL:self.recentProductBadgeLabel];
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
    [self.priceLine setX:16];
    
    if (0 == [product.sum integerValue] ) {
        [_ratingLine setHidden:YES];
    }else{
        [_ratingLine setHidden:NO];
        
        self.ratingLine.ratingAverage = product.avr;
        self.ratingLine.ratingSum = product.sum;
    }
    [self reloadViews];
}


@end
