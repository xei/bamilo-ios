//
//  UserDefaultsManager.m
//  Bamilo
//
//  Created by Narbeh Mirzaei on 4/9/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "UserDefaultsManager.h"

@implementation UserDefaultsManager

+(BOOL)set:(NSString *)key value:(id<NSCoding>)value {
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    [standardUserDefaults setObject:value forKey:key];
    return [standardUserDefaults synchronize];
}

+(id)get:(NSString *)key {
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    return [standardUserDefaults objectForKey:key];
}

+(void)remove:(NSString *)key {
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    [standardUserDefaults removeObjectForKey:key];
    [standardUserDefaults synchronize];
}
    
+(void)update:(NSString *)key insert:(id)value {
    id object = [self get:key];
    NSMutableArray *newObject = object ? [NSMutableArray arrayWithArray:object] : [NSMutableArray array];
    [newObject addObject:value];
    [self remove:key];
    [self set:key value:newObject];
}

//Utility Functions
+(int)getCounter:(NSString *)key {
    NSNumber *counter = [UserDefaultsManager get:key];
    if(counter == nil) {
        [UserDefaultsManager set:key value:[NSNumber numberWithInteger:0]];
        return 0;
    } else {
        return [counter intValue];
    }
}

+(int)incrementCounter:(NSString *)key {
    int counter = [UserDefaultsManager getCounter:key] + 1;
    if([UserDefaultsManager set:key value:[NSNumber numberWithInteger:counter]]) {
        return counter;
    }
    
    return 0;
}

+(BOOL)resetCounter:(NSString *)key {
    return [UserDefaultsManager set:key value:[NSNumber numberWithInteger:0]];
}

@end
