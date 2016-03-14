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

- (instancetype)initButtonWithTitle:(NSString *)title
{
    self = (JAButton *)[JAButton buttonWithType:UIButtonTypeRoundedRect];
    if (self) {
        [self setTitle:[title uppercaseString] forState:UIControlStateNormal];
        [self.titleLabel setFont:JABUTTONFont];
        [self setBackgroundImage:[UIImage imageWithColor:JAOrange1Color] forState:UIControlStateNormal];
        [self setBackgroundImage:[UIImage imageWithColor:JABlack700Color] forState:UIControlStateDisabled];
        [self setBackgroundColor:JAOrange2Color];
        [self setTintColor:JAWhiteColor];
    }
    return self;
}

- (instancetype)initButtonWithTitle:(NSString *)title target:(id)target action:(SEL)action
{
    self = [[JAButton alloc] initButtonWithTitle:title];
    if (self) {
        [self addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

@end
