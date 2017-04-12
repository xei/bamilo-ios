//
//  UITextField+Extensions.m
//  Bamilo
//
//  Created by Ali Saeedifar on 3/11/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "UITextField+Extensions.h"

@implementation UITextField (Extensions)

- (void)applyStyle:(UIFont *)font color:(UIColor *)color {
    self.font = font;
    self.textColor = color;
}

@end
