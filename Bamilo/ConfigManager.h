//
//  ConfigManager.h
//  Bamilo
//
//  Created by Narbeh Mirzaei on 1/28/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ConfigManager-Consts.h"

@interface ConfigManager : NSObject

-(instancetype) initWithConfigurationFile:(NSString *)plist;
-(NSString *) getConfigurationForKey:(NSString *)key variation:(NSString *)variation;
//-(BOOL) saveConfigurationForKey:(NSString *)key variation:(NSString *)variation value:(NSString *)value;

@end
