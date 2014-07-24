//
//  BMA4SNotification.h
//  BMA4SNotification
//
//  Created by fabrice noui on 14/03/11.
//  Copyright 2011 Ad4Screen. All rights reserved.
//

#import <Foundation/Foundation.h>


/*
// in your application delegate, ad the following code :

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
 
	// Override point for customization after application launch.
 
	// Add the view controller's view to the window and display.
	[self.window addSubview:viewController.view];
	[self.window makeKeyAndVisible];
 
	[BMA4STracker trackWithPartnerId:@"your partner id" privateKey:@"your private key"];
 
	// register for notification 
	[[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
	UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
 
	// if iOS launch the application because of a notification, handle it
	[[BMA4SNotification sharedBMA4S] didFinishLaunchingWithOptions:launchOptions controller:viewController];
 
	return YES;
}
 
 
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
	[[BMA4SNotification sharedBMA4S] registerDeviceToken:deviceToken];
}
 
// called by iOS when we receive a notification
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo 
{
	[[BMA4SNotification sharedBMA4S] didReceiveRemoteNotification:userInfo];
}
*/


@class CLLocation;

/** BMA4SNotification is the class that manage push notification.
 */
@interface BMA4SNotification : NSObject 
{
}

/** singleton
@return the BMA4SNotification singleton
*/
+ (BMA4SNotification*) sharedBMA4S;

/** @name push notification required methods*/
/** register the device token to Ad4Screen
 
 In order to be able to send push notification, you must forward the device token to the SDK.
 
	- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
	{
		[[BMA4SNotification sharedBMA4S] registerDeviceToken:deviceToken];
	}
 
 @param deviceToken the token receive in the appDelegate
*/
- (void) registerDeviceToken:(NSData*) deviceToken;

/** Display the notification received at startup if any.
 
 @param launchOptions from [UIApplicationDelegate application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions]
 */
- (void) didFinishLaunchingWithOptions:(NSDictionary *)launchOptions;


/** Forward the push notification to the SDK. It will display the notification.
 
	- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
	{
		[[BMA4SNotification sharedBMA4S] didReceiveRemoteNotification:userInfo];
	}
@param userInfo the notification received from iOS
@warning If the application is not active, an alert notification won't be displayed because it was already displayed by the system.
 
*/
- (void) didReceiveRemoteNotification:(NSDictionary *)userInfo;


/** @name optional methods */


/**  synchronise new value for the user profile

For each user you can create a profile that will contain key and values. This will allow you to use those informations to target specifi user
for push and inApp notification in our back office.

@param values a dictionary containing all the information to upload to our server
*/
- (void) synchroniseProfile:(NSDictionary*)values;

/** Delay the display of push notification 
 This is usefull when your UI needs time to finish loading or when display intersitial at startup.
 The notification will be displayed when value is False. Default value is False
 @param value - NO (default value) to allow notification display
 - YES to delay notification display
 @warning don't forget to set value to NO when your application is ready to display notification if you set
 it to YES at startup.
*/
- (void) setPushNotificationLock:(BOOL)value;

/** update location of the device on the server
@param location location received from locationManager
*/
- (void) updateLocation:(CLLocation*) location;

/** if true, allow the SDK to change every inApp banner or rich push superView
 to ensure they are always above every other view. Default value is false
*/
- (void) allowViewAutomaticalyOnTop:(BOOL)value;

/** update display the local notification
@param notification the localNotification received in your application delegate
*/
- (void)didReceiveLocalNotification:(UILocalNotification *)notification;

/** track opening
@param url the url received in your application delegate
*/
- (BOOL)applicationHandleOpenUrl:(NSURL*)url;

@end