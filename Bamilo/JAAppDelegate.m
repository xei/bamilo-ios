
//
//  JAAppDelegate.m
//  Jumia
//
//  Created by Pedro Lopes on 24/07/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JAAppDelegate.h"
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import <NewRelicAgent/NewRelic.h>
#import <GoogleAppIndexing/GoogleAppIndexing.h>
#import "JARootViewController.h"
#import "JAUtils.h"
#import "RIAdjustTracker.h"
#import "RIProduct.h"
#import "ConfigManager.h"
#import "AppManager.h"
#import "SessionManager.h"
#import "URLUtility.h"


//#######################################################################################
#import <Pushwoosh/PushNotificationManager.h>
#import <UserNotifications/UserNotifications.h>
#import "ViewControllerManager.h"
#import "BaseViewController.h"
#import "ThemeManager.h"
#import "DeepLinkManager.h"
#import "PushWooshTracker.h"

@interface JAAppDelegate () <RIAdjustTrackerDelegate>

@property (nonatomic, strong)NSDate *startLoadingTime;

@end

@implementation JAAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.startLoadingTime = [NSDate date];
    
    //SETUP THEME
    ThemeFont *themeFont = [ThemeFont fontWithVariations:@{
        kFontVariationRegular: cFontVariationNone,
        kFontVariationBold: @"Bold",
        kFontVariationBlack: @"Black",
        kFontVariationMedium: cFontVariationNone,
        kFontVariationLight: @"Light"
    }];
    [[ThemeManager sharedInstance] addThemeFont:cPrimaryFont font:themeFont];
    
    ThemeColor *themeColor = [ThemeColor colorWithPalette:@{
        kColorBlue: [UIColor withRGBA:74 green:144 blue:226 alpha:1.0f],
        kColorOrange: [UIColor withRGBA:255 green:153 blue:0 alpha:1.0f],
        kColorGreen: [UIColor withRGBA:0 green:160 blue:0 alpha:1.0],
        kColorGray: [UIColor withRepeatingRGBA:217 alpha:1.0f],
        kColorDarkGray: [UIColor withRepeatingRGBA:115 alpha:1.0f],
        kColorExtraDarkGray: [UIColor withRepeatingRGBA:80 alpha:1.0f],
        kColorLightGray: [UIColor withRepeatingRGBA:146 alpha:1.0f],
        kColorExtraLightGray: [UIColor withRepeatingRGBA:186 alpha:1.0f],
        kColorExtraExtraLightGray: [UIColor withRepeatingRGBA:222 alpha:1.0f],
        kColorRed: [UIColor withRGBA:185 green:15 blue:0 alpha:1.0f], 
        kColorExtraLightRed: [UIColor withRGBA:254 green:243 blue:242 alpha:1.0f]
    }];
    [[ThemeManager sharedInstance] addThemeColor:cPrimaryPalette color:themeColor];
    
    [[NSUserDefaults standardUserDefaults] setObject:@"Bamilo-Sans" forKey:kFontRegularNameKey];
    [[NSUserDefaults standardUserDefaults] setObject:@"Bamilo-Sans-Light" forKey:kFontLightNameKey];
    [[NSUserDefaults standardUserDefaults] setObject:@"Bamilo-Sans-Bold" forKey:kFontBoldNameKey];
    [[NSUserDefaults standardUserDefaults] setObject:@"Bamilo-Sans" forKey:kFontMediumNameKey];
    [[NSUserDefaults standardUserDefaults] setObject:@"Bamilo-Sans-Black" forKey:kFontBlackNameKey];

#ifdef IS_RELEASE
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"RITracking_Bamilo" ofType:@"plist"];
#else
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"RITrackingDebug_Bamilo" ofType:@"plist"];
#endif
    
    [[RITrackingWrapper sharedInstance] startWithConfigurationFromPropertyListAtPath:plistPath launchOptions:launchOptions delegate:self];

    [[GSDAppIndexing sharedInstance] registerApp:kAppStoreIdBamiloInteger];
    
    [[SessionManager sharedInstance] evaluateActiveSessions];
    
    [[UINavigationBar appearance] setBarTintColor:JABlack300Color];
    
    [[UIBarButtonItem appearanceWhenContainedIn:[UISearchBar class], nil] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:JABackgroundGrey, NSForegroundColorAttributeName, [Theme font:kFontVariationLight size:18], NSFontAttributeName,nil] forState:UIControlStateNormal];
    
    [[UIBarButtonItem appearanceWhenContainedIn:[UISearchBar class], nil] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[Theme color:kColorOrange], NSForegroundColorAttributeName, [Theme font:kFontVariationLight size:18], NSFontAttributeName,nil] forState:UIControlStateSelected];
    
    NSString* phpSessIDCookie = [NSString stringWithFormat:@"%@%@",kPHPSESSIDCookie,[RIApi getCountryIsoInUse]];
    NSDictionary *cookieProperties = [[NSUserDefaults standardUserDefaults] objectForKey:phpSessIDCookie];
    if(VALID_NOTEMPTY(cookieProperties, NSDictionary)) {
        NSHTTPCookie *cookie = [NSHTTPCookie cookieWithProperties:cookieProperties];
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
    }

    if ([launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey] != nil) {
        UINavigationController *rootViewController = (UINavigationController*)self.window.rootViewController;
        JARootViewController* mainController = (JARootViewController*) [rootViewController topViewController];
        if(VALID_NOTEMPTY(mainController, JARootViewController)) {
            mainController.notification = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
        }
        
        [[RITrackingWrapper sharedInstance] applicationDidReceiveRemoteNotification:[launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey]];
    }
    
//#########################################################################################################
    ConfigManager *configManager = [[ConfigManager alloc] initWithConfigurationFile:@"Bamilo-Configs"];
#ifdef IS_RELEASE
    //NSString *newRelicApiKey = [configManager getConfigurationForKey:@"NewRelic" variation:kConfManagerEnvLive];
    NSString *crashlyticsApiKey = [configManager getConfigurationForKey:@"Crashlytics" variation:kConfManagerEnvLive];
#else
    //NSString *newRelicApiKey = [configManager getConfigurationForKey:@"NewRelic" variation:kConfManagerEnvStaging];
    NSString *crashlyticsApiKey = [configManager getConfigurationForKey:@"Crashlytics" variation:kConfManagerEnvStaging];
#endif
    
    /*
    if (newRelicApiKey) {
        [NewRelicAgent startWithApplicationToken:newRelicApiKey];
        
        #ifdef IS_RELEASE
            [NewRelicAgent enableCrashReporting:YES];
        #else
             [NewRelicAgent disableFeatures:NRFeatureFlag_CrashReporting];
        #endif
    }*/
    
    if(crashlyticsApiKey) {
        [Crashlytics startWithAPIKey:crashlyticsApiKey];
    }
    
    //PUSH WOOSH
    // set custom delegate for push handling, in our case AppDelegate
    PushNotificationManager *pushManager = [PushNotificationManager pushManager];
    pushManager.delegate = [PushWooshTracker sharedTracker];
    
    // set default Pushwoosh delegate for iOS10 foreground push handling
    [UNUserNotificationCenter currentNotificationCenter].delegate = [PushNotificationManager pushManager].notificationCenterDelegate;
    
    // handling push on app start
    [[PushNotificationManager pushManager] handlePushReceived:launchOptions];
    
    // track application open statistics
    [[PushNotificationManager pushManager] sendAppOpen];
    
    // register for push notifications!
    [[PushNotificationManager pushManager] registerForPushNotifications];
    
    
    // Set merchant ID. for emarsysPredict
    EMSession *emarsysSession = [EMSession sharedSession];
    emarsysSession.merchantID = @"18146DE34FE0B8C9";
    emarsysSession.logLevel = EMLogLevelDebug;
    
    return YES;
}

#ifdef __IPHONE_8_0
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
    //register to receive notifications
    [application registerForRemoteNotifications];
}

- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void(^)())completionHandler {
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
        [self handleOpenAppWithURL:deeplink];
    }
    return YES;
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    id topViewController = [ViewControllerManager topViewController];
    NSString *screenName;
    
    if([topViewController conformsToProtocol:@protocol(PerformanceTrackerProtocol)]) {
        screenName = [topViewController getPerformanceTrackerScreenName];
    }
    
    if(screenName) {
        [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventCloseApp] data:[NSDictionary dictionaryWithObject:screenName forKey:kRIEventScreenNameKey]];
    }
    
    /*
    UINavigationController *rootViewController = (UINavigationController*) self.window.rootViewController;
    JARootViewController* mainController = (JARootViewController*) [rootViewController topViewController];
    if(VALID_NOTEMPTY(mainController, JARootViewController)) {
        UINavigationController* centerPanel = (UINavigationController*) [mainController centerPanel];
        if(VALID_NOTEMPTY(centerPanel, UINavigationController)) {
            NSArray *viewControllers = centerPanel.viewControllers;
            if(VALID_NOTEMPTY(viewControllers, NSArray)) {
                JABaseViewController *rootViewController = (JABaseViewController *) OBJECT_AT_INDEX(viewControllers, [viewControllers count] - 1);
                NSString *screenName = [rootViewController getPerformanceTrackerScreenName];
                if(VALID_NOTEMPTY(screenName, NSString)) {

                }
            }
        }
    }*/
    
    [[RITrackingWrapper sharedInstance] applicationDidEnterBackground:application];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kAppDidEnterBackground object:nil];
}

// In case the app was sent into the background when there was no network connection, we will use
// the background data fetching mechanism to send any pending Google Analytics data.
- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    [[RITrackingWrapper sharedInstance] applicationDidEnterBackground:application];
    completionHandler(UIBackgroundFetchResultNewData);
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    [RIApi startApiWithCountry:nil reloadAPI:NO successBlock:^(RIApi *api, BOOL hasUpdate, BOOL isUpdateMandatory){
        if(hasUpdate) {
            if(isUpdateMandatory) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:STRING_UPDATE_NECESSARY_TITLE message:[NSString stringWithFormat:STRING_UPDATE_NECESSARY_MESSAGE, APP_NAME] delegate:self cancelButtonTitle:STRING_OK_UPDATE otherButtonTitles:nil];
                [alert setTag:kForceUpdateAlertViewTag];
                [alert show];
            } else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:STRING_UPDATE_AVAILABLE_TITLE message:[NSString stringWithFormat:STRING_UPDATE_AVAILABLE_MESSAGE, APP_NAME] delegate:self cancelButtonTitle:STRING_NO_THANKS otherButtonTitles:STRING_UPDATE, nil];
                [alert setTag:kUpdateAvailableAlertViewTag];
                [alert show];
            }
        }
    } andFailureBlock:^(RIApiResponse apiResponse, NSArray *errorMessage){
    }];
    
    self.startLoadingTime = [NSDate date];
    
    [[SessionManager sharedInstance] evaluateActiveSessions];
    
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

- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window {
    NSUInteger supportedInterfaceOrientationsForWindow = -1;
    
    UINavigationController *rootViewController = (UINavigationController*)self.window.rootViewController;
    JARootViewController* mainController = (JARootViewController*) [rootViewController topViewController];
    if(VALID_NOTEMPTY(mainController, JARootViewController)) {
        UINavigationController* centerPanel = (UINavigationController*) [mainController centerPanel];
        if(VALID_NOTEMPTY(centerPanel, UINavigationController)) {
            NSArray *viewControllers = centerPanel.viewControllers;
            if(VALID_NOTEMPTY(viewControllers, NSArray)) {
                JABaseViewController *rootViewController = (JABaseViewController *) OBJECT_AT_INDEX(viewControllers, [viewControllers count] - 1);
                supportedInterfaceOrientationsForWindow = [rootViewController supportedInterfaceOrientations];
            }
        }
    }

    // This should not happen.
    if(-1 == supportedInterfaceOrientationsForWindow) {
        supportedInterfaceOrientationsForWindow = UIInterfaceOrientationMaskPortrait;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            supportedInterfaceOrientationsForWindow = UIInterfaceOrientationMaskAll;
        }
    }
    return supportedInterfaceOrientationsForWindow;
}

#pragma mark - Push Notification
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    [[RITrackingWrapper sharedInstance] applicationDidRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
    
    //PUSH WOOSH
    [[PushNotificationManager pushManager] handlePushRegistration:deviceToken];
}

// system push notification registration error callback, delegate to pushManager
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    //PUSH WOOSH
    [[PushNotificationManager pushManager] handlePushRegistrationFailure:error];
}

// system push notifications callback, delegate to pushManager
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    if(!VALID_NOTEMPTY(application, UIApplication) || UIApplicationStateActive != application.applicationState) {
        [[RITrackingWrapper sharedInstance] applicationDidReceiveRemoteNotification:userInfo];
    }
    
    //PUSH WOOSH
    [[PushNotificationManager pushManager] handlePushReceived:userInfo];
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    [[RITrackingWrapper sharedInstance] applicationDidReceiveLocalNotification:notification];
}

#pragma mark - Open URL Scheme
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    
    [Adjust appWillOpenUrl:url = [GSDDeepLink handleDeepLink:url]];
    
    if (url) {
        [[RITrackingWrapper sharedInstance] trackOpenURL:url];
        [self handleOpenAppWithURL:url];
        return YES;
    }
    
    return NO;
}

#pragma mark - Private Methods
- (void)handleOpenAppWithURL:(NSURL *)url {
    
    [DeepLinkManager handleUrl:url];
    
    /*
    NSString *urlScheme = [url scheme];
    
    if (urlScheme) {
        NSString *urlHost = [NSString stringWithString:url.host];
        NSDictionary *queryString = [URLUtility parseQueryString:url];
        
        NSMutableString *queryBuilder = [NSMutableString new];
        for(id key in queryString) {
            if(![key isEqualToString:@"UTM"]) {
                [queryBuilder appendFormat:@"%@/%@", key, [queryString valueForKey:key]];
            }
        }
        
        NSString *path = [url.path stringByAppendingFormat:@"/%@", [NSString stringWithString:queryBuilder]];
        
        NSString *utm = [queryString valueForKey:@"UTM"];
        if(utm) {
            [path stringByAppendingFormat:@"?%@", utm];
        }
        
        NSMutableDictionary *fullUrl = [NSMutableDictionary dictionaryWithObject:[urlHost stringByAppendingString:path] forKey:@"u"];
        
        [[RITrackingWrapper sharedInstance] handlePushNotifcation:fullUrl];
    }
    */
    /*
    NSString *urlScheme = [url scheme];
    if (urlScheme) {
        NSMutableDictionary *fullUrl = [NSMutableDictionary dictionaryWithObject:@"" forKey:@"u"];
        
        NSString *path = [NSString stringWithString:url.path];
        NSString *urlHost = [NSString stringWithString:url.host];
        
        if (url.query && [url.query length] >= 5) {
            if (![[url.query substringToIndex:4] isEqualToString:@"ADXID"]) {
                NSRange range = [url.query rangeOfString:@"?ADXID"];
                if (range.location != NSNotFound) {
                    NSString *paramsWithoutAdXData = [url.query substringToIndex:range.location];
                    path = [url.path stringByAppendingString:[NSString stringWithFormat:@"?%@", paramsWithoutAdXData]];
                } else {
                    path = [url.path stringByAppendingString:[NSString stringWithFormat:@"?%@", url.query]];
                }
            }
        }
        
        NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
        if (![urlHost isEqualToString:bundleIdentifier]) {
            path = [urlHost stringByAppendingString:path];
        } else {
            path = [path substringFromIndex:1];
        }
        
        NSDictionary *dict = [URLUtility parseQueryString:url];
        
        fullUrl = [NSMutableDictionary dictionaryWithObject:path forKey:@"u"];
        
        if ([dict objectForKey:@"UTM"]) {
            [fullUrl addEntriesFromDictionary:dict];
        }
        
        [[RITrackingWrapper sharedInstance] handlePushNotifcation:fullUrl];
    }*/
}

- (void)adjustAttributionChanged:(NSString *)network campaign:(NSString *)campaign adGroup:(NSString *)adGroup creative:(NSString *)creative {
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
    
    [[RITrackingWrapper sharedInstance] trackEvent:@(RIEventInstallViaAdjust) data:dictionary];
}

@end
