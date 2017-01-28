//
//  ConfigManager.m
//  Bamilo
//
//  Created by Narbeh Mirzaei on 1/28/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "ConfigManager.h"

@interface ConfigManager()
//-(BOOL) storeConfigurationFile:(NSDictionary *)configs;
@end

@implementation ConfigManager {
@private
    NSDictionary *_propertyList;
}

-(instancetype)initWithConfigurationFile:(NSString *)plist {
    if (self = [super init]) {
        _propertyList = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:plist ofType:@"plist"]];
    }
    return self;
}

-(NSString *)getConfigurationForKey:(NSString *)key variation:(NSString *)variation {
    if (_propertyList) {
        return [[_propertyList objectForKey:key] objectForKey:variation];
    }
    
    return nil;
}

/*
-(BOOL)saveConfigurationForKey:(NSString *)key variation:(NSString *)variation value:(NSString *)value {
    if (_propertyList) {
        @try {
            [[_propertyList objectForKey:key] setObject:value forKey:variation];
            return true;
        } @catch (NSException *exception) {
            NSLog(@"An exception occurred: %@", exception.name);
            NSLog(@"Here are some details: %@", exception.reason);
            return false;
        }
    }
    
    return false;
}

#pragma mark - Private Methods
-(BOOL)storeConfigurationFile:(NSDictionary *)configs {
    
}
 */

@end
