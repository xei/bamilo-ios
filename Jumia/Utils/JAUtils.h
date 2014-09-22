//
//  JAUtils.h
//  Jumia
//
//  Created by Pedro Lopes on 31/07/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JAUtils : NSObject

+ (void) goToCheckoutNextStep:(NSString*)nextStep
                 inStoryboard:(UIStoryboard*)storyboard;

+ (unsigned int)intFromHexString:(NSString *) hexStr;

+ (NSString *)getDeviceModel;

@end
