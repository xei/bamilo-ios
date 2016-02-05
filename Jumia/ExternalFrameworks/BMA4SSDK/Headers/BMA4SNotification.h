//
//  BMA4SNotification.h
//  Accengage SDK 
//
//  Copyright (c) 2010-2015 Accengage. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CLLocation;
@class UILocalNotification;

@protocol BMA4SNotificationDelegate <NSObject>
@optional

/**
 *  Called when your app has received a remote notification sended by our platform.
 *
 *  @param notifId The identifier of the notification
 *  @param params  The additional parameters
 *
 *  @note This method is called only if the application is in forground
 *
 *  @since Available in SDK 5.4.0 and later.localnot
 */
- (void)didReceiveNotificationWithId:(NSString *)notifId
                          parameters:(NSDictionary*)params;

/**
 *  Called when the user has clicked on remote notification.
 *
 *  @param notifId The identifier of the notification
 *  @param params  The additional parameters
 *
 *  @since Available in SDK 5.4.0 and later.
 */
- (void)didOpenNotificationWithId:(NSString *)notifId
                       parameters:(NSDictionary*)params;

/**
 *  Called when the user taps an action button in an alert displayed 
 *  in response to a remote notification.
 *
 *  @param actionId The identifier associated with the custom action.
 *  @param notifId  The identifier of the notification
 *  @param params1  The additional parameters associated with the notification
 *  @param params2  The additional parameters associated with the action
 *
 *  @since Available in SDK 5.4.0 and later.
 */
- (void)didClickOnActionWithIdentifier:(NSString *)actionId
           forRemoteNotificationWithId:(NSString *)notifId
                notificationParameters:(NSDictionary*)params1
                      actionParameters:(NSDictionary*)params2;

@end


@interface BMA4SNotification : NSObject

/**
 The notifications delegate must adopt the
 BMA4SNotificationDelegate protocol.  
 
 @since Available in SDK 5.4.0 and later.
 */
@property (nonatomic, assign) id<BMA4SNotificationDelegate> delegate;

/**
 Get the Singleton
 */
+ (BMA4SNotification*)sharedBMA4S;


/** 
 Register the user device token with Accengage
 @param deviceToken This value is given by the following method in your appDelegate:
 
    - (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
 
 */
- (void)registerDeviceToken:(NSData*) deviceToken;

/**
 Check if the app was launched because of the reception of a notification and display the notification if necessary
 @param launchOptions This value is given by the following method in your appDelegate:
 
    - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions

 */
- (void)didFinishLaunchingWithOptions:(NSDictionary *)launchOptions;


/**
 Display the notification
 @param userInfo This value is given by the following method in your appDelegate:
 
    - (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
 
 */
- (void)didReceiveRemoteNotification:(NSDictionary *)userInfo;


/**
 This method allows the SDK to display interactive push notifications sent by Accengage
 
 Add it to your application delegate like this:
 
    - (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void (^)())completionHandler {
        [[BMA4SNotification sharedBMA4S] handleActionWithIdentifier:identifier forRemoteNotification:userInfo];
        completionHandler();
    }

 @param identifier The same as the identifier param of handleActionWithIdentifierforRemoteNotification method in your appDelegate
 @param userInfo   The same as the userInfo param of handleActionWithIdentifierforRemoteNotification method in your appDelegate
 @since            Available in SDK 5.4.0 and later
 
 */
- (void)handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo NS_AVAILABLE_IOS(8_0);

/**
 Synchronise new value for the user profile
 @param values NSDictionary with values that you want to synchronise
 
 NSDictionary* profile = [NSDictionary dictionaryWithObjectsAndKeys: [NSNumber numberWithInt:1000], @"id",
 @"john", @"user", nil];
 [[BMA4SNotification sharedBMA4S] synchroniseProfile:profile];
 
 @deprecated Since 4.0.0, use [BMA4STracker updateDeviceInfo:] instead.
 
 */
- (void)synchroniseProfile:(NSDictionary*)values __attribute__((deprecated("use [BMA4STracker updateDeviceInfo:] instead")));

/**
 Prevent the display of any push notification while displaying ads
 This value can be changed at any time.
 @param value Boolean value:
 
 - YES: if you want to disable inAppNotification
 - NO: to enable inAppNotification
 
 */
- (void)setPushNotificationLock:(BOOL)value;

/**
 Returns the status of pushNotificationLock
 
 @return A boolean value which represents the state of pushNotificationLock
 */
- (BOOL)pushNotificationLock;

/**
 If your application uses geo-location (GPS), you can use the user's location to target your notification based on location criteria.
 
 To update the location on our server you can call this instance method.
 @param location A CLLocation object which represents the location of the user
 */
- (void)updateLocation:(CLLocation*)location;

/**
 Activate the geofence service
 
 If you want to use the geofencing function, call the following method in didFinishLaunchingWithOptions method of your appDelegate.m
 */
- (void)enableGeofenceService;

/**
 Define the placement of inApp banners and rich pushes in the view hierarchy
 
 @param value A boolean value. If TRUE, allow the SDK to place inApp banners or rich pushes above all other views. Default value is TRUE
 */
- (void) allowViewAutomaticallyOnTop:(BOOL)value;

/**
 This method allows the SDK to track and display local notifications sent by Accengage.
 
 Add it to your application delegate like this:
 
    - (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
    {
        [[BMA4SNotification sharedBMA4S] didReceiveLocalNotification:notification];
    }
 
 
 @param notification The same as didReceiveLocalNotification in your appDelegate
 */
- (void)didReceiveLocalNotification:(UILocalNotification *)notification;

/**
 This method allows the SDK to track and display interactive local notifications sent by Accengage
 
 Add it to your application delegate like this:
 
    - (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forLocalNotification:(UILocalNotification *)notification completionHandler:(void (^)())completionHandler {
        [[BMA4SNotification sharedBMA4S] handleActionWithIdentifier:identifier forLocalNotification:notification];
        completionHandler();
    }
 
 @param identifier    The same as the identifier param of handleActionWithIdentifierForLocalNotification method in your appDelegate
 @param notification  The same as the notification param of handleActionWithIdentifierForLocalNotification method in your appDelegate
 @since               Available in SDK 5.4.0 and later
 
 */
-(void)handleActionWithIdentifier:(NSString *)identifier forLocalNotification:(UILocalNotification *)notification NS_AVAILABLE_IOS(8_0);

/**
 Call this method in your appDelegate.
 @param url The same as applicationHandleOpenUrl where this method is called.
 */
- (BOOL)applicationHandleOpenUrl:(NSURL*)url;

/**
 Reset the badge number of the user
 */
- (void)resetBadgeNumber;

/**
 Call this instance method with value NO to prevent SDK from resetting application badge number automatically.
 */
- (void)setAllowBadgeReset:(BOOL)allow;

/**
 Returns the default Accengage notification categories. If you want to use these, you have to add them to UIUserNotificationSettings when registering for push notifications.
 
 Add the following code to your app delegate:
 
    NSSet *categories = [[BMA4SNotification sharedBMA4S] notificationCategories];
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes: (UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories: categories];
    [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
 
 @return Default Accengage notification categories
 @since Available in SDK 5.4.0 and later
 
 */
- (NSSet*)notificationCategories;


/** ----------------------------------------------------------------------------
 * @name Deprecated
 * -----------------------------------------------------------------------------
 */

/**
 * This method is used to activate the geofence service.
 
 * @deprecated This method is deprecated starting from version 5.4.0
 * @note Please use allowViewAutomaticallyOnTop: instead.
 */
- (void) allowViewAutomaticalyOnTop:(BOOL) value __attribute__((deprecated("This method is deprecated starting from version 5.4.0")));

@end
