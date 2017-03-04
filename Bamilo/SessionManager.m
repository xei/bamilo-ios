//
//  SessionManager.m
//  Bamilo
//
//  Created by Narbeh Mirzaei on 1/29/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "SessionManager.h"

@implementation SessionManager

static SessionManager *instance;

+(instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[SessionManager alloc] init];
    });
    
    return instance;
}

-(int) evaluateActiveSessions {
    NSNumber *numberOfSessions = [[NSUserDefaults standardUserDefaults] objectForKey:kNumberOfSessions];
    NSInteger numberOfSessionsInteger = 0;
    
    if(numberOfSessions) {
        NSInteger numberOfSessionsInteger = [numberOfSessions integerValue];
        NSDate *startSessionDate = [[NSUserDefaults standardUserDefaults] objectForKey:kSessionDate];
        if(startSessionDate) {
            CGFloat timeSinceStartOfSession = [startSessionDate timeIntervalSinceNow];
            if(fabs(timeSinceStartOfSession) > kSessionDuration) {
                numberOfSessionsInteger += 1;
            }
        }
    } else {
        numberOfSessionsInteger = 1;
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:kSessionDate];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:numberOfSessionsInteger] forKey:kNumberOfSessions];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    return (int)numberOfSessionsInteger;
}

@end
