//
//  JAButton.m
//  Jumia
//
//  Created by Jose Mota on 11/03/16.
//  Copyright © 2016 Rocket Internet. All rights reserved.
//

#import "JAButton.h"
#import "UIImage+WithColor.h"
#import "NSString+Size.h"

@interface JAButton ()

@property (nonatomic, strong) UIColor *enabledColor;
@property (nonatomic, strong) UIColor *disabledColor;

@end

@implementation JAButton

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (instancetype)initButtonWithTitle:(NSString *)title
{
    self = [super init];
    if (self) {
        [self setBackgroundColor:JAOrange1Color];
        [self setEnabledColor:JAOrange1Color];
        [self setDisabledColor:JABlack700Color];
        [self setTintColor:JAWhiteColor];
        [self setTitleColor:JAWhiteColor forState:UIControlStateNormal];
        [self setTitle:[title uppercaseString] forState:UIControlStateNormal];
        [self.titleLabel setFont:JABUTTONFont];
    }
    return self;
}

- (instancetype)initAlternativeButtonWithTitle:(NSString *)title
{
    self = [[JAButton alloc] initButtonWithTitle:title];
    if (self) {
        [self setBackgroundColor:JAWhiteColor];
        [self setTitleColor:JABlack800Color forState:UIControlStateNormal];
        [self.layer setBorderColor:JABlack400Color.CGColor];
        [self.layer setBorderWidth:1.f];
    }
    return self;
}

- (instancetype)initAlternativeButtonWithTitle:(NSString *)title target:(id)target action:(SEL)action
{
    self = [[JAButton alloc] initButtonWithTitle:title];
    if (self) {
        [self setBackgroundColor:JAWhiteColor];
        [self setTitleColor:JABlack800Color forState:UIControlStateNormal];
        [self.layer setBorderColor:JABlack400Color.CGColor];
        [self.layer setBorderWidth:1.f];
        [self addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (instancetype)initButtonWithTitle:(NSString *)title target:(id)target action:(SEL)action
{
    self = [[JAButton alloc] initButtonWithTitle:title];
    if (self) {
        [self setBackgroundColor:JAOrange1Color];
        [self setEnabledColor:JAOrange1Color];
        [self setDisabledColor:JABlack700Color];
        [self setTintColor:JAWhiteColor];
        [self setTitleColor:JAWhiteColor forState:UIControlStateNormal];
        [self addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (instancetype)initSmallButtonWithImage:(UIImage *)image target:(id)target action:(SEL)action
{
    self = [super init];
    if (self) {
        [[self imageView] setContentMode:UIViewContentModeCenter];
        [self setImage:image forState:UIControlStateNormal];
        [self setBackgroundColor:JABlack900Color];
        [self setTitleColor:JAWhiteColor forState:UIControlStateNormal];
        [self addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (instancetype)initFacebookButtonWithTitle:(NSString *)title target:(id)target action:(SEL)action
{
    self = [super init];
    if (self) {
        [self setTitle:title forState:UIControlStateNormal];
        [self.titleLabel setFont:JABodyFont];
        [self setBackgroundColor:[UIColor clearColor]];
        [self setTitleColor:JABlue1Color forState:UIControlStateNormal];
        [self addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
        [self setImage:[UIImage imageNamed:@"facebook_icon"] forState:UIControlStateNormal];
    }
    return self;
}

- (void)setEnabled:(BOOL)enabled
{
    [super setEnabled:enabled];
    if (enabled && VALID(self.enabledColor, UIColor)) {
        [self setBackgroundColor:self.enabledColor];
    } else if (!enabled && VALID(self.disabledColor, UIColor)) {
        [self setBackgroundColor:self.disabledColor];
    }
}

- (CGSize)sizeWithMaxWidth:(CGFloat)width
{
    return [self.titleLabel.text sizeForFont:self.titleLabel.font withMaxWidth:width];
}

@end
