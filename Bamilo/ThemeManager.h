//
//  ThemeManager.h
//  Bamilo
//
//  Created by Narbeh Mirzaei on 3/11/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ThemeKeys.h"
#import "ThemeFont.h"
#import "ThemeColor.h"

@interface ThemeManager : NSObject

+(instancetype) sharedInstance;

//FONTS
-(void) addThemeFont:(NSString *)key font:(ThemeFont *)font;
-(UIFont *)getFont:(NSString *)variation size:(CGFloat)size;
-(UIFont *)getFont:(NSString *)font variation:(NSString *)variation size:(CGFloat)size;


//COLORS
-(void) addThemeColor:(NSString *)key color:(ThemeColor *)color;
-(UIColor *)getColor:(NSString *)colorKey;
-(UIColor *)getColor:(NSString *)key colorKey:(NSString *)colorKey;

@end

@interface Theme : NSObject

+(UIColor *) color:(NSString *)colorKey;
+(UIFont *) font:(NSString *)fontVariation size:(CGFloat)size;

@end
