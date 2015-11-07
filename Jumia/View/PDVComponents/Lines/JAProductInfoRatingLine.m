//
//  JAProductInfoRatingLine.m
//  Jumia
//
//  Created by josemota on 9/23/15.
//  Copyright (c) 2015 Rocket Internet. All rights reserved.
//

#import "JAProductInfoRatingLine.h"

@interface JAProductInfoRatingLine () {
    CGSize _viewBounds;
}

@property (nonatomic) UIImageView *star1;
@property (nonatomic) UIImageView *star2;
@property (nonatomic) UIImageView *star3;
@property (nonatomic) UIImageView *star4;
@property (nonatomic) UIImageView *star5;

@property (nonatomic) UILabel *ratingSumLabel;

@property (nonatomic) NSString *imageSize;

@end

@implementation JAProductInfoRatingLine

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
    CGRect frame = CGRectMake(self.lineContentXOffset, self.height/2-self.imageHeight/2, self.imageHeight, self.imageHeight);
    if (!VALID_NOTEMPTY(_star1, UIImageView)) {
        _star1 = [[UIImageView alloc] initWithImage:[self getEmptyStar]];
        [_star1 setFrame:frame];
        [self addSubview:_star1];
    }else if (!CGRectEqualToRect(_star1.frame, frame)) {
        [_star1 setFrame:frame];
    }
    return _star1;
}

- (UIImageView *)star2
{
    CGRect frame = CGRectMake(CGRectGetMaxX(self.star1.frame) + 2.f, self.height/2-self.imageHeight/2, self.imageHeight, self.imageHeight);
    if (!VALID_NOTEMPTY(_star2, UIImageView)) {
        _star2 = [[UIImageView alloc] initWithImage:[self getEmptyStar]];
        [_star2 setFrame:frame];
        [self addSubview:_star2];
    }else if (!CGRectEqualToRect(_star2.frame, frame)) {
        [_star2 setFrame:frame];
    }
    return _star2;
}

- (UIImageView *)star3
{
    CGRect frame = CGRectMake(CGRectGetMaxX(self.star2.frame) + 2.f, self.height/2-self.imageHeight/2, self.imageHeight, self.imageHeight);
    if (!VALID_NOTEMPTY(_star3, UIImageView)) {
        _star3 = [[UIImageView alloc] initWithImage:[self getEmptyStar]];
        [_star3 setFrame:frame];
        [self addSubview:_star3];
    }else if (!CGRectEqualToRect(_star3.frame, frame)) {
        [_star3 setFrame:frame];
    }
    return _star3;
}

- (UIImageView *)star4
{
    CGRect frame = CGRectMake(CGRectGetMaxX(self.star3.frame) + 2.f, self.height/2-self.imageHeight/2, self.imageHeight, self.imageHeight);
    if (!VALID_NOTEMPTY(_star4, UIImageView)) {
        _star4 = [[UIImageView alloc] initWithImage:[self getEmptyStar]];
        [_star4 setFrame:frame];
        [self addSubview:_star4];
    }else if (!CGRectEqualToRect(_star4.frame, frame)) {
        [_star4 setFrame:frame];
    }
    return _star4;
}

- (UIImageView *)star5
{
    CGRect frame = CGRectMake(CGRectGetMaxX(self.star4.frame) + 2.f, self.height/2-self.imageHeight/2, self.imageHeight, self.imageHeight);
    if (!VALID_NOTEMPTY(_star5, UIImageView)) {
        _star5 = [[UIImageView alloc] initWithImage:[self getEmptyStar]];
        [_star5 setFrame:frame];
        [self addSubview:_star5];
    }else if (!CGRectEqualToRect(_star5.frame, frame)) {
        [_star5 setFrame:frame];
    }
    return _star5;
}

- (UILabel *)ratingSumLabel
{
    CGRect frame = CGRectMake(CGRectGetMaxX(self.star5.frame) + 6.f, (_viewBounds.height-self.imageHeight)/2, _viewBounds.width - (CGRectGetMaxX(self.star5.frame) + 2*6.f), self.imageHeight);
    if (!VALID_NOTEMPTY(_ratingSumLabel, UILabel)) {
        _ratingSumLabel = [[UILabel alloc] initWithFrame:frame];
        [_ratingSumLabel setTextColor:[UIColor darkGrayColor]];
        [_ratingSumLabel setFont:JACaptionFont];
        [_ratingSumLabel setText:@"(0)"];
        [_ratingSumLabel sizeToFit];
        [_ratingSumLabel setTextAlignment:NSTextAlignmentLeft];
        [_ratingSumLabel setY:self.height/2-_ratingSumLabel.height/2];
        [self addSubview:_ratingSumLabel];
    }else if (!CGRectEqualToRect(_ratingSumLabel.frame, frame)) {
        [_ratingSumLabel setFrame:frame];
        [_ratingSumLabel setTextAlignment:NSTextAlignmentLeft];
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
        [self.ratingSumLabel setText:STRING_BE_THE_FIRST_TO_RATE];
    }else
        [self.ratingSumLabel setText:[NSString stringWithFormat:@"(%@)", ratingSum]];
    [_ratingSumLabel sizeToFit];
    [self ratingSumLabel];
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    _viewBounds = frame.size;
    [self star1];
    [self star2];
    [self star3];
    [self star4];
    [self star5];
    [self ratingSumLabel];
}

- (void)setHiddenSum:(BOOL)hiddenSum
{
    [self.ratingSumLabel setHidden:hiddenSum];
}

@end
