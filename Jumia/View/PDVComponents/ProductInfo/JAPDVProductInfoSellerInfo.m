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

@property (nonatomic) UIImageView *arrow;
@property (nonatomic) UILabel *sellerNameLabel;
@property (nonatomic) UILabel *sellerDeliveryLabel;
@property (nonatomic) UILabel *sellerDeliveryTimeLabel;
@property (nonatomic) JAProductInfoRatingLine *sellerRatingLine;

@end

@implementation JAPDVProductInfoSellerInfo

- (UIImageView *)arrow
{
    CGRect frame = CGRectMake(self.width - 16, self.height/2 - 6, 8, 12);
    if (!VALID_NOTEMPTY(_arrow, UIImageView)) {
        _arrow = [[UIImageView alloc] initWithFrame:frame];
        [_arrow setImage:[UIImage imageNamed:@"arrow_moreinfo"]];
        [_arrow setHidden:YES];
        [_arrow setX:self.width - 16 - _arrow.width];
        [_arrow setY:self.height/2 - _arrow.height/2];
        [self addSubview:_arrow];
    }else if(!CGRectEqualToRect(frame, _arrow.frame)) {
        [_arrow setFrame:frame];
    }
    return _arrow;
}

- (UILabel *)sellerNameLabel
{
    if (!VALID_NOTEMPTY(_sellerNameLabel, UILabel)) {
        _sellerNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, 16, self.width-32, 20)];
        [_sellerNameLabel setFont:JABody1Font];
        [_sellerNameLabel setTextColor:JABlack900Color];
        [self addSubview:_sellerNameLabel];
    }
    return _sellerNameLabel;
}

- (UILabel *)sellerDeliveryLabel
{
    if (!VALID_NOTEMPTY(_sellerDeliveryLabel, UILabel)) {
        _sellerDeliveryLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, CGRectGetMaxY(self.sellerRatingLine.frame) + 8.f, self.width-32, 20)];
        [_sellerDeliveryLabel setFont:JABody3Font];
        [_sellerDeliveryLabel setTextColor:JABlack800Color];
        [self addSubview:_sellerDeliveryLabel];
    }
    return _sellerDeliveryLabel;
}

- (UILabel *)sellerDeliveryTimeLabel
{
    if (!VALID_NOTEMPTY(_sellerDeliveryTimeLabel, UILabel)) {
        _sellerDeliveryTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, CGRectGetMaxY(self.sellerDeliveryLabel.frame) + 8.f, self.width-32, 20)];
        [_sellerDeliveryTimeLabel setFont:JACaptionFont];
        [_sellerDeliveryTimeLabel setTextColor:JABlack800Color];
        [self addSubview:_sellerDeliveryTimeLabel];
    }
    return _sellerDeliveryTimeLabel;
}

- (JAProductInfoRatingLine *)sellerRatingLine
{
    if (!VALID_NOTEMPTY(_sellerRatingLine, JAProductInfoRatingLine)) {
        _sellerRatingLine = [[JAProductInfoRatingLine alloc] initWithFrame:CGRectMake(16, CGRectGetMaxY(self.sellerNameLabel.frame), self.width, 0)];
        [_sellerRatingLine setHidden:YES];
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
    [self arrow];
}

- (void)addTarget:(id)target action:(SEL)action
{
    [self addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    [self.arrow setHidden:NO];
}

@end
