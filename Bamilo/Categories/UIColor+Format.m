//
//  UIColor+Format.m
//  Jumia
//
//  Created by Ali saiedifar on 1/24/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "UIColor+Format.h"

@implementation UIColor (Format)

+(UIColor *) withHexString:(NSString *)hexString {
    unsigned rgbValue = 0;
    if([hexString hasPrefix:@"#"]) {
        hexString = [hexString substringFromIndex:1];
    }
    
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:0];
    [scanner scanHexInt:&rgbValue];
    
    return [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0x00FF00) >> 8))/255.0 blue:((float)((rgbValue & 0x0000FF) >>  0))/255.0 alpha:1.0];
}

+(UIColor *)withRepeatingRGBA:(int)rgb alpha:(float)alpha {
    return [UIColor withRGBA:rgb green:rgb blue:rgb alpha:alpha];
}

+(UIColor *) withRGBA:(int)red green:(int)green blue:(int)blue alpha:(float)alpha {
    return [UIColor colorWithRed:red/255.0f green:green/255.0f blue:blue/255.0f alpha:alpha];
}

@end
