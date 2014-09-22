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

+ (void) goToCheckoutNextStep:(NSString*)nextStep
                 inStoryboard:(UIStoryboard*)storyboard
{
    if([@"createAddress" isEqualToString:nextStep])
    {
    }
    else if([@"billing" isEqualToString:nextStep])
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:kShowCheckoutAddressesScreenNotification
                                                            object:nil
                                                          userInfo:nil];
    }
    else if([@"shippingMethod" isEqualToString:nextStep])
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:kShowCheckoutShippingScreenNotification
                                                            object:nil
                                                          userInfo:nil];
    }
    else if([@"paymentMethod" isEqualToString:nextStep])
    {        
        [[NSNotificationCenter defaultCenter] postNotificationName:kShowCheckoutPaymentScreenNotification
                                                            object:nil
                                                          userInfo:nil];
    }
    else if([@"finish" isEqualToString:nextStep])
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:kShowCheckoutFinishScreenNotification
                                                            object:nil
                                                          userInfo:nil];
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

@end
