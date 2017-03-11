//
//  ThemeManager.m
//  Bamilo
//
//  Created by Narbeh Mirzaei on 3/11/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "ThemeManager.h"

@implementation ThemeManager {
@private
    NSMutableDictionary *_fonts;
    NSMutableDictionary *_colors;
}

- (instancetype)init {
    if (self = [super init]) {
        _fonts = [NSMutableDictionary new];
        _colors = [NSMutableDictionary new];
    }
    return self;
}

static ThemeManager *instance;

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[ThemeManager alloc] init];
    });
    
    return instance;
}

//FONTS
-(void) addThemeFont:(NSString *)key font:(ThemeFont *)font {
    [_fonts setObject:font forKey:key];
}

-(UIFont *)getFont:(NSString *)variation size:(CGFloat)size {
    return [self getFont:cPrimaryFont variation:variation size:size];
}

-(UIFont *)getFont:(NSString *)font variation:(NSString *)variation size:(CGFloat)size {
    if(variation.length) {
        ThemeFont *themeFont = [_fonts objectForKey:variation];
        return [UIFont fontWithName:[NSString stringWithFormat:@"%@-%@", font, [themeFont.variations objectForKey:variation]] size:size];
    } else {
        return [UIFont fontWithName:font size:size];
    }
}

//COLORS
-(void) addThemeColor:(NSString *)key color:(ThemeColor *)color {
    [_colors setObject:color forKey:key];
}

-(UIColor *)getColor:(NSString *)colorKey {
    return [self getColor:cPrimaryPalette colorKey:colorKey];
}

-(UIColor *)getColor:(NSString *)key colorKey:(NSString *)colorKey {
    ThemeColor *themeColor = [_colors objectForKey:key];
    if(themeColor) {
        return [themeColor.palette objectForKey:colorKey];
    } else {
        return nil;
    }
}

@end
