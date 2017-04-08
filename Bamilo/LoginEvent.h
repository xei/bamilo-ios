//
//  LoginEvent.h
//  Bamilo
//
//  Created by Narbeh Mirzaei on 4/8/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "AppEvent.h"

@interface LoginEvent : AppEvent

FOUNDATION_EXPORT NSString *const kEventLoginMethod;
FOUNDATION_EXPORT NSString *const kEventEmailDomain;

@end
