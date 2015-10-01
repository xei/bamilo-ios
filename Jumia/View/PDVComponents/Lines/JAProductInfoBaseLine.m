//
//  JAProductInfoBaseLine.m
//  Jumia
//
//  Created by josemota on 9/23/15.
//  Copyright (c) 2015 Rocket Internet. All rights reserved.
//

#import "JAProductInfoBaseLine.h"

@interface JAProductInfoBaseLine ()

@property (nonatomic) UILabel *arrow;
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
        _label = [[UILabel alloc] initWithFrame:CGRectMake(16, 6, self.width-12, self.height-12)];
        [_label setTextColor:JABlackColor];
        [_label setText:@"set your text here."];
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
    [self.arrow setEnabled:YES];
    [super addTarget:target action:action forControlEvents:controlEvents];
}

- (UILabel *)arrow
{
    if (!VALID_NOTEMPTY(_arrow, UILabel)) {
        _arrow = [[UILabel alloc] initWithFrame:CGRectMake(self.width - 16, 6, 10, self.height-12)];
        [_arrow setTextColor:JABlack400Color];
        [_arrow setText:@">"];
        [_arrow sizeToFit];
        [_arrow setX:self.width - 16 - _arrow.width];
        [_arrow setY:self.height/2 - _arrow.height/2];
        [self addSubview:_arrow];
    }
    return _arrow;
}

- (void)setTitle:(NSString *)title
{
    [_label setText:title];
    [_label sizeToFit];
    [_label setY:self.height/2-_label.height/2];
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
