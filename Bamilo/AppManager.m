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

-(void)addAltAppIcon:(NSString *)icon expires:(NSDate *)expires {
    [UserDefaultsManager remove:kUDMAltIcons]; //remove all the rests
    if (VALID_NOTEMPTY(expires, NSData)) {
        [UserDefaultsManager set:kUDMAltIcons value:@[@{ @"icon": icon, @"expires": expires }]];
    }
}

-(void)updateScheduledAppIcons {
    NSMutableArray *altIcons = [NSMutableArray arrayWithArray:[UserDefaultsManager get:kUDMAltIcons]];
    if(altIcons.count) {
        NSMutableArray *discardedItems = [NSMutableArray new];
        for(NSDictionary *altIcon in altIcons) {
            if (VALID_NOTEMPTY([altIcon objectForKey:@"expires"], NSDate)) {
                NSDate *altIconExpiryDate = [altIcon objectForKey:@"expires"];
                if([[NSDate date] compare:altIconExpiryDate] == NSOrderedDescending) {
                    [discardedItems addObject:altIcon];
                }
            }
        }
        
        [altIcons removeObjectsInArray:discardedItems];
        [UserDefaultsManager set:kUDMAltIcons value:altIcons];
    } else if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"10.3") && [UIApplication sharedApplication].alternateIconName) {
        //There is no alt icons stored but icon is changed to alt. WTF! If we leave it like this, alt icon is not going to change back. Force reset to default
        [self resetAppIconToDefault];
    }
}
    
-(void)executeScheduledAppIcons {
    NSMutableArray *altIcons = [NSMutableArray arrayWithArray:[UserDefaultsManager get:kUDMAltIcons]];
    if(altIcons.count) {
        NSString *icon = [[altIcons lastObject] objectForKey:@"icon"];
        if(![[UserDefaultsManager get:kUDMAlternativeIcon] isEqualToString:icon]) {
            [UserDefaultsManager set:kUDMAlternativeIcon value:icon];
            [self updateAppIcon:icon];
        }
    } else {
        [self resetAppIconToDefault];
    }
}
    
-(void)resetAppIconToDefault {
    if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"10.3") && [UIApplication sharedApplication].alternateIconName) {
        [UserDefaultsManager remove:kUDMAltIcons];
        [UserDefaultsManager remove:kUDMAlternativeIcon];
        [self updateAppIcon:nil];
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
