//
//  UIView+Extensions.m
//  Bamilo
//
//  Created by Narbeh Mirzaei on 2/6/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "UIView+Extensions.h"

@implementation UIView (Extensions)

@dynamic cornerRadius, borderColor, borderWidth, shadowColor, shadowOffset, shadowRadius, shadowOpacity;

- (void)setCornerRadius:(CGFloat)cornerRadius {
    self.layer.cornerRadius = cornerRadius;
    self.layer.masksToBounds = cornerRadius > 0;
}

- (void)setBorderColor:(UIColor *)borderColor {
    self.layer.borderColor = borderColor.CGColor;
}

- (void)setBorderWidth:(CGFloat)borderWidth {
    self.layer.borderWidth = borderWidth;
}

- (void)setShadowColor:(UIColor *)shadowColor {
    [self.layer setShadowColor: shadowColor.CGColor];
}

- (void)setShadowOffset:(CGSize)shadowOffset {
    [self.layer setShadowOffset: shadowOffset];
}

- (void)setShadowRadius:(CGFloat)shadowRadius {
    [self.layer setShadowRadius: shadowRadius];
}

- (void)setShadowOpacity:(CGFloat)shadowOpacity {
    [self.layer setShadowOpacity:shadowOpacity];
}

-(void)anchorMatch:(UIView *)view {
    NSDictionary *views = NSDictionaryOfVariableBindings(view);
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[view]|" options:0 metrics:nil views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view]|"options:0 metrics:nil views:views]];
}

@end
