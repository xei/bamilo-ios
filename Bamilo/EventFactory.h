//
//  EventFactory.h
//  Bamilo
//
//  Created by Narbeh Mirzaei on 4/8/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LoginEvent.h"
#import "SignUpEvent.h"
#import "LogoutEvent.h"
#import "OpenAppEvent.h"

@interface EventFactory : NSObject

+(NSDictionary *) login:(NSString *)loginMethod success:(BOOL)success;
+(NSDictionary *) signup:(NSString *)signupMethod success:(BOOL)success;
+(NSDictionary *) logout:(BOOL)success;
+(NSDictionary *) openApp:(int)count source:(OpenAppEventSourceType)source;

@end
