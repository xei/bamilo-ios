//
//  BaseEvent.h
//  Bamilo
//
//  Created by Narbeh Mirzaei on 3/25/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EventConsts.h"

#define cUNKNOWN_EVENT_VALUE @"?"

@interface BaseEvent : NSObject

+(NSMutableDictionary *) event;
+(NSString *) name;

@end
