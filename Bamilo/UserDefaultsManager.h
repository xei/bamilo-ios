//
//  UserDefaultsManager.h
//  Bamilo
//
//  Created by Narbeh Mirzaei on 4/9/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserDefaultsConsts.h"

@interface UserDefaultsManager : NSObject

+(BOOL) set:(NSString *)key value:(id)value;
+(id) get:(NSString *)key;
+(void) remove:(NSString *)key;
+(void) update:(NSString *)key insert:(id)value;

//Utility Functions
+(int) getCounter:(NSString *)key;
+(int) incrementCounter:(NSString *)key;
+(BOOL) resetCounter:(NSString *)key;

@end
