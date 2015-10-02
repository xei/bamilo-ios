//
//  JAProductInfoSingleLine.m
//  Jumia
//
//  Created by josemota on 9/23/15.
//  Copyright (c) 2015 Rocket Internet. All rights reserved.
//

#import "JAProductInfoSingleLine.h"

@interface JAProductInfoSingleLine ()

@end

@implementation JAProductInfoSingleLine

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

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    [self setBottomSeparatorVisibility:YES];
    [self setBottomSeparatorColor:JABlack400Color];
}

- (UILabel *)label
{
    [super.label setFont:JAList2Font];
    return super.label;
}

@end
