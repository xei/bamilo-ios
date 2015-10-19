//
//  JAPDVProductInfoSellerInfo.m
//  Jumia
//
//  Created by josemota on 9/30/15.
//  Copyright © 2015 Rocket Internet. All rights reserved.
//

#import "JAPDVProductInfoSellerInfo.h"
#import "JAProductInfoRatingLine.h"

@interface JAPDVProductInfoSellerInfo ()

@property (nonatomic) UILabel *sellerNameLabel;
@property (nonatomic) UILabel *sellerDeliveryLabel;
@property (nonatomic) UILabel *sellerDeliveryTimeLabel;
@property (nonatomic) JAProductInfoRatingLine *sellerRatingLine;

@end

@implementation JAPDVProductInfoSellerInfo

- (UILabel *)sellerNameLabel
{
    if (!VALID_NOTEMPTY(_sellerNameLabel, UILabel)) {
        _sellerNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.width-32, 20)];
        [_sellerNameLabel setFont:JABody1Font];
        [_sellerNameLabel setTextColor:JABlack900Color];
        [self addSubview:_sellerNameLabel];
    }
    return _sellerNameLabel;
}

- (UILabel *)sellerDeliveryLabel
{
    if (!VALID_NOTEMPTY(_sellerDeliveryLabel, UILabel)) {
        _sellerDeliveryLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.sellerRatingLine.frame) + 8.f, self.width-32, 20)];
        [_sellerDeliveryLabel setFont:JABody3Font];
        [_sellerDeliveryLabel setTextColor:JABlack800Color];
        [self addSubview:_sellerDeliveryLabel];
    }
    return _sellerDeliveryLabel;
}

- (UILabel *)sellerDeliveryTimeLabel
{
    if (!VALID_NOTEMPTY(_sellerDeliveryTimeLabel, UILabel)) {
        _sellerDeliveryTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.sellerDeliveryLabel.frame) + 8.f, self.width-32, 20)];
        [_sellerDeliveryTimeLabel setFont:JACaptionFont];
        [_sellerDeliveryTimeLabel setTextColor:JABlack800Color];
        [self addSubview:_sellerDeliveryTimeLabel];
    }
    return _sellerDeliveryTimeLabel;
}

- (JAProductInfoRatingLine *)sellerRatingLine
{
    if (!VALID_NOTEMPTY(_sellerRatingLine, JAProductInfoRatingLine)) {
        _sellerRatingLine = [[JAProductInfoRatingLine alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.sellerNameLabel.frame), self.width, 0)];
        [_sellerRatingLine setHidden:YES];
//        _sellerRatingLine = [[JAProductInfoRatingLine alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.sellerNameLabel.frame), self.width, 25)];
        [_sellerRatingLine setTopSeparatorVisibility:NO];
        [_sellerRatingLine setBottomSeparatorVisibility:NO];
        [self addSubview:_sellerRatingLine];
    }
    return _sellerRatingLine;
}

- (void)setSeller:(RISeller *)seller
{
    _seller = seller;
    [self.sellerNameLabel setText:seller.name];
    [self.sellerRatingLine setNoMargin:YES];
    [self.sellerRatingLine setRatingAverage:seller.reviewAverage];
    [self.sellerRatingLine setRatingSum:seller.reviewTotal];
#warning TODO String
    [self.sellerDeliveryLabel setText:@"Delivered through"];
#warning TODO String
    [self.sellerDeliveryTimeLabel setText:[NSString stringWithFormat:@"%ld day(s) Replacement Guarantee", (long)seller.maxDeliveryTime.integerValue]];
    
    [self setHeight:CGRectGetMaxY(self.sellerDeliveryTimeLabel.frame) + 16.f];
}

- (void)addTarget:(id)target action:(SEL)action
{
    [self.sellerRatingLine addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
}

@end
