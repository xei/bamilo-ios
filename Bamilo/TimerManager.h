//
//  TimerManager.h
//  Bamilo
//
//  Created by Narbeh Mirzaei on 4/16/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, TimerCompletionType) {
    TIMER_COMPLETION_CANCELLED = 0,
    TIMER_COMPLETION_DOME = 1
};

typedef void(^TimerCompletionBlock)(BOOL completed);

@interface TimerManager : NSObject

+(instancetype) sharedInstance;

-(NSString *) setupTimer:(int)seconds completion:(TimerCompletionBlock)completion;
-(BOOL) cancelTimer:(NSString *)timerId;

@end
