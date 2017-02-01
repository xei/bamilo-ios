//
//  UIColor+Format.h
//  Jumia
//
//  Created by Ali saiedifar on 1/24/17.
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
+(UIColor *) withRGBA:(int)red green:(int)green blue:(int)blue alpha:(float)alpha;

@end
