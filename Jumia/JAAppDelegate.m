//
//  JAAppDelegate.m
//  Jumia
//
//  Created by Pedro Lopes on 24/07/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JAAppDelegate.h"
#import "JARootViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import <HockeySDK/HockeySDK.h>

#define kSessionDuration 1800.0f

@interface JAAppDelegate ()

@end

@implementation JAAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
#if defined(DEBUG) && DEBUG
    
#if defined(STAGING) && STAGING
    [[BITHockeyManager sharedHockeyManager] configureWithIdentifier:@"9e886b9cb1a1dbb18eb575c7582ab3c9"];
#else
    [[BITHockeyManager sharedHockeyManager] configureWithIdentifier:@"3c9ad1f5e09a65331e412821125cc2f2"];
#endif
    [[BITHockeyManager sharedHockeyManager].crashManager setCrashManagerStatus:BITCrashManagerStatusAutoSend];
    [[BITHockeyManager sharedHockeyManager] startManager];
    
    // we will run authenticateInstallation only if it is a from hockey
#if defined(HOCKEY) && HOCKEY
    [[BITHockeyManager sharedHockeyManager].authenticator authenticateInstallation];
#endif
    
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"RITrackingDebug" ofType:@"plist"];
#else
    [[BITHockeyManager sharedHockeyManager] configureWithIdentifier:@"dc297f584830db92a1047ba154dadb9e"];
    [[BITHockeyManager sharedHockeyManager].crashManager setCrashManagerStatus:BITCrashManagerStatusAutoSend];
    [[BITHockeyManager sharedHockeyManager] startManager];
    
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"RITracking" ofType:@"plist"];
#endif
    
    [[RITrackingWrapper sharedInstance] startWithConfigurationFromPropertyListAtPath:plistPath
                                                                       launchOptions:launchOptions];
    
    [FBLoginView class];
    
    [self checkSession];
    
    [[UINavigationBar appearance] setBarTintColor:UIColorFromRGB(0xeaeaea)];
    
    [[UIBarButtonItem appearanceWhenContainedIn:[UISearchBar class], nil]
     setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                             UIColorFromRGB(0xc8c8c8), NSForegroundColorAttributeName,
                             [UIFont fontWithName:@"HelveticaNeue-Light" size:18.0f], NSFontAttributeName,nil] forState:UIControlStateNormal];
    
    [[UIBarButtonItem appearanceWhenContainedIn:[UISearchBar class], nil]
     setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                             [UIColor orangeColor], NSForegroundColorAttributeName,
                             [UIFont fontWithName:@"HelveticaNeue-Light" size:18.0f], NSFontAttributeName,nil] forState:UIControlStateSelected];
    
    NSDictionary *cookieProperties = [[NSUserDefaults standardUserDefaults] objectForKey:kPHPSESSIDCookie];
    if(VALID_NOTEMPTY(cookieProperties, NSDictionary))
    {
        NSHTTPCookie *cookie = [NSHTTPCookie cookieWithProperties:cookieProperties];
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
    }
    
    // Push Notifications Activation
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes: (UIRemoteNotificationTypeBadge |
                                                                            UIRemoteNotificationTypeSound |
                                                                            UIRemoteNotificationTypeAlert )];
    
    if ([launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey] != nil)
    {
        UINavigationController *rootViewController = (UINavigationController*)self.window.rootViewController;
        JARootViewController* mainController = (JARootViewController*) [rootViewController topViewController];
        if(VALID_NOTEMPTY(mainController, JARootViewController))
        {
            mainController.notification = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
        }
        [[RITrackingWrapper sharedInstance] applicationDidReceiveRemoteNotification:[launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey]];
    }
    
    return YES;
}

- (void)checkSession
{
    NSNumber *numberOfSessions = [[NSUserDefaults standardUserDefaults] objectForKey:kNumberOfSessions];
    if(VALID_NOTEMPTY(numberOfSessions, NSNumber))
    {
        NSInteger numberOfSessionsInteger = [numberOfSessions integerValue];
        NSDate *startSessionDate = [[NSUserDefaults standardUserDefaults] objectForKey:kSessionDate];
        if(VALID_NOTEMPTY(startSessionDate, NSDate))
        {
            CGFloat timeSinceStartOfSession = [startSessionDate timeIntervalSinceNow];
            if(fabs(timeSinceStartOfSession) > kSessionDuration)
            {
                [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:kSessionDate];
                [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:numberOfSessionsInteger + 1] forKey:kNumberOfSessions];
            }
        }
    }
    else
    {
        [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:kSessionDate];
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:1] forKey:kNumberOfSessions];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    UINavigationController *rootViewController = (UINavigationController*)self.window.rootViewController;
    JARootViewController* mainController = (JARootViewController*) [rootViewController topViewController];
    if(VALID_NOTEMPTY(mainController, JARootViewController))
    {
        UINavigationController* centerPanel = (UINavigationController*) [mainController centerPanel];
        if(VALID_NOTEMPTY(centerPanel, UINavigationController))
        {
            NSArray *viewControllers = centerPanel.viewControllers;
            if(VALID_NOTEMPTY(viewControllers, NSArray))
            {
                JABaseViewController *rootViewController = (JABaseViewController *) OBJECT_AT_INDEX(viewControllers, [viewControllers count] - 1);
                NSString *screenName = rootViewController.screenName;
                if(VALID_NOTEMPTY(screenName, NSString))
                {
                    [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventCloseApp] data:[NSDictionary dictionaryWithObject:screenName forKey:kRIEventScreenNameKey]];
                }
            }
        }
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [self checkSession];
}

#pragma mark - Push notification

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    [[RITrackingWrapper sharedInstance] applicationDidRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    if(!VALID_NOTEMPTY(application, UIApplication) || UIApplicationStateActive != application.applicationState)
    {
        [[RITrackingWrapper sharedInstance] applicationDidReceiveRemoteNotification:userInfo];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kSelectedCountryNotification
                                                            object:nil
                                                          userInfo:userInfo];
    }
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    [[RITrackingWrapper sharedInstance] applicationDidReceiveLocalNotification:notification];
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    BOOL urlWasHandled = [FBAppCall handleOpenURL:url
                                sourceApplication:sourceApplication
                                  fallbackHandler:^(FBAppCall *call) {
                                      NSLog(@"Unhandled deep link: %@", url);
                                  }];
    
    if (VALID_NOTEMPTY(url, NSURL))
    {
        [[RITrackingWrapper sharedInstance] trackOpenURL:url];
    }
    
    return urlWasHandled;
}

@end
