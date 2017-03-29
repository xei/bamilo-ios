//
//  DeviceManager.m
//  Bamilo
//
//  Created by Narbeh Mirzaei on 3/29/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "DeviceManager.h"
#include <sys/types.h>
#include <sys/sysctl.h>

@implementation DeviceManager

+(NSString *)getDeviceModel {
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    
    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    
    NSString *platform = [NSString stringWithCString:machine encoding:NSUTF8StringEncoding];
    if([platform isEqualToString:@"i386"] || [platform isEqualToString:@"x86_64"]) {
        platform = @"Simulator";
    }
    
    free(machine);
    
    return platform;
}

+(NSOperatingSystemVersion)getOSVersion {
    return [[NSProcessInfo processInfo] operatingSystemVersion];
}

+(NSString *)getOSVersionFormatted {
    NSOperatingSystemVersion osVersion = [DeviceManager getOSVersion];
    NSMutableString *osVersionFormatted = [NSMutableString stringWithFormat:@"%ld.%ld", osVersion.majorVersion, osVersion.minorVersion];
    if(osVersion.patchVersion) {
        [osVersionFormatted appendFormat:@".%ld", osVersion.patchVersion];
    }
    
    return osVersionFormatted;
}

+(NSString *)getLocalTimeZoneRFC822Formatted {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"Z"];
    
    return [dateFormatter stringFromDate:[NSDate date]];
}

@end
