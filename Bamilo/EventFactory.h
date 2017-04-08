//
//  EventFactory.h
//  Bamilo
//
//  Created by Narbeh Mirzaei on 4/8/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LoginEvent.h"

@interface EventFactory : NSObject

+(NSDictionary *) login:(NSString *)loginMethod success:(BOOL)success;

@end
