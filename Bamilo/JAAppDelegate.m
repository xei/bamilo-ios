//
//  JAAppDelegate.m
//  Jumia
//
//  Created by Pedro Lopes on 24/07/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JAAppDelegate.h"
#import "JARootViewController.h"
#import "JAUtils.h"
#import "RIAdjustTracker.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <GoogleAppIndexing/GoogleAppIndexing.h>
#import "RIProduct.h"
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>

#define kSessionDuration 1800.0f

@interface JAAppDelegate ()
<RIAdjustTrackerDelegate>

@property (nonatomic, strong)NSDate *startLoadingTime;

@end

@implementation JAAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
//    [[RIDataBaseWrapper sharedInstance] deleteAllEntriesOfType:NSStringFromClass([RIProduct class])];
    self.startLoadingTime = [NSDate date];
    
    [[NSUserDefaults standardUserDefaults] setObject:@"Bamilo-Sans" forKey:kFontRegularNameKey];
    [[NSUserDefaults standardUserDefaults] setObject:@"Bamilo-Sans-Light" forKey:kFontLightNameKey];
    [[NSUserDefaults standardUserDefaults] setObject:@"Bamilo-Sans-Bold" forKey:kFontBoldNameKey];
    [[NSUserDefaults standardUserDefaults] setObject:@"Bamilo-Sans" forKey:kFontMediumNameKey];
    [[NSUserDefaults standardUserDefaults] setObject:@"Bamilo-Sans-Black" forKey:kFontBlackNameKey];

#ifdef IS_DEBUG
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"RITrackingDebug_Bamilo" ofType:@"plist"];
#elif IS_STAGING
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"RITrackingDebug_Bamilo" ofType:@"plist"];
    [Fabric with:@[[Crashlytics class]]];
#elif IS_RELEASE
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"RITracking_Bamilo" ofType:@"plist"];
#endif
    
    [[RITrackingWrapper sharedInstance] startWithConfigurationFromPropertyListAtPath:plistPath launchOptions:launchOptions delegate:self];

    [[GSDAppIndexing sharedInstance] registerApp:kAppStoreIdBamiloInteger];
    
    [[FBSDKApplicationDelegate sharedInstance] application:application didFinishLaunchingWithOptions:launchOptions];
    
    [self checkSession];
    
    [[UINavigationBar appearance] setBarTintColor:JABlack300Color];
    
    [[UIBarButtonItem appearanceWhenContainedIn:[UISearchBar class], nil]
     setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                             JABackgroundGrey, NSForegroundColorAttributeName,
                             [UIFont fontWithName:kFontLightName size:18.0f], NSFontAttributeName,nil] forState:UIControlStateNormal];
    
    [[UIBarButtonItem appearanceWhenContainedIn:[UISearchBar class], nil]
     setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                             [UIColor orangeColor], NSForegroundColorAttributeName,
                             [UIFont fontWithName:kFontLightName size:18.0f], NSFontAttributeName,nil] forState:UIControlStateSelected];
    
    
    NSString* phpSessIDCookie = [NSString stringWithFormat:@"%@%@",kPHPSESSIDCookie,[RIApi getCountryIsoInUse]];
    NSDictionary *cookieProperties = [[NSUserDefaults standardUserDefaults] objectForKey:phpSessIDCookie];
    if(VALID_NOTEMPTY(cookieProperties, NSDictionary))
    {
        NSHTTPCookie *cookie = [NSHTTPCookie cookieWithProperties:cookieProperties];
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
    }

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

#ifdef __IPHONE_8_0
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:   (UIUserNotificationSettings *)notificationSettings {
    //register to receive notifications
    [application registerForRemoteNotifications];
}

- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString   *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void(^)())completionHandler {
    if(!VALID_NOTEMPTY(application, UIApplication) || UIApplicationStateActive != application.applicationState) {
        [[RITrackingWrapper sharedInstance] applicationHandleActionWithIdentifier:identifier forRemoteNotification:userInfo];
    }
    
    completionHandler();
}
#endif

- (BOOL)application:(UIApplication *)application continueUserActivity:(nonnull NSUserActivity *)userActivity restorationHandler:(nonnull void (^)(NSArray * _Nullable))restorationHandler {
    if ([[userActivity activityType] isEqualToString:NSUserActivityTypeBrowsingWeb]) {
        [Adjust appWillOpenUrl:[userActivity webpageURL]];
        
        NSString* appName = [APP_NAME lowercaseString];
        
        NSURL * deeplink = [Adjust convertUniversalLink:[userActivity webpageURL] scheme:appName];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self handlePushNotificationURL:deeplink];
        });
        
    }
    return YES;
}

- (void)checkSession {
    NSNumber *numberOfSessions = [[NSUserDefaults standardUserDefaults] objectForKey:kNumberOfSessions];
    if(VALID_NOTEMPTY(numberOfSessions, NSNumber)) {
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
    UINavigationController *rootViewController = (UINavigationController*) self.window.rootViewController;
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
    
    [[RITrackingWrapper sharedInstance] applicationDidEnterBackground:application];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kAppDidEnterBackground object:nil];
}

// In case the app was sent into the background when there was no network connection, we will use
// the background data fetching mechanism to send any pending Google Analytics data.
- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    [[RITrackingWrapper sharedInstance] applicationDidEnterBackground:application];
    completionHandler(UIBackgroundFetchResultNewData);
}


- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [RIApi startApiWithCountry:nil
                     reloadAPI:NO
                  successBlock:^(RIApi *api, BOOL hasUpdate, BOOL isUpdateMandatory){
                      if(hasUpdate)
                      {
                          if(isUpdateMandatory)
                          {
                              UIAlertView *alert = [[UIAlertView alloc] initWithTitle:STRING_UPDATE_NECESSARY_TITLE message:[NSString stringWithFormat:STRING_UPDATE_NECESSARY_MESSAGE, APP_NAME] delegate:self cancelButtonTitle:STRING_OK_UPDATE otherButtonTitles:nil];
                              [alert setTag:kForceUpdateAlertViewTag];
                              [alert show];
                          }
                          else
                          {
                              UIAlertView *alert = [[UIAlertView alloc] initWithTitle:STRING_UPDATE_AVAILABLE_TITLE message:[NSString stringWithFormat:STRING_UPDATE_AVAILABLE_MESSAGE, APP_NAME] delegate:self cancelButtonTitle:STRING_NO_THANKS otherButtonTitles:STRING_UPDATE, nil];
                              [alert setTag:kUpdateAvailableAlertViewTag];
                              [alert show];
                          }
                      }
                  }
               andFailureBlock:^(RIApiResponse apiResponse, NSArray *errorMessage){}];
    
    self.startLoadingTime = [NSDate date];
    
    [self checkSession];
    
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSMutableDictionary *trackingDictionary = [[NSMutableDictionary alloc] init];
    
    [trackingDictionary setValue:[infoDictionary valueForKey:@"CFBundleVersion"] forKey:kRILaunchEventAppVersionDataKey];    
    [trackingDictionary setValue:[JAUtils getDeviceModel] forKey:kRILaunchEventDeviceModelDataKey];

    CGFloat duration = fabs([self.startLoadingTime timeIntervalSinceNow] * 1000);
    
    [trackingDictionary setValue:[NSString stringWithFormat:@"%f", duration] forKey:kRILaunchEventDurationDataKey];
    
    [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventOpenApp]
                                              data:[trackingDictionary copy]];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kAppWillEnterForeground object:nil];
}

- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
    NSUInteger supportedInterfaceOrientationsForWindow = -1;
    
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
                supportedInterfaceOrientationsForWindow = [rootViewController supportedInterfaceOrientations];
            }
        }
    }

    // This should not happen.
    if(-1 == supportedInterfaceOrientationsForWindow)
    {
        supportedInterfaceOrientationsForWindow = UIInterfaceOrientationMaskPortrait;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            supportedInterfaceOrientationsForWindow = UIInterfaceOrientationMaskAll;
        }
    }
    return supportedInterfaceOrientationsForWindow;
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
    url = [GSDDeepLink handleDeepLink:url];
    [Adjust appWillOpenUrl:url];
    
    BOOL urlWasHandled = [[FBSDKApplicationDelegate sharedInstance] application:application openURL:url sourceApplication:sourceApplication annotation:annotation];
    
    if (!urlWasHandled && VALID_NOTEMPTY(url, NSURL))
    {
        [[RITrackingWrapper sharedInstance] trackOpenURL:url];
            
        dispatch_async(dispatch_get_main_queue(), ^{
            [self handlePushNotificationURL:url];
        });
    }
    
    return urlWasHandled;
}

- (void)handlePushNotificationURL:(NSURL *)url {
    NSString *urlScheme = [url scheme];
    
    NSDictionary* infoDict = [[NSBundle mainBundle] infoDictionary];
    NSString *faceAppId = [infoDict objectForKey:@"FacebookAppID"];
    NSString *facebookSchema = @"";
    
    if (faceAppId.length > 0) {
        facebookSchema = [NSString stringWithFormat:@"fb%@", faceAppId];
    }
    NSString* appName = [APP_NAME lowercaseString];

    if ((urlScheme != nil && [urlScheme isEqualToString:appName]) || (urlScheme != nil && [facebookSchema isEqualToString:urlScheme]))
    {
        NSMutableDictionary *pushNotification = [NSMutableDictionary dictionaryWithObject:@"" forKey:@"u"];
        
        if ([facebookSchema isEqualToString:urlScheme])
        {
            [[RITrackingWrapper sharedInstance] handlePushNotifcation:pushNotification];
        }
        else
        {
            NSString *path = [NSString stringWithString:url.path];
            NSString *urlHost = [NSString stringWithString:url.host];
            NSString *urlQuery = nil;
            
            if (url.query != nil)
            {
                if ([url.query length] >= 5)
                {
                    if (![[url.query substringToIndex:4] isEqualToString:@"ADXID"])
                    {
                        NSRange range = [url.query rangeOfString:@"?ADXID"];
                        if (range.location != NSNotFound)
                        {
                            NSString *paramsWithoutAdXData = [url.query substringToIndex:range.location];
                            urlQuery = [NSString stringWithFormat:@"?%@",paramsWithoutAdXData];
                            path = [url.path stringByAppendingString:urlQuery];
                        } else
                        {
                            urlQuery = [NSString stringWithFormat:@"?%@",url.query];
                            path = [url.path stringByAppendingString:urlQuery];
                        }
                    }
                }
            }
            
            NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
            if (![urlHost isEqualToString:bundleIdentifier])
            {
                path = [urlHost stringByAppendingString:path];
            }
            else
            {
                path = [path substringFromIndex:1];
            }
            
            NSDictionary *dict = [self parseQueryString:[url query]];
            
            pushNotification = [NSMutableDictionary dictionaryWithObject:path forKey:@"u"];
            
            NSString *temp = [dict objectForKey:@"UTM"];
            
            if (temp)
            {
                [pushNotification addEntriesFromDictionary:dict];
            }
            
            [[RITrackingWrapper sharedInstance] handlePushNotifcation:pushNotification];
        }
    }
}

- (NSDictionary *)parseQueryString:(NSString *)query
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithCapacity:16];
    NSArray *pairs = [query componentsSeparatedByString:@"&"];
    
    for (NSString *pair in pairs)
    {
        NSArray *elements = [pair componentsSeparatedByString:@"="];
        
        NSString *key = [elements[0] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSString *val = [elements[1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        [dict setObject:val forKey:key];
    }
    
    return dict;
}

- (void)adjustAttributionChanged:(NSString *)network campaign:(NSString *)campaign adGroup:(NSString *)adGroup creative:(NSString *)creative
{
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    if(VALID_NOTEMPTY(network, NSString)) {
        [dictionary setObject:network forKey:kRIEventNetworkKey];
    }
    if(VALID_NOTEMPTY(campaign, NSString))
    {
        [dictionary setObject:campaign forKey:kRIEventAdgroupKey];
    }
    if(VALID_NOTEMPTY(adGroup, NSString))
    {
        [dictionary setObject:adGroup forKey:kRIEventCreativeKey];
    }
    if(VALID_NOTEMPTY(creative, NSString))
    {
        [dictionary setObject:creative forKey:kRIEventCreativeKey];
    }
    
    [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventInstallViaAdjust] data:dictionary];
}

-(void)applicationDidBecomeActive:(UIApplication *)application
{
    [FBSDKAppEvents activateApp];
}


#pragma mark UIAlertView

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if(kUpdateAvailableAlertViewTag == [alertView tag])
    {
        if(0 == buttonIndex)
        {
            //cancel
        }
        else if(1 == buttonIndex)
        {
            NSURL  *url;
            
            url = [NSURL URLWithString:kAppStoreUrlBamilo];

            if([[UIApplication sharedApplication] canOpenURL:url]) {
                [[UIApplication sharedApplication] openURL:url];
            }
        }
    }
    else if(kForceUpdateAlertViewTag == [alertView tag])
    {
        if(0 == buttonIndex)
        {
            NSURL  *url;
            url = [NSURL URLWithString:kAppStoreUrlBamilo];
            if([[UIApplication sharedApplication] canOpenURL:url]) {
                [[UIApplication sharedApplication] openURL:url];
            }
        }
    }
}

@end
