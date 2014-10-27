//
//  JAUtils.h
//  Jumia
//
//  Created by Pedro Lopes on 31/07/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RICheckout.h"

@interface JAUtils : NSObject

+ (void) goToCheckout:(RICheckout*)checkout
         inStoryboard:(UIStoryboard*)storyboard;

+ (unsigned int)intFromHexString:(NSString *) hexStr;

+ (NSString *)getDeviceModel;

+ (UIImage *)imageWithColor:(UIColor *)color;

@end
