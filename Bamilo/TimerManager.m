//
//  TimerManager.m
//  Bamilo
//
//  Created by Narbeh Mirzaei on 4/16/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "TimerManager.h"
#import "IntUtility.h"

#define kTimerId @"TimerId"
#define kTimerSeconds @"TimerSeconds"
#define kTimerCompletion @"TimerCompletion"

@implementation TimerManager {
@private
    NSMutableDictionary *_timers;
}

- (instancetype)init {
    if (self = [super init]) {
        _timers = [NSMutableDictionary new];
    }
    return self;
}

static TimerManager *instance;

+(instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [TimerManager new];
    });
    
    return instance;
}

-(NSString *)setupTimer:(int)seconds completion:(TimerCompletionBlock)completion {
    NSString *timerId = [@([IntUtility randomInt]) stringValue];
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:seconds target:self selector:@selector(executeTimer:) userInfo:@{ kTimerId: timerId, kTimerSeconds: @(seconds), kTimerCompletion: completion } repeats:NO];
    
    [_timers setObject:timer forKey:timerId];
    
    return timerId;
}

-(BOOL)cancelTimer:(NSString *)timerId {
    NSTimer *timer = [_timers objectForKey:timerId];
    if(timer) {
        ((TimerCompletionBlock)[timer.userInfo objectForKey:kTimerCompletion])(NO);
        return [self removeTimer:timerId];
    }
    
    return NO;
}

#pragma mark - Helpers
-(void) executeTimer:(NSTimer *)timer {
    ((TimerCompletionBlock)[timer.userInfo objectForKey:kTimerCompletion])(YES);
    [self removeTimer:[timer.userInfo objectForKey:kTimerId]];
}

-(BOOL) removeTimer:(NSString *)timerId {
    if(timerId && [self invalidateTimer:timerId]) {
        [_timers removeObjectForKey:timerId];
        return YES;
    }
    
    return NO;
}

-(BOOL) invalidateTimer:(NSString *)timerId {
    NSTimer *timer = [_timers objectForKey:timerId];
    if(timer) {
        [timer invalidate];
        timer = nil;
        return YES;
    }
    
    return NO;
}

@end
