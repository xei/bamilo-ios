//
//  JAButton.h
//  Jumia
//
//  Created by Jose Mota on 11/03/16.
//  Copyright © 2016 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JAClickableView.h"

#define kBottomDefaultHeight 48

@interface JAButton : JAClickableView

- (instancetype)initButtonWithTitle:(NSString *)title;
- (instancetype)initButtonWithTitle:(NSString *)title target:(id)target action:(SEL)action;
- (instancetype)initAlternativeButtonWithTitle:(NSString *)title;
- (instancetype)initAlternativeButtonWithTitle:(NSString *)title target:(id)target action:(SEL)action;
- (instancetype)initSmallButtonWithImage:(UIImage *)image target:(id)target action:(SEL)action;
//- (instancetype)initFacebookButtonWithTitle:(NSString *)title target:(id)target action:(SEL)action;

- (CGSize)sizeWithMaxWidth:(CGFloat)width;

@end
