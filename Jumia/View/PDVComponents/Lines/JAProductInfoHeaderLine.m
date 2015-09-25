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
        [self setFrame:CGRectMake(0, 0, 320, 80)];
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
    [self setBackgroundColor:UIColorFromRGB(0xf0f0f0)];
    UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.width, .5)];
    [separator setBackgroundColor:[UIColor grayColor]];
    [self addSubview:separator];
}

- (UILabel *)label
{
    [super.label setFont:JAList1Font];
    return super.label;
}

@end
