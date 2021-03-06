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

- (void)anchorMatch:(UIView *)view {
    NSDictionary *views = NSDictionaryOfVariableBindings(view);
    self.frame = view.frame;
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[view]|" options:0 metrics:nil views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view]|"options:0 metrics:nil views:views]];
}

- (CGSize)sizeToFitSubviews {
    float width = 0, height = 0;
    
    for (UIView *view in self.subviews) {
        float fw = view.frame.origin.x + view.frame.size.width;
        float fh = view.frame.origin.y + view.frame.size.height;
        width = MAX(fw, width);
        height = MAX(fh, height);
    }
    
    [self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, width, height)];
    
    return CGSizeMake(width, height);
}

- (void)hide {
    [self setHidden:YES];
    [self setAlpha:0];
}

- (void)fadeIn:(NSTimeInterval) duration {
    [self setHidden:NO];
    [UIView animateWithDuration:duration animations:^{
        [self setAlpha:1];
    }];
}

- (void)fadeOut:(NSTimeInterval) duration {
    [UIView animateWithDuration:duration animations:^{
        [self setAlpha:0];
    } completion:^(BOOL finished) {
        [self setHidden:YES];
    }];
}

@end
