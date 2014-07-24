//
//  BMA4SInAppNotification.h
//  MultiTester
//
//  Created by fabrice noui on 18/04/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>



extern NSString *const BMA4SInAppNotification_Clicked;
extern NSString *const BMA4SInAppNotification_DidAppear;
extern NSString *const BMA4S_InAppNotification_Closed;

// Key used to store NSData received as an inAppNotification
extern NSString *const BMA4SINAppNotificationDataKey; 

/** BMA4SInAppNotification allows you to parameter inApp notification.
InApp Notification are notifications that are displayed only when the application is active.

 
The SDK send NSNotification when displaying, closing or when the user click on it.
You can register to those notification to follow inApp Notification life cycle
UserInfo will contains the notification identifier and the parameters filled in our back office
	- (void) registerForInApp
	{
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onInAppNotifClicked:) name:BMA4SInAppNotification_Clicked object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onInAppNotifDidAppear:) name:BMA4SInAppNotification_DidAppear object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onInAppNotifClosed:) name:BMA4S_InAppNotification_Closed object:nil];
	}
 
	- (void) onInAppNotifClicked:(NSNotification*) notif
	{
		NSLog(@"Client Side : On InApp Clicked : %@", notif.userInfo);
	}
	- (void) onInAppNotifDidAppear:(NSNotification*) notif
	{
		NSLog(@"Client Side : On InApp did Appear : %@", notif.userInfo);
	}
	- (void) onInAppNotifClosed:(NSNotification*) notif
	{
		NSLog(@"Client Side : On InApp Closed : %@", notif.userInfo);
	}
*/
@interface BMA4SInAppNotification : NSObject

/** Allow you to change the position of the inApp notification.
This value can be changed at any time. You can configure different position for portrait and landscape orientation.
@param position the top left position for banner
*/
+ (void) setDefaultBannerOriginForPortrait:(CGPoint)position;
+ (void) setDefaultBannerOriginForLandscape:(CGPoint)position;

/** Prevent display of inApp notification. This is usefull when UI loading takes time
or when displaying add.
@param locked This value can be changed at any time.
 
 - Set locked to YES if you want to disable inAppNotification
 - Set locked to NO to enable inAppNotification
 
 @warning don't forget to set value to NO when your application is ready to display inApp notification if you set
 it previously to YES.
*/
+ (void) setNotificationLock:(BOOL)locked;

/** set minimum time interval between display of 2 inApp notifications in a session
@param  minimumTimeInterval delay in seconds between 2 inApp notifications display
*/
+ (void) setNotificationTimeInterval:(NSTimeInterval)minimumTimeInterval;

/** update the sdk with the new orientation when your viewController orientation changes
*/
+ (void) setCurrentOrientation:(UIInterfaceOrientation)interfaceOrientation;

@end
