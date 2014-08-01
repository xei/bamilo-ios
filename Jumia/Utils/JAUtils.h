//
//  JAUtils.h
//  Jumia
//
//  Created by Pedro Lopes on 31/07/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JAUtils : NSObject

+ (UIViewController*) getCheckoutNextStepViewController:(NSString*)nextStep
                                           inStoryboard:(UIStoryboard*)storyboard;

@end
