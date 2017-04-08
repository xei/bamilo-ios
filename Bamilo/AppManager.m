//
//  AppManager.m
//  Bamilo
//
//  Created by Narbeh Mirzaei on 1/28/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "AppManager.h"

@implementation AppManager

static AppManager *instance;

+(instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [AppManager new];
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

@end
