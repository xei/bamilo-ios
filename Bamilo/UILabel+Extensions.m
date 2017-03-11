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
    [self applyStyle:[UIFont fontWithName:fontName size:fontSize] color:color];
}

-(void)applyStyle:(UIFont *)font color:(UIColor *)color {
    self.font = font;
    self.textColor = color;
}

- (CGSize)sizeForLabel {
    CGRect labelRect = [self.text boundingRectWithSize:self.size options:NSStringDrawingUsesLineFragmentOrigin attributes:@{ NSFontAttributeName : self.font } context:nil];
    
    return labelRect.size;
}

@end
