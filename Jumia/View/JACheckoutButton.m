//
//  JACheckoutButton.m
//  Jumia
//
//  Created by Jose Mota on 28/04/16.
//  Copyright © 2016 Rocket Internet. All rights reserved.
//

#import "JACheckoutButton.h"

@interface JACheckoutButton ()

@property (nonatomic, strong) UIImageView *iconImageView;

@end

@implementation JACheckoutButton

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
    [self.titleLabel setFont:JABodyFont];
    [self setTitleColor:JABlackColor forState:UIControlStateNormal];
    [self setTitleColor:JABlack800Color forState:UIControlStateDisabled];
    [self.titleLabel setTextColor:JABlackColor];
    [self setTintColor:JABlackColor];
}

- (UIImageView *)iconImageView
{
    if (!VALID(_iconImageView, UIImageView)) {
        _iconImageView = [[UIImageView alloc] init];
        [self addSubview:_iconImageView];
    }
    return _iconImageView;
}

- (void)setImage:(UIImage *)image
{
    [self.iconImageView setImage:image];
    [self.iconImageView setWidth:image.size.width];
    [self.iconImageView setHeight:image.size.height];
    [self.iconImageView setXCenterAligned];
    [self.iconImageView setY:0.f];
}

- (void)setTag:(NSInteger)tag
{
    [super setTag:tag];
}

- (void)setEnabled:(BOOL)enabled
{
    [super setEnabled:enabled];
    if (self.iconImageView) {
        [UIView animateWithDuration:.2 animations:^{
            [self.iconImageView setAlpha:enabled?1.f:.5f];
        }];
    }
}

@end
