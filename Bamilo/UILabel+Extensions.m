//
//  UILabel+Extensions.m
//  Bamilo
//
//  Created by Narbeh Mirzaei on 2/4/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "UILabel+Extensions.h"

@implementation UILabel (Extensions)

-(void)applyStyle:(NSString *)fontName fontSize:(CGFloat)fontSize color:(UIColor *)color {
    self.font = [UIFont fontWithName:fontName size:fontSize];
    self.textColor = color;
}

@end
