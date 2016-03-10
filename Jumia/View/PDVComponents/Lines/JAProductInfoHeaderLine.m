//
//  JAProductHeaderLine.m
//  Jumia
//
//  Created by josemota on 9/23/15.
//  Copyright (c) 2015 Rocket Internet. All rights reserved.
//

#import "JAProductInfoHeaderLine.h"

@interface JAProductInfoHeaderLine ()

@end

@implementation JAProductInfoHeaderLine

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setFrame:CGRectMake(0, 0, 320, kProductInfoHeaderLineHeight)];
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
    [self setBackgroundColor:JABlack300Color];
}

- (UILabel *)label
{
    [super.label setFont:JAHEADLINEFont];
    return super.label;
}

@end
