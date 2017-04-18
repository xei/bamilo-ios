//
//  AppManager.m
//  Bamilo
//
//  Created by Narbeh Mirzaei on 1/28/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "AppManager.h"

@interface AppManager()

@property (assign, nonatomic) OpenAppEventSourceType openAppEventSource;

@end

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

-(OpenAppEventSourceType)updateOpenAppEventSource:(OpenAppEventSourceType)source {
    return self.openAppEventSource = source;
}

-(OpenAppEventSourceType)getOpenAppEventSource {
    return self.openAppEventSource;
}

-(void)setAppIcon:(NSString *)icon expires:(NSDate *)expires {
    [UserDefaultsManager set:kUDMAltIconExpiryDate value:expires];
    [self updateAppIcon:icon];
}

-(void)resetAppIconToDefault {
    if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"10.3") && [UIApplication sharedApplication].alternateIconName) {
        [UserDefaultsManager remove:kUDMAltIconExpiryDate];
        [self updateAppIcon:nil];
    }
}

-(void)executeScheduledAppIconUpdates {
    NSDate *altIconExpiryDate = [UserDefaultsManager get:kUDMAltIconExpiryDate];
    if(altIconExpiryDate && [[NSDate date] compare:altIconExpiryDate] == NSOrderedDescending) {
        [self resetAppIconToDefault];
    }
}

#pragma mark - Helpers
-(void) updateAppIcon:(NSString *)icon {
    if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"10.3")) {
        if([UIApplication sharedApplication].supportsAlternateIcons) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [[UIApplication sharedApplication] setAlternateIconName:icon completionHandler:^(NSError * _Nullable error) {
                    if(error) {
                        NSLog(@"AppManager > updateAppIcon > FAILED > %@", error.localizedDescription);
                    }
                }];
            });
        }
    }
}

@end
