//
//  JAProductInfoPriceLine.m
//  Jumia
//
//  Created by josemota on 9/24/15.
//  Copyright (c) 2015 Rocket Internet. All rights reserved.
//

#import "JAProductInfoPriceLine.h"

@interface JAProductInfoPriceLine ()

@property (nonatomic) UILabel *priceOffLabel;
@property (nonatomic) UILabel *oldPriceLabel;
@property (nonatomic) UIView *oldPriceLine;

@end

@implementation JAProductInfoPriceLine

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setDefaults];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setDefaults];
    }
    return self;
}

- (void)setDefaults
{
}

- (UILabel *)priceOffLabel
{
    if (!VALID_NOTEMPTY(_priceOffLabel, UILabel)) {
        CGFloat priceOffLabelX = CGRectGetMaxX(self.label.frame) + 10.f;
        if (VALID_NOTEMPTY(_oldPrice, NSString)) {
            priceOffLabelX = CGRectGetMaxX(_priceOffLabel.frame) + 10.f;
        }
        _priceOffLabel = [[UILabel alloc] initWithFrame:CGRectMake(priceOffLabelX, 0, 60, 30)];
        UIColor *priceOffColor = JAOrange1Color;
        [_priceOffLabel setTextColor:priceOffColor];
        [_priceOffLabel setFont:JACaptionFont];
        [_priceOffLabel setTextAlignment:NSTextAlignmentCenter];
        [_priceOffLabel.layer setBorderWidth:1];
        [_priceOffLabel.layer setBorderColor:priceOffColor.CGColor];
        [self addSubview:_priceOffLabel];
    }
    return _priceOffLabel;
}

- (UILabel *)oldPriceLabel
{
    if (!VALID_NOTEMPTY(_oldPriceLabel, UILabel)) {
        _oldPriceLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.label.frame) + 10.f, self.label.y, 60, 30)];
        [_oldPriceLabel setTextColor:JABlack800Color];
        [_oldPriceLabel setFont:JAList2Font];
        [self addSubview:_oldPriceLabel];
    }
    return _oldPriceLabel;
}

- (void)setPriceOff:(NSInteger)priceOff
{
    _priceOff = priceOff;
    [self.priceOffLabel setText:[NSString stringWithFormat:@"-%ld%% OFF", (long)priceOff]];
    [self.priceOffLabel sizeToFit];
    [self.priceOffLabel setXRightOf:self.oldPriceLabel at:10.f];
    self.priceOffLabel.width += 6.f;
    self.priceOffLabel.height = self.oldPriceLabel.height;
    [self.priceOffLabel setY:self.oldPriceLabel.y];
}

- (void)setOldPrice:(NSString *)oldPrice
{
    _oldPrice = oldPrice;
    [self.label sizeToFit];
    [self.label setY:self.height/2 - self.label.height/2];
    [self.oldPriceLabel setText:oldPrice];
    [self.oldPriceLabel sizeToFit];
    [self.oldPriceLabel setY:self.height/2 - self.oldPriceLabel.height/2];
    [self.oldPriceLine setX:self.oldPriceLabel.x];
    [self.oldPriceLine setWidth:self.oldPriceLabel.width];
}

- (UILabel *)label
{
    [super.label setFont:JAList1Font];
    return super.label;
}

- (UIView *)oldPriceLine
{
    if (!VALID_NOTEMPTY(_oldPriceLine, UIView)) {
        _oldPriceLine = [[UIView alloc] initWithFrame:CGRectMake(0, self.height/2, 0, 1)];
        [_oldPriceLine setBackgroundColor:[UIColor lightGrayColor]];
        [self addSubview:_oldPriceLine];
    }
    return _oldPriceLine;
}

@end
