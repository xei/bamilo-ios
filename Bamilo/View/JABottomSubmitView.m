//
//  JABottomSubmitView.m
//  Jumia
//
//  Created by Jose Mota on 13/05/16.
//  Copyright © 2016 Rocket Internet. All rights reserved.
//

#import "JABottomSubmitView.h"

#define kLateralMargin 16.f
#define kVerticalMargin 16.f

@interface JABottomSubmitView ()

@property (nonatomic, strong) UIView *separator;

@end

@implementation JABottomSubmitView

- (UIView *)separator
{
    if (!VALID(_separator, UIView)) {
        _separator = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.width, 1)];
        [_separator setBackgroundColor:JABlack400Color];
        [self addSubview:_separator];
    }
    return _separator;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (!VALID([self.button superview], UIView))
    {
        [self setBackgroundColor:JAWhiteColor];
        [self addSubview:self.button];
    }
    
    [self.separator setFrame:CGRectMake(0, 0, self.width, 1)];
    [self.button setFrame:CGRectMake(kLateralMargin, 0, self.width - 2*kLateralMargin, kBottomDefaultHeight)];
    [self.button setYCenterAligned];
}

+ (CGFloat)defaultHeight
{
    return kBottomDefaultHeight + 2*kVerticalMargin;
}

@end
