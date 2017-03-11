//
//  ThemeColor.m
//  Bamilo
//
//  Created by Narbeh Mirzaei on 3/11/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "ThemeColor.h"

@implementation ThemeColor

+(instancetype) colorWithPalette:(NSDictionary *)palette {
    ThemeColor *themeColor = [ThemeColor new];
    themeColor.palette = palette;
    
    return themeColor;
}

@end
