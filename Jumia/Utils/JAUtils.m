//
//  JAUtils.m
//  Jumia
//
//  Created by Pedro Lopes on 31/07/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JAUtils.h"

@implementation JAUtils

+ (UIViewController*) getCheckoutNextStepViewController:(NSString*)nextStep
                                           inStoryboard:(UIStoryboard*)storyboard
{
    UIViewController *nextStepViewController = nil;
    
    if([@"createAddress" isEqualToString:nextStep])
    {
    }
    else if([@"billing" isEqualToString:nextStep])
    {
        nextStepViewController = [storyboard instantiateViewControllerWithIdentifier:@"billingViewController"];
    }
    else if([@"shippingMethod" isEqualToString:nextStep])
    {
        nextStepViewController = [storyboard instantiateViewControllerWithIdentifier:@"shippingViewController"];
    }
    else if([@"paymentMethod" isEqualToString:nextStep])
    {
        nextStepViewController = [storyboard instantiateViewControllerWithIdentifier:@"paymentViewController"];
    }
    else if([@"finish" isEqualToString:nextStep])
    {
    }
    
    return nextStepViewController;
}

+ (unsigned int)intFromHexString:(NSString *) hexStr
{
    unsigned int hexInt = 0;
    
    // Create scanner
    NSScanner *scanner = [NSScanner scannerWithString:hexStr];
    
    // Tell scanner to skip the # character
    [scanner setCharactersToBeSkipped:[NSCharacterSet characterSetWithCharactersInString:@"#"]];
    
    // Scan hex value
    [scanner scanHexInt:&hexInt];
    
    return hexInt;
}

@end
