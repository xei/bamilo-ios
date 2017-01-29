//
//  SessionManager.h
//  Bamilo
//
//  Created by Narbeh Mirzaei on 1/29/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kSessionDuration 1800.0f

@interface SessionManager : NSObject

+(instancetype) sharedInstance;

-(int) evaluateActiveSessions;

@end
