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
    [self setTopSeparatorVisibility:YES];
    [self setTopSeparatorXOffset:self.label.x];
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    [self setBottomSeparatorVisibility:YES];
}

- (UILabel *)label
{
    [super.label setFont:JACaptionFont];
    return super.label;
}

- (void)sizeToFit
{
    [super sizeToFit];
    [self.label setWidth:self.width - 2*self.lineContentXOffset];
    [self.label sizeToFit];
    [self setWidth:CGRectGetMaxX(self.label.frame)];
    [self setHeight:self.label.height];
    [self.label setYCenterAligned];
}

@end
