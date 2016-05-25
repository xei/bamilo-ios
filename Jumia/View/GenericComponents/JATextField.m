//
//  JATextField.m
//  Jumia
//
//  Created by Pedro Lopes on 03/09/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JATextField.h"

@interface JATextField ()

@property (nonatomic, strong) UIView *bottomLayer;

@end

@implementation JATextField

- (UIView *)bottomLayer
{
    if (!VALID(_bottomLayer, UIView)) {
        _bottomLayer = [[UIView alloc] initWithFrame:CGRectMake(0.f, self.height-1, self.width, 1.f)];
        [_bottomLayer setBackgroundColor:JABlack400Color];
        [self addSubview:_bottomLayer];
    }
    return _bottomLayer;
}

- (CGRect)textRectForBounds:(CGRect)bounds
{
    return CGRectMake(bounds.origin.x, bounds.origin.y - 3.0f,
                      bounds.size.width, bounds.size.height);
}

- (CGRect)editingRectForBounds:(CGRect)bounds
{
    return CGRectMake(bounds.origin.x, bounds.origin.y - 3.0f,
                      bounds.size.width, bounds.size.height);
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self.bottomLayer setWidth:self.width];
    [self.bottomLayer setYBottomAligned:1.f];
    [self setTextAlignment:RI_IS_RTL?NSTextAlignmentRight:NSTextAlignmentLeft];
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    [self setTextAlignment:RI_IS_RTL?NSTextAlignmentRight:NSTextAlignmentLeft];
}

@end
