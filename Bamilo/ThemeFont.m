//
//  ThemeFont.m
//  Bamilo
//
//  Created by Narbeh Mirzaei on 3/11/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "ThemeFont.h"

@implementation ThemeFont

+(instancetype)fontWithVariations:(NSDictionary *)variations {
    ThemeFont *themeFont = [ThemeFont new];
    themeFont.variations = variations;
    
    return themeFont;
}

@end
