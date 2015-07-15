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
#import <FacebookSDK/FacebookSDK.h>
#import <HockeySDK/HockeySDK.h>

#define kSessionDuration 1800.0f
#define IS_IOS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)

@interface JAAppDelegate ()
<RIAdjustTrackerDelegate>

@property (nonatomic, strong)NSDate *startLoadingTime;

@end

@implementation JAAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.startLoadingTime = [NSDate date];
    
    //fonts
    if ([[APP_NAME uppercaseString] isEqualToString:@"SHOP.COM.MM"]) {
        [[NSUserDefaults standardUserDefaults] setObject:@"Zawgyi-One" forKey:kFontRegularNameKey];
        [[NSUserDefaults standardUserDefaults] setObject:@"Zawgyi-One" forKey:kFontLightNameKey];
        [[NSUserDefaults standardUserDefaults] setObject:@"Zawgyi-One" forKey:kFontBoldNameKey];
        [[NSUserDefaults standardUserDefaults] setObject:@"Zawgyi-One" forKey:kFontMediumNameKey];
    } else if ([[APP_NAME uppercaseString] isEqualToString:@"بامیلو"]) {
        [[NSUserDefaults standardUserDefaults] setObject:@"HelveticaNeue" forKey:kFontRegularNameKey];
        [[NSUserDefaults standardUserDefaults] setObject:@"HelveticaNeue" forKey:kFontLightNameKey];
        [[NSUserDefaults standardUserDefaults] setObject:@"HelveticaNeue" forKey:kFontBoldNameKey];
        [[NSUserDefaults standardUserDefaults] setObject:@"HelveticaNeue" forKey:kFontMediumNameKey];
    } else {
        [[NSUserDefaults standardUserDefaults] setObject:@"HelveticaNeue" forKey:kFontRegularNameKey];
        [[NSUserDefaults standardUserDefaults] setObject:@"HelveticaNeue-Light" forKey:kFontLightNameKey];
        [[NSUserDefaults standardUserDefaults] setObject:@"HelveticaNeue-Bold" forKey:kFontBoldNameKey];
        [[NSUserDefaults standardUserDefaults] setObject:@"HelveticaNeue-Medium" forKey:kFontMediumNameKey];
    }    
    
#if defined(DEBUG) && DEBUG
    
#if defined(STAGING) && STAGING
    if([[APP_NAME uppercaseString] isEqualToString:@"JUMIA"])
    {
        [[BITHockeyManager sharedHockeyManager] configureWithIdentifier:@"9e886b9cb1a1dbb18eb575c7582ab3c9"];
    }
    else if ([[APP_NAME uppercaseString] isEqualToString:@"DARAZ"])
    {
        [[BITHockeyManager sharedHockeyManager] configureWithIdentifier:@"7275370b79981af6b6437a87d813bafd"];
    }
    else if ([[APP_NAME uppercaseString] isEqualToString:@"SHOP.COM.MM"])
    {
        [[BITHockeyManager sharedHockeyManager] configureWithIdentifier:@"9b9785a49d8763ce4f7d1041e15970cc"];
    }
    else if ([[APP_NAME uppercaseString] isEqualToString:@"بامیلو"])
    {
        [[BITHockeyManager sharedHockeyManager] configureWithIdentifier:@"b69eae07b51d81f272e9ae78312967a8"];
    }
    
#else
    if([[APP_NAME uppercaseString] isEqualToString:@"JUMIA"])
    {
        [[BITHockeyManager sharedHockeyManager] configureWithIdentifier:@"3c9ad1f5e09a65331e412821125cc2f2"];
    }
    else if ([[APP_NAME uppercaseString] isEqualToString:@"DARAZ"])
    {
        [[BITHockeyManager sharedHockeyManager] configureWithIdentifier:@""];
    }
    else if ([[APP_NAME uppercaseString] isEqualToString:@"SHOP.COM.MM"])
    {
        [[BITHockeyManager sharedHockeyManager] configureWithIdentifier:@""];
    }
    else if ([[APP_NAME uppercaseString] isEqualToString:@"بامیلو"])
    {
        [[BITHockeyManager sharedHockeyManager] configureWithIdentifier:@""];
    }
#endif
    [[BITHockeyManager sharedHockeyManager].crashManager setCrashManagerStatus:BITCrashManagerStatusAutoSend];
    [[BITHockeyManager sharedHockeyManager] startManager];
    
    // we will run authenticateInstallation only if it is a from hockey
#if defined(HOCKEY) && HOCKEY
    [[BITHockeyManager sharedHockeyManager].authenticator authenticateInstallation];
#endif
    
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"RITrackingDebug_%@", [APP_NAME uppercaseString]] ofType:@"plist"];
    [[RITrackingWrapper sharedInstance] startWithConfigurationFromPropertyListAtPath:plistPath
                                                                       launchOptions:launchOptions
                                                                        delegate:self];
#else
    if([[APP_NAME uppercaseString] isEqualToString:@"JUMIA"])
    {
        [[BITHockeyManager sharedHockeyManager] configureWithIdentifier:@"dc297f584830db92a1047ba154dadb9e"];
    }
    else if ([[APP_NAME uppercaseString] isEqualToString:@"DARAZ"])
    {
        [[BITHockeyManager sharedHockeyManager] configureWithIdentifier:@"373b0efcd95c82dbfb69a0c2d16c4b51"];
    }
    else if ([[APP_NAME uppercaseString] isEqualToString:@"SHOP.COM.MM"])
    {
        [[BITHockeyManager sharedHockeyManager] configureWithIdentifier:@"d4fd2d8b265e80e20a34fc19ccc55d64"];
    }
    else if ([[APP_NAME uppercaseString] isEqualToString:@"بامیلو"])
    {
        [[BITHockeyManager sharedHockeyManager] configureWithIdentifier:@"64935d72b0c34cd51a7a806f7bb70e4a"];
    }
    [[BITHockeyManager sharedHockeyManager].crashManager setCrashManagerStatus:BITCrashManagerStatusAutoSend];
    [[BITHockeyManager sharedHockeyManager] startManager];
    
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"RITracking_%@", [APP_NAME uppercaseString]] ofType:@"plist"];
    [[RITrackingWrapper sharedInstance] startWithConfigurationFromPropertyListAtPath:plistPath
                                                                       launchOptions:launchOptions
                                                                            delegate:self];
#endif
    
    [FBLoginView class];
    
    [self checkSession];
    
    [[UINavigationBar appearance] setBarTintColor:UIColorFromRGB(0xeaeaea)];
    
    [[UIBarButtonItem appearanceWhenContainedIn:[UISearchBar class], nil]
     setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                             UIColorFromRGB(0xc8c8c8), NSForegroundColorAttributeName,
                             [UIFont fontWithName:kFontLightName size:18.0f], NSFontAttributeName,nil] forState:UIControlStateNormal];
    
    [[UIBarButtonItem appearanceWhenContainedIn:[UISearchBar class], nil]
     setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                             [UIColor orangeColor], NSForegroundColorAttributeName,
                             [UIFont fontWithName:kFontLightName size:18.0f], NSFontAttributeName,nil] forState:UIControlStateSelected];
    
    NSDictionary *cookieProperties = [[NSUserDefaults standardUserDefaults] objectForKey:kPHPSESSIDCookie];
    if(VALID_NOTEMPTY(cookieProperties, NSDictionary))
    {
        NSHTTPCookie *cookie = [NSHTTPCookie cookieWithProperties:cookieProperties];
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
    }
    
    // Push Notifications Activation
    
    BOOL checkNotificationsSwitch = YES;
    BOOL checkSoundSwitch = YES;

    if(!ISEMPTY([[NSUserDefaults standardUserDefaults] objectForKey:kChangeNotificationsOptions]))
    {
        checkNotificationsSwitch = [[NSUserDefaults standardUserDefaults] boolForKey:kChangeNotificationsOptions];
    }
    else
    {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kChangeNotificationsOptions];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    if(!ISEMPTY([[NSUserDefaults standardUserDefaults] objectForKey:kChangeSoundOptions]))
    {
        checkSoundSwitch = [[NSUserDefaults standardUserDefaults] boolForKey:kChangeSoundOptions];
    }
    else
    {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kChangeSoundOptions];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    if (checkNotificationsSwitch && checkSoundSwitch)
    {

        if(IS_IOS_8_OR_LATER) {
            UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes: (UIRemoteNotificationTypeBadge
                                                                                                  |UIRemoteNotificationTypeSound
                                                                                                  |UIRemoteNotificationTypeAlert) categories:nil];
            [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
        } else {
            [[UIApplication sharedApplication] registerForRemoteNotificationTypes: (UIRemoteNotificationTypeBadge |
                                                                                    UIRemoteNotificationTypeSound |
                                                                                    UIRemoteNotificationTypeAlert )];
        }
    }
    else if(checkNotificationsSwitch && !checkNotificationsSwitch)
    {
        if(IS_IOS_8_OR_LATER) {
            UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes: (UIRemoteNotificationTypeBadge
                                                                                                  |UIRemoteNotificationTypeSound) categories:nil];
            [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
        } else {
            [[UIApplication sharedApplication] registerForRemoteNotificationTypes: (UIRemoteNotificationTypeBadge |
                                                                                    UIRemoteNotificationTypeAlert )];
        }
    }
    else{
        [[UIApplication sharedApplication] unregisterForRemoteNotifications];
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
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:   (UIUserNotificationSettings *)notificationSettings
{
    //register to receive notifications
    [application registerForRemoteNotifications];
}

- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString   *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void(^)())completionHandler
{
    //handle the actions
    if ([identifier isEqualToString:@"declineAction"]){
    }
    else if ([identifier isEqualToString:@"answerAction"]){
    }
}
#endif

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
    
    [[RITrackingWrapper sharedInstance] applicationDidEnterBackground:application];
}

// In case the app was sent into the background when there was no network connection, we will use
// the background data fetching mechanism to send any pending Google Analytics data.
- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
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

- (NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
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
    [Adjust appWillOpenUrl:url];
    
    BOOL urlWasHandled = [FBAppCall handleOpenURL:url
                                sourceApplication:sourceApplication
                                  fallbackHandler:^(FBAppCall *call) {
                                      NSLog(@"Unhandled deep link: %@", url);
                                  }];
    
    if (!urlWasHandled && VALID_NOTEMPTY(url, NSURL))
    {
        [[RITrackingWrapper sharedInstance] trackOpenURL:url];
            
        dispatch_async(dispatch_get_main_queue(), ^{
            [self handlePushNotificationURL:url];
        });
    }
    
    return urlWasHandled;
}

- (void)handlePushNotificationURL:(NSURL *)url
{
    NSString *urlScheme = [url scheme];
    
    NSDictionary* infoDict = [[NSBundle mainBundle] infoDictionary];
    NSString *faceAppId = [infoDict objectForKey:@"FacebookAppID"];
    NSString *facebookSchema = @"";
    
    if (faceAppId.length > 0)
    {
        facebookSchema = [NSString stringWithFormat:@"fb%@", faceAppId];
    }
    
    if ((urlScheme != nil && [urlScheme isEqualToString:@"jumia"]) || (urlScheme != nil && [facebookSchema isEqualToString:urlScheme]))
    {
        NSMutableDictionary *pushNotification = [NSMutableDictionary dictionaryWithObject:@"" forKey:@"u"];
        
        if ([facebookSchema isEqualToString:urlScheme])
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:kSelectedCountryNotification
                                                                object:nil
                                                              userInfo:pushNotification];
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

            [[NSNotificationCenter defaultCenter] postNotificationName:kSelectedCountryNotification
                                                                object:nil
                                                              userInfo:pushNotification];
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
    if(VALID_NOTEMPTY(network, NSString))
    {
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
    [FBAppEvents activateApp];
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
            if([[APP_NAME uppercaseString] isEqualToString:@"JUMIA"])
            {
                url = [NSURL URLWithString:kAppStoreUrl];
            }
            else if ([[APP_NAME uppercaseString] isEqualToString:@"DARAZ"])
            {
                url = [NSURL URLWithString:kAppStoreUrlDaraz];
            }
            else if ([[APP_NAME uppercaseString] isEqualToString:@"SHOP.COM.MM"])
            {
                url = [NSURL URLWithString:kAppStoreUrlShop];
            }
            else if ([[APP_NAME uppercaseString] isEqualToString:@"بامیلو"])
            {
                url = [NSURL URLWithString:kAppStoreUrlBamilo];
            }

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
            if([[APP_NAME uppercaseString] isEqualToString:@"JUMIA"])
            {
                url = [NSURL URLWithString:kAppStoreUrl];
            }
            else if ([[APP_NAME uppercaseString] isEqualToString:@"DARAZ"])
            {
                url = [NSURL URLWithString:kAppStoreUrlDaraz];
            }
            else if ([[APP_NAME uppercaseString] isEqualToString:@"SHOP.COM.MM"])
            {
                url = [NSURL URLWithString:kAppStoreUrlShop];
            }
            else if ([[APP_NAME uppercaseString] isEqualToString:@"بامیلو"])
            {
                url = [NSURL URLWithString:kAppStoreUrlBamilo];
            }
            if([[UIApplication sharedApplication] canOpenURL:url]) {
                [[UIApplication sharedApplication] openURL:url];
            }
        }
    }
}

@end
