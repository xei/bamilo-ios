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

@synthesize label = _label;

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
    [self setEnabled:NO];
}

- (UILabel *)label
{
    if (!VALID_NOTEMPTY(_label, UILabel)) {
        _label = [[UILabel alloc] initWithFrame:CGRectMake(16, 6, self.width-32, self.height-12)];
        [_label setTextColor:JABlackColor];
        [_label setText:@""];
        [_label sizeToFit];
        [_label setY:self.height/2-_label.height/2];
        [self addSubview:_label];
    }
    return _label;
}

- (void)setLabel:(UILabel *)label
{
    _label = label;
    [_label sizeToFit];
    [_label setY:self.height/2-_label.height/2];
}

- (void)addTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents
{
    [self setEnabled:YES];
    [self.arrow setHidden:NO];
    [super addTarget:target action:action forControlEvents:controlEvents];
}

- (UIImageView *)arrow
{
    if (!VALID_NOTEMPTY(_arrow, UILabel)) {
        _arrow = [[UIImageView alloc] initWithFrame:CGRectMake(self.width - 16, 6, 8, 12)];
        [_arrow setImage:[UIImage imageNamed:@"arrow_moreinfo"]];
        [_arrow setHidden:YES];
        [_arrow setX:self.width - 16 - _arrow.width];
        [_arrow setY:self.height/2 - _arrow.height/2];
        [self addSubview:_arrow];
    }
    return _arrow;
}

- (void)setTitle:(NSString *)title
{
    [self.label setText:title];
    CGFloat labelWidth = self.width - 32;
    [self.label sizeToFit];
    [self.label setY:self.height/2-self.label.height/2];
    [self.label setWidth:labelWidth];
}

- (void)setTopSeparatorVisibility:(BOOL)topSeparatorVisibility
{
    _topSeparatorVisibility = topSeparatorVisibility;
    [self.topSeparator setHidden:!_topSeparatorVisibility];
}

- (void)setBottomSeparatorVisibility:(BOOL)bottomSeparatorVisibility
{
    _bottomSeparatorVisibility = bottomSeparatorVisibility;
    [self.bottomSeparator setHidden:!_bottomSeparatorVisibility];
}

- (void)setTopSeparatorWidth:(CGFloat)topSeparatorWidth
{
    _topSeparatorWidth = topSeparatorWidth;
    [self.topSeparator setHeight:_topSeparatorWidth];
}

- (void)setBottomSeparatorWidth:(CGFloat)bottomSeparatorWidth
{
    _bottomSeparatorWidth = bottomSeparatorWidth;
    [self.bottomSeparator setHeight:_bottomSeparatorWidth];
}

- (void)setBottomSeparatorColor:(UIColor *)bottomSeparatorColor
{
    _bottomSeparatorColor = bottomSeparatorColor;
    [self.bottomSeparator setBackgroundColor:_bottomSeparatorColor];
}

- (void)setTopSeparatorColor:(UIColor *)topSeparatorColor
{
    _topSeparatorColor = topSeparatorColor;
    [self.topSeparator setBackgroundColor:_topSeparatorColor];
}

- (UIView *)topSeparator
{
    if (!VALID_NOTEMPTY(_topSeparator, UIView)) {
        _topSeparator = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.width, 1)];
        [_topSeparator setBackgroundColor:JABlack400Color];
        [self addSubview:_topSeparator];
    }
    return _topSeparator;
}

- (UIView *)bottomSeparator
{
    if (!VALID_NOTEMPTY(_bottomSeparator, UIView)) {
        _bottomSeparator = [[UIView alloc] initWithFrame:CGRectMake(0, self.height-1, self.width, 1)];
        [_bottomSeparator setBackgroundColor:JABlack400Color];
        [self addSubview:_bottomSeparator];
    }
    return _bottomSeparator;
}

@end
