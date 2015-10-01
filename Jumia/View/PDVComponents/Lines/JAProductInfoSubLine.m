//
//  JAProductInfoSingleLine.m
//  Jumia
//
//  Created by josemota on 9/23/15.
//  Copyright (c) 2015 Rocket Internet. All rights reserved.
//

#import "JAProductInfoSubLine.h"

@interface JAProductInfoSubLine ()

@property (nonatomic) UIView *bottomSeparator;

@end

@implementation JAProductInfoSubLine

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

- (UIView *)bottomSeparator
{
    if (!VALID_NOTEMPTY(_bottomSeparator, UIView)) {
        _bottomSeparator = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.width, .5)];
        [_bottomSeparator setYBottomAligned:0];
        [_bottomSeparator setBackgroundColor:JABlack400Color];
        [self addSubview:_bottomSeparator];
    }
    return _bottomSeparator;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    [self.bottomSeparator setYBottomAligned:0];
}

- (UILabel *)label
{
    [super.label setFont:JACaptionFont];
    return super.label;
}

@end
