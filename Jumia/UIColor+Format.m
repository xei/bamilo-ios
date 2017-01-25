//
//  UIColor+Format.m
//  Jumia
//
//  Created by Ali saiedifar on 1/24/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "UIColor+Format.h"

@implementation UIColor (Format)

+ (UIColor *) withHexString:(NSString *)hexString {
    unsigned rgbValue = 0;
    if([hexString hasPrefix:@"#"]) {
        hexString = [hexString substringFromIndex:1];
    }
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:0];
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

@end
