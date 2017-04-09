//
//  AppManager.h
//  Bamilo
//
//  Created by Narbeh Mirzaei on 1/28/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OpenAppEvent.h"

@interface AppManager : NSObject

+(instancetype) sharedInstance;

-(NSString *) getAppVersionNumber;
-(NSString *) getAppBuildNumber;
-(NSString *) getAppFullFormattedVersion;

-(void) updateOpenAppEventSource:(OpenAppEventSourceType)source;
-(OpenAppEventSourceType) getOpenAppEventSource;

@end
