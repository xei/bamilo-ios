//
//  JAButton.m
//  Jumia
//
//  Created by Jose Mota on 11/03/16.
//  Copyright © 2016 Rocket Internet. All rights reserved.
//

#import "JAButton.h"
#import "UIImage+WithColor.h"

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
        [self setTitle:[title uppercaseString] forState:UIControlStateNormal];
        [self.titleLabel setFont:JABUTTONFont];
    }
    return self;
}

- (instancetype)initAlternativeButtonWithTitle:(NSString *)title target:(id)target action:(SEL)action
{
    self = [[JAButton alloc] initButtonWithTitle:title];
    if (self) {
        [self setBackgroundColor:JAWhiteColor];
        [self setTintColor:JABlack800Color];
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
        [self setTintColor:JAWhiteColor];
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
        [self setTintColor:[UIColor whiteColor]];
        [self addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (instancetype)initFacebookButtonWithTitle:(NSString *)title target:(id)target action:(SEL)action
{
    self = [[JAButton alloc] initButtonWithTitle:title];
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
        [self setTitleColor:JAWhiteColor forState:UIControlStateNormal];
        [self addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
        [self setBackgroundImage:[UIImage imageNamed:@"facebookMedium_normal"]];
    }
    return self;
}

@end
