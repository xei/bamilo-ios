//
//  PerformanceTrackerProtocol.h
//  Bamilo
//
//  Created by Narbeh Mirzaei on 2/19/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol PerformanceTrackerProtocol <NSObject>

-(void) recordStartLoadTime;
-(void) publishScreenLoadTime;

-(NSString *) getPerformanceTrackerScreenName;
-(NSString *) getPerformanceTrackerLabel;

@optional
-(BOOL) forcePublishScreenLoadTime;

@end
