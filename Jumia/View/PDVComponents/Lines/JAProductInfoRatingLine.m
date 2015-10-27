//
//  JAProductInfoRatingLine.m
//  Jumia
//
//  Created by josemota on 9/23/15.
//  Copyright (c) 2015 Rocket Internet. All rights reserved.
//

#import "JAProductInfoRatingLine.h"

@interface JAProductInfoRatingLine ()

@property (nonatomic) UIImageView *star1;
@property (nonatomic) UIImageView *star2;
@property (nonatomic) UIImageView *star3;
@property (nonatomic) UIImageView *star4;
@property (nonatomic) UIImageView *star5;

@property (nonatomic) UILabel *ratingSumLabel;

@property (nonatomic) CGFloat lineXOffset;
@property (nonatomic) NSString *imageSize;

@end

@implementation JAProductInfoRatingLine

@synthesize ratingSumLabel = _ratingSumLabel, lineXOffset = _lineXOffset;

- (UIImage *)getEmptyStar
{
    return [UIImage imageNamed:[NSString stringWithFormat:@"img_rating_star_%@_empty", self.imageSize]];
}

- (UIImage *)getFilledStar
{
    if (self.fashion) {
        return [UIImage imageNamed:[NSString stringWithFormat:@"img_rating_star_fashion_%@_full", self.imageSize]];
    }else{
        return [UIImage imageNamed:[NSString stringWithFormat:@"img_rating_star_%@_full", self.imageSize]];
    }
}

- (UIImageView *)star1
{
    if (!VALID_NOTEMPTY(_star1, UIImageView)) {
        _star1 = [[UIImageView alloc] initWithImage:[self getEmptyStar]];
        [_star1 setFrame:CGRectMake(self.lineXOffset, self.height/2-self.imageHeight/2, self.imageHeight, self.imageHeight)];
        [self addSubview:_star1];
    }
    return _star1;
}

- (UIImageView *)star2
{
    if (!VALID_NOTEMPTY(_star2, UIImageView)) {
        _star2 = [[UIImageView alloc] initWithImage:[self getEmptyStar]];
        [_star2 setFrame:CGRectMake(CGRectGetMaxX(self.star1.frame) + 2.f, self.height/2-self.imageHeight/2, self.imageHeight, self.imageHeight)];
        [self addSubview:_star2];
    }
    return _star2;
}

- (UIImageView *)star3
{
    if (!VALID_NOTEMPTY(_star3, UIImageView)) {
        _star3 = [[UIImageView alloc] initWithImage:[self getEmptyStar]];
        [_star3 setFrame:CGRectMake(CGRectGetMaxX(self.star2.frame) + 2.f, self.height/2-self.imageHeight/2, self.imageHeight, self.imageHeight)];
        [self addSubview:_star3];
    }
    return _star3;
}

- (UIImageView *)star4
{
    if (!VALID_NOTEMPTY(_star4, UIImageView)) {
        _star4 = [[UIImageView alloc] initWithImage:[self getEmptyStar]];
        [_star4 setFrame:CGRectMake(CGRectGetMaxX(self.star3.frame) + 2.f, self.height/2-self.imageHeight/2, self.imageHeight, self.imageHeight)];
        [self addSubview:_star4];
    }
    return _star4;
}

- (UIImageView *)star5
{
    if (!VALID_NOTEMPTY(_star5, UIImageView)) {
        _star5 = [[UIImageView alloc] initWithImage:[self getEmptyStar]];
        [_star5 setFrame:CGRectMake(CGRectGetMaxX(self.star4.frame) + 2.f, self.height/2-self.imageHeight/2, self.imageHeight, self.imageHeight)];
        [self addSubview:_star5];
    }
    return _star5;
}

- (UILabel *)ratingSumLabel
{
    if (!VALID_NOTEMPTY(_ratingSumLabel, UILabel)) {
        _ratingSumLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.star5.frame) + 6.f, 10, 30, 30)];
        [_ratingSumLabel setTextColor:[UIColor darkGrayColor]];
        [_ratingSumLabel setFont:JACaptionFont];
        [_ratingSumLabel setText:@"(0)"];
        [_ratingSumLabel sizeToFit];
        [_ratingSumLabel setY:self.height/2-_ratingSumLabel.height/2];
        [self addSubview:_ratingSumLabel];
    }
    return _ratingSumLabel;
}

- (NSString *)imageSize
{
    switch (self.imageRatingSize) {
        case kImageRatingSizeSmall:
            return @"small";
            break;
        case kImageRatingSizeMedium:
            return @"medium";
            break;
        case kImageRatingSizeBig:
            return @"big";
            break;
            
        default:
            return @"medium";
    }
}

- (CGFloat)imageHeight
{
    switch (self.imageRatingSize) {
        case kImageRatingSizeSmall:
            return 14.f;
            break;
        case kImageRatingSizeMedium:
            return 18.f;
            break;
        case kImageRatingSizeBig:
            return 22.f;
            break;
            
        default:
            return 18.f;
    }
}

- (CGFloat)lineXOffset
{
    if (!self.noMargin)
    {
        _lineXOffset = 16.0f;
    }else{
        _lineXOffset = 0.f;
    }
    return _lineXOffset;
}

- (void)setRatingAverage:(NSNumber *)ratingAverage
{
    self.star1.image = ratingAverage.integerValue < 1 ?
    [self getEmptyStar] :
    [self getFilledStar];
    
    self.star2.image = ratingAverage.integerValue < 2 ?
    [self getEmptyStar] :
    [self getFilledStar];
    
    self.star3.image = ratingAverage.integerValue < 3 ?
    [self getEmptyStar] :
    [self getFilledStar];
    
    self.star4.image = ratingAverage.integerValue < 4 ?
    [self getEmptyStar] :
    [self getFilledStar];
    
    self.star5.image = ratingAverage.integerValue < 5 ?
    [self getEmptyStar] :
    [self getFilledStar];
}

- (void)setRatingSum:(NSNumber *)ratingSum
{
    _ratingSum = ratingSum;
    if (ratingSum.integerValue == 0) {
#warning TODO String
        [self.ratingSumLabel setText:@"Be the first to rate"];
    }else
        [self.ratingSumLabel setText:[NSString stringWithFormat:@"(%@)", ratingSum]];
    [self.ratingSumLabel sizeToFit];
}

@end
