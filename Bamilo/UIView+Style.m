//
//  UIView+Style.m
//  Jumia
//
//  Created by Ali saiedifar on 1/23/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "UIView+Style.h"

@implementation UIView (Style)
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
    [self.layer setShadowColor:[[UIColor blackColor] CGColor]];
}

- (void)setShadowOffset:(CGSize)shadowOffset {
    [self.layer setShadowOffset:CGSizeMake(-4.0, 4.0)];
}

- (void)setShadowRadius:(CGFloat)shadowRadius {
    [self.layer setShadowRadius:4.75];
}

- (void)setShadowOpacity:(CGFloat)shadowOpacity {
    [self.layer setShadowOpacity:0.4];
}
@end
