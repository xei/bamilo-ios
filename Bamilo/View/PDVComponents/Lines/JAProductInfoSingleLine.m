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

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setDefaults];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setDefaults];
    }
    return self;
}

- (void)setDefaults {
    [self setTopSeparatorVisibility:YES];
    [self setTopSeparatorXOffset:self.label.x];
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
}

- (void)sizeToFit {
    [self setWidth:CGRectGetMaxX(self.label.frame)];
    [self setHeight:self.label.height];
    [self.label setYCenterAligned];
}

- (UILabel *)label {
    [super.label setFont:JAListFont];
    return super.label;
}

@end
