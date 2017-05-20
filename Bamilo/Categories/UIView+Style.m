//
//  UIView+Style.m
//  Jumia
//
//  Created by Ali Saeedifar on 1/23/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "UIView+Style.h"

@implementation UIView (Style)
@dynamic cornerRadius, borderColor, borderWidth;

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
@end
