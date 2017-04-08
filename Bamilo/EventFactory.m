//
//  EventFactory.m
//  Bamilo
//
//  Created by Narbeh Mirzaei on 4/8/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "EventFactory.h"

@implementation EventFactory

+(NSDictionary *)login:(NSString *)loginMethod success:(BOOL)success {
    NSMutableDictionary *attributes = [LoginEvent attributes];
    
    [attributes setObject:loginMethod forKey:kEventMethod];
    [attributes setObject:@(success) forKey:kEventSuccess];
    
    return attributes;
}

+(NSDictionary *)signup:(NSString *)signupMethod success:(BOOL)success {
    NSMutableDictionary *attributes = [SignUpEvent attributes];
    
    [attributes setObject:signupMethod forKey:kEventMethod];
    [attributes setObject:@(success) forKey:kEventSuccess];
    
    return attributes;
}

+(NSDictionary *)logout:(BOOL)success {
    NSMutableDictionary *attributes = [LogoutEvent attributes];
    
    [attributes setObject:@(success) forKey:kEventSuccess];
    
    return attributes;
}

@end
