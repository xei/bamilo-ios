//
//  JAUtils.m
//  Jumia
//
//  Created by Pedro Lopes on 31/07/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JAUtils.h"
#include <sys/types.h>
#include <sys/sysctl.h>

@implementation JAUtils

+ (void) goToNextStep:(NSString*)nextStep
             userInfo:(NSDictionary*)userInfo
{
    if([@"createAddress" isEqualToString:nextStep])
    {
        NSDictionary *userInfo = [NSDictionary dictionaryWithObjects:@[[NSNumber numberWithBool:YES], [NSNumber numberWithBool:YES], [NSNumber numberWithBool:NO], [NSNumber numberWithBool:YES]] forKeys:@[@"is_billing_address", @"is_shipping_address", @"show_back_button", @"from_checkout"]];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kShowCheckoutAddAddressScreenNotification
                                                            object:nil
                                                          userInfo:userInfo];
    }
    else if([@"addresses" isEqualToString:nextStep])
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:kShowCheckoutAddressesScreenNotification
                                                            object:@{@"animated":[NSNumber numberWithBool:YES]}
                                                          userInfo:@{@"from_checkout":[NSNumber numberWithBool:YES]}];
    }
    else if([@"shippingMethod" isEqualToString:nextStep])
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:kShowCheckoutShippingScreenNotification
                                                            object:nil
                                                          userInfo:nil]; //this screen loads the cart itself
    }
    else if([@"paymentMethod" isEqualToString:nextStep])
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:kShowCheckoutPaymentScreenNotification
                                                            object:nil
                                                          userInfo:nil]; //this screen loads the cart itself
    }
    else if([@"finish" isEqualToString:nextStep])
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:kShowCheckoutFinishScreenNotification
                                                            object:nil
                                                          userInfo:userInfo];
    }
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

+ (NSString *)getDeviceModel
{
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    
    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    
    NSString *platform = [NSString stringWithCString:machine encoding:NSUTF8StringEncoding];
    platform = [JAUtils platformType:platform];
    
    free(machine);
    
    return platform;
}

+ (NSString *) platformType:(NSString *)platform
{
    if ([platform isEqualToString:@"i386"]) {
        return @"Simulator";
    }
    if ([platform isEqualToString:@"x86_64"]) {
        return @"Simulator";
    }
    
    return platform;
}

+ (UIImage *)imageWithColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0, 0, 1, 1);
    // Create a 1 by 1 pixel context
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
    [color setFill];
    UIRectFill(rect);   // Fill it with your color
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end
