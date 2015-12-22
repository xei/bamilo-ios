//
//  JAProductInfoBaseLine.m
//  Jumia
//
//  Created by josemota on 9/23/15.
//  Copyright (c) 2015 Rocket Internet. All rights reserved.
//

#import "JAProductInfoBaseLine.h"

@interface JAProductInfoBaseLine ()

@property (nonatomic) UIImageView *arrow;
@property (nonatomic) UIView *topSeparator;
@property (nonatomic) UIView *bottomSeparator;

@end

@implementation JAProductInfoBaseLine

@synthesize label = _label, topSeparatorXOffset = _topSeparatorXOffset, bottomSeparatorXOffset = _bottomSeparatorXOffset;

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setDefauls];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setDefauls];
    }
    return self;
}

- (void)setDefauls
{
    self.lineContentXOffset = 16.f;
    [self setEnabled:NO];
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    [self label];
    [self arrow];
    [self topSeparator];
    [self bottomSeparator];
}

- (UILabel *)label
{
    CGRect frame = CGRectMake(self.lineContentXOffset, 6, self.width-32, self.height-12);
    if (!VALID_NOTEMPTY(_label, UILabel)) {
        _label = [[UILabel alloc] initWithFrame:frame];
        [_label setTextColor:JABlackColor];
        [_label setText:@""];
        [_label sizeToFit];
        [_label setY:self.height/2-_label.height/2];
        [self addSubview:_label];
    }else if (!CGRectEqualToRect(frame, _label.frame)) {
        [_label setFrame:frame];
        [_label sizeToFit];
        CGFloat labelWidth = self.width - 2*self.lineContentXOffset - (self.width - self.arrow.x);
        if (labelWidth < _label.width) {
            [_label setWidth:labelWidth];
        }
        [_label setYCenterAligned];
    }
    return _label;
}

- (void)setLabel:(UILabel *)label
{
    _label = label;
    [_label sizeToFit];
    [_label setY:self.height/2-_label.height/2];
}

- (void)setTag:(NSInteger)tag
{
    [super setTag:tag];
}

- (void)addTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents
{
    [self setEnabled:YES];
    [self.arrow setHidden:NO];
    [super addTarget:target action:action forControlEvents:controlEvents];
}

- (UIImageView *)arrow
{
    CGRect frame = CGRectMake(self.width - 16, self.height/2 - 6, 8, 12);
    if (!VALID_NOTEMPTY(_arrow, UIImageView)) {
        _arrow = [[UIImageView alloc] initWithFrame:frame];
        [_arrow setImage:[UIImage imageNamed:@"arrow_moreinfo"]];
        [_arrow setHidden:YES];
        [_arrow setX:self.width - 16 - _arrow.width];
        [_arrow setY:self.height/2 - _arrow.height/2];
        if (RI_IS_RTL) {
            [_arrow flipViewImage];
        }
        [self addSubview:_arrow];
    }else if(!CGRectEqualToRect(frame, _arrow.frame)) {
        [_arrow setFrame:frame];
    }
    return _arrow;
}

- (void)setTitle:(NSString *)title
{
    [self.label setText:title];
    CGFloat labelWidth = self.width - self.lineContentXOffset;
    [self.label sizeToFit];
    [self.label setWidth:labelWidth];
}

- (void)setTopSeparatorVisibility:(BOOL)topSeparatorVisibility
{
    _topSeparatorVisibility = topSeparatorVisibility;
    [self.topSeparator setHidden:!_topSeparatorVisibility];
}

- (void)setTopSeparatorBorderWidth:(CGFloat)topSeparatorWidth
{
    _topSeparatorBorderWidth = topSeparatorWidth;
    [self.topSeparator setHeight:_topSeparatorBorderWidth];
}

- (void)setTopSeparatorColor:(UIColor *)topSeparatorColor
{
    _topSeparatorColor = topSeparatorColor;
    [self.topSeparator setBackgroundColor:_topSeparatorColor];
}

- (void)setTopSeparatorXOffset:(CGFloat)topSeparatorXOffset
{
    _topSeparatorXOffset = topSeparatorXOffset;
    [self topSeparator];
}

- (void)setBottomSeparatorVisibility:(BOOL)bottomSeparatorVisibility
{
    _bottomSeparatorVisibility = bottomSeparatorVisibility;
    [self.bottomSeparator setHidden:!_bottomSeparatorVisibility];
}

- (void)setBottomSeparatorWidth:(CGFloat)bottomSeparatorBorderWidth
{
    _bottomSeparatorBorderWidth = bottomSeparatorBorderWidth;
    [self.bottomSeparator setHeight:_bottomSeparatorBorderWidth];
}

- (void)setBottomSeparatorColor:(UIColor *)bottomSeparatorColor
{
    _bottomSeparatorColor = bottomSeparatorColor;
    [self.bottomSeparator setBackgroundColor:_bottomSeparatorColor];
}

- (void)setBottomSeparatorXOffset:(CGFloat)bottomSeparatorXOffset
{
    _bottomSeparatorXOffset = bottomSeparatorXOffset;
    [self bottomSeparator];
}

- (UIView *)topSeparator
{
    CGRect frame = CGRectMake(_topSeparatorXOffset, 0, self.width - _topSeparatorXOffset, 1);
    if (!VALID_NOTEMPTY(_topSeparator, UIView)) {
        _topSeparator = [[UIView alloc] initWithFrame:frame];
        [_topSeparator setBackgroundColor:JABlack400Color];
        [_topSeparator setHidden:!self.topSeparatorVisibility];
        [self addSubview:_topSeparator];
    }else if (!CGRectEqualToRect(frame, _topSeparator.frame)) {
        [_topSeparator setFrame:frame];
    }
    return _topSeparator;
}

- (UIView *)bottomSeparator
{
    CGRect frame = CGRectMake(_bottomSeparatorXOffset, self.height-1, self.width - _bottomSeparatorXOffset, 1);
    if (!VALID_NOTEMPTY(_bottomSeparator, UIView)) {
        _bottomSeparator = [[UIView alloc] initWithFrame:frame];
        [_bottomSeparator setBackgroundColor:JABlack400Color];
        [_bottomSeparator setHidden:!self.bottomSeparatorVisibility];
        [self addSubview:_bottomSeparator];
    }else if (!CGRectEqualToRect(frame, _bottomSeparator.frame)) {
        [_bottomSeparator setFrame:frame];
    }
    return _bottomSeparator;
}

/*
 * to avoid confusions with label
 */
- (UILabel *)titleLabel
{
    return self.label;
}

@end
