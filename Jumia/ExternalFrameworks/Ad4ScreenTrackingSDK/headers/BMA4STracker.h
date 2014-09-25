//
//  BMA4STracker.h
//  Ad4ScreenTrackingSDK
//
//  Created by fabrice noui on 15/11/10.
//  Copyright 2010 ad4screen. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
BMA4STracker is the main entry point of the sdk.
This class will allow you to :
 
 - start the SDK with trackWithPartnerId:privateKey:options:
 - send event with trackEventWithType:parameters:
 - access to device or user ID



Events are data you send to our server and that you can consult on our back office. 
It will allow you to have usage statistic of your application. 
For instance, you can send an event when a user enter in a specific view, when he makes an inApp purchase etc.
 
@warning To be able to launch the SDK, you'll need a partnerId and privateKey provided by Ad4Screen. If you don't have those identifier, please contact Ad4Screen support. 
 
*/
@interface BMA4STracker : NSObject
{
}
/** @name SDK initialisation */
/** call this class method once in your app delegate to track your application. This will setup the SDK.
 
 The better place to start the sdk is in didFinishLaunchingWithOptions like in this example:
	- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
	{
		[BMA4STracker trackWithPartnerId:@"your partner id" privateKey:@"your private key" options:launchOptions];
 
		// your code...
		return YES;
	}
 
 @param partnerId The partnerId we provided
 @param privateKey The privateKey we provided
 @param launchOptions the launchOptions from [UIApplicationDelegate application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions]
 

 */
+ (void) trackWithPartnerId:(NSString*)partnerId privateKey:(NSString*)privateKey options:(NSDictionary *)launchOptions;



/** @name Event management */
/** send an event to Ad4Screen server.
 
 Here is an example :
	- (void) onUserDidFinishBuyAction
	{
		// assuming that self.itemId contains an identifier of the item baught and self.amount its amount.
		NSString* buyEntry = [NSString stringWithFormat:@"buyItem=%d", self.itemId];
		NSString* buyAmount = [NSString stringWithFormat:@"amount=%f", self.amount];
		[BMA4S trackEventWithType:1001 parameters:[NSArray arrayWithObjects:buyEntry, buyAmount, nil]];
	}
 @param eventType a number above 1000 to identify the event. Numbers below 1000 are reserved for further use.
 @param parameters an array of string. Each string format is free, but usually each string follow a key value format such as "amount=10"
 */
+ (void) trackEventWithType:(NSInteger) eventType parameters:(NSArray*) parameters;



/** @name ID access */
/** set an ID that will be reported to Ad4Screen server for this device.
 @param userID your own user ID to our server. (Max length : 128 bytes)
 */
+ (void) setUserID:(NSString*)userID;

/** Your own ID
@return the reported own userID
 */
+ (NSString*) userID;

/** Each device has an ID provided by Ad4Screen. You can use this ID to identify each device.
@return Ad4Screen internal ID
*/
+ (NSString*) A4SID;




/** @name Do Not Track */
/** Ask the SDK to stop uploading information to Ad4Screen Server. 
 @param value YES to stop tracking, NO otherwise. 
 @warning : Any call to any SDK method will also be deactived.
 */
+ (void) setDoNotTrack:(BOOL)value;

/** 
 @return the doNotTrack current value. Default value is NO.
 */
+ (BOOL) doNotTrack;




/** @name debug method */
/** Activate verbose mode. The SDK will provide log for debuging
 @param value YES to activate log, FALSE otherwise
 */
+ (void) setDebugMode:(BOOL)value;

@end