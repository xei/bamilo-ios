//
//  EventTrackerProtocol.h
//  Bamilo
//
//  Created by Narbeh Mirzaei on 3/25/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol EventTrackerProtocol <NSObject>

-(BOOL) isEventEligable:(NSString *)eventName;
-(void) postEvent:(NSDictionary *)attributes forName:(NSString *)name;

@end
