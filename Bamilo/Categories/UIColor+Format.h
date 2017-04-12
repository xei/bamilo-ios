//
//  UIColor+Format.h
//  Jumia
//
//  Created by Ali Saeedifar on 1/24/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (Format)

/**
 *  @desc   : convert the hexString to UIColor object
 *  @input  : {String} hex string of target color e.g. #FFFFFF or FFFFFF
 *  @output : {UIColor}
 */

+(UIColor *) withHexString:(NSString *)hexString;
+(UIColor *) withRepeatingRGBA:(int)rgb alpha:(float)alpha; //#E6E6E6 -> E6
+(UIColor *) withRGBA:(int)red green:(int)green blue:(int)blue alpha:(float)alpha;

@end
