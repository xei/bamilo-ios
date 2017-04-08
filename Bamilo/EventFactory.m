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
    
    [attributes setObject:loginMethod forKey:kEventLoginMethod];
    [attributes setObject:@(success) forKey:kEventSuccess];
    
    return attributes;
}

@end
