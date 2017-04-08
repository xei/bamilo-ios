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
        platform = @"simulator";
    }
    
    free(machine);
    
    return platform;
}

+(NSOperatingSystemVersion)getOSVersion {
    return [[NSProcessInfo processInfo] operatingSystemVersion];
}

+(NSString *)getOSVersionFormatted {
    NSOperatingSystemVersion osVersion = [DeviceManager getOSVersion];
    NSMutableString *osVersionFormatted = [NSMutableString stringWithFormat:@"%d.%d", (int)osVersion.majorVersion, (int)osVersion.minorVersion];
    if(osVersion.patchVersion) {
        [osVersionFormatted appendFormat:@".%d", (int)osVersion.patchVersion];
    }
    
    return osVersionFormatted;
}

+(NSString *)getLocalTimeZoneRFC822Formatted {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"Z"];
    
    return [dateFormatter stringFromDate:[NSDate date]];
}

+(NSString *)getConnectionType {
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    
    [reachability startNotifier];
    NetworkStatus status = [reachability currentReachabilityStatus];
    [reachability stopNotifier];
    
    if(status == NotReachable) {
        return @"no internet";
    } else if (status == ReachableViaWiFi) {
        return @"wifi";
    } else if (status == ReachableViaWWAN) {
        return @"cellular";
    } else {
        return @"unknown";
    }
}

@end
