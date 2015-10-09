//
//  JAUtils.h
//  Jumia
//
//  Created by Pedro Lopes on 31/07/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RICart.h"

@interface JAUtils : NSObject

+ (void) goToNextStep:(NSString*)nextStep
             userInfo:(NSDictionary*)userInfo;

+ (unsigned int)intFromHexString:(NSString *) hexStr;

+ (NSString *)getDeviceModel;

+ (UIImage *)imageWithColor:(UIColor *)color;

@end
