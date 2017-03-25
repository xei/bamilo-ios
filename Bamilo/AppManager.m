//
//  AppManager.m
//  Bamilo
//
//  Created by Narbeh Mirzaei on 1/28/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "AppManager.h"
#include <sys/types.h>
#include <sys/sysctl.h>

@implementation AppManager

static AppManager *instance;

+(instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[AppManager alloc] init];
    });
    
    return instance;
}

-(NSString *)getAppVersionNumber {
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
}

-(NSString *)getAppBuildNumber {
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
}

-(NSString *)getAppFullFormattedVersion {
    return [NSString stringWithFormat:@"%@ (%@)", [self getAppVersionNumber], [self getAppBuildNumber]];
}

-(NSString *)getDeviceModel {
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

@end
