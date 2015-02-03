//
//  BMA4SInAppNotification.h
//  Accengage SDK 
//
//  Copyright (c) 2010-2014 Accengage. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <UIKit/UIKit.h>

extern NSString *const BMA4SInAppNotification_Clicked;
extern NSString *const BMA4SInAppNotification_DidAppear;
extern NSString *const BMA4S_InAppNotification_Closed;
extern NSString *const BMA4S_InAppNotification_DataAvailable;
// Key used to store NSData received as an inAppNotification
extern NSString *const BMA4S_InAppNotification_DataKey;

/**
 You can use this class to manage inApp notification
 */
@interface BMA4SInAppNotification : NSObject

/**
 By default, the notifications are displayed at the bottom of the screen in Portrait mode.
 @param position CGPoint value for the position (x,y) of the banner in the screen.

 To change this position, you have to call setDefaultBannerOriginForPortrait with the required CGPoint.
 
    [BMA4SInAppNotification setDefaultBannerOriginForPortrait:CGPointMake(0, 200)];
 
 */
+ (void) setDefaultBannerOriginForPortrait:(CGPoint)position;

/**
 By default, the notifications are displayed at the bottom of the screen in Landscape mode.
 @param position CGPoint value for the position (x,y) of the banner in the screen.

 To change this position, you have to call setDefaultBannerOriginForPortrait with the required CGPoint.
 
    [BMA4SInAppNotification setDefaultBannerOriginForLandscape(0, 200)];
 
 */
+ (void) setDefaultBannerOriginForLandscape:(CGPoint)position;

/**
 Reset the default position of banner in the screen in portrait mode.
 */
+ (void) resetDefaultBannerOriginForPortrait;

/**
  Reset the default position of banner in the screen in landscape mode.
 */
+ (void) resetDefaultBannerOriginForLandscape;

/**
 Change the position of banners in the screen for a given view controller in portrait mode.
 @param position        CGPoint value for the position (x,y) of the banner in the screen.
 @param viewController  the view controller where you want to set a special position for banners
 
 Example : [BMA4SInAppNotification setBannerOriginForPortrait(0, 200) forViewController:self];

 */
+ (void) setBannerOriginForPortrait:(CGPoint)position forViewController:(UIViewController *)viewController;

/**
 Change the position of banners in the screen for a given view controller in landscape mode.
 @param position        CGPoint value for the position (x,y) of the banner in the screen.
 @param viewController  the view controller where you want to set a special position for banners
 
 Example : [BMA4SInAppNotification setBannerOriginForLandscape(0, 200) forViewController:self];
 
 */
+ (void) setBannerOriginForLandscape:(CGPoint)position forViewController:(UIViewController *)viewController;

/**
 Remove specific position for a given view controller in portrait mode
 @note  After calling this method, banners will appear at the default position you may have set in
        setDefaultBannerOriginForPortrait: or if not, at the bottom of the screen.
 */
+ (void) resetOriginForPortraitForViewController:(UIViewController *)viewController;

/**
 Remove specific position for a given view controller in landscape mode
 @note  After calling this method, banners will appear at the default position you may have set in
        setDefaultBannerOriginForPortrait: or if not, at the bottom of the screen.
 */
+ (void) resetOriginForLandscapeForViewController:(UIViewController *)viewController;

/**
 You can prevent the display of any inApp notification, by calling this class method.
 This value can be changed at any time.
 @param locked Boolean value:
 
    - YES: if you want to disable inAppNotification
    - NO: to enable inAppNotification

 */
+ (void) setNotificationLock:(BOOL)locked;


/**
 Call this class method to get the status of notificationLock
 @return Return the state of notificationLock
 */
+ (BOOL) notificationLock;

/** 
 Set minimum time interval between display of 2 inApp notifications in a session
 @param minimumTimeInterval Minimum time interval between display of 2 inApp notifications
 */
+ (void) setNotificationTimeInterval:(NSTimeInterval)minimumTimeInterval;


@end
