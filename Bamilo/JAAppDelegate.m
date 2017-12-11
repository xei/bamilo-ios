
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
#import "JAUtils.h"
#import "Adjust.h"
#import "RIProduct.h"
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
#import "EmarsysMobileEngage.h"
#import "EmarsysMobileEngageTracker.h"
#import "EmarsysPredictManager.h"
#import "Bamilo-Swift.h"

@interface JAAppDelegate ()

@property (nonatomic, strong) NSDate *startLoadingTime;

@end

@implementation JAAppDelegate

+(JAAppDelegate *)instance {
    return (JAAppDelegate *)[UIApplication sharedApplication].delegate;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [[NSUserDefaults standardUserDefaults] setObject:[NSArray arrayWithObjects:@"fa", @"en", nil] forKey:@"AppleLanguages"];
    
    self.startLoadingTime = [NSDate date];
    
    //SET THE LANGUAGE
    RICountry *country = [RICountry getUniqueCountry];
    [RILocalizationWrapper setLocalization:country.selectedLanguage.langCode];
    
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
        kColorBlue1: [UIColor withHexString:@"#1a365e"],
        kColorBlue10: [UIColor withHexString:@"#e9e8ee"],
        kColorOrange: [UIColor withRGBA:255 green:153 blue:0 alpha:1.0f],
        kColorGreen: [UIColor withRGBA:0 green:160 blue:0 alpha:1.0],
        kColorGray: [UIColor withRepeatingRGBA:217 alpha:1.0f],
        kColorDarkGray: [UIColor withRepeatingRGBA:115 alpha:1.0f],
        kColorExtraDarkGray: [UIColor withRepeatingRGBA:80 alpha:1.0f],
        kColorLightGray: [UIColor withRepeatingRGBA:146 alpha:1.0f],
        kColorVeryLightGray: [UIColor withRepeatingRGBA:238 alpha:1.0f],
        kColorExtraLightGray: [UIColor withRepeatingRGBA:186 alpha:1.0f],
        kColorExtraExtraLightGray: [UIColor withRepeatingRGBA:222 alpha:1.0f],
        kColorRed: [UIColor withRGBA:185 green:15 blue:0 alpha:1.0f],
        kColorExtraLightRed: [UIColor withRGBA:254 green:243 blue:242 alpha:1.0f],
        kColorExtraDarkBlue: [UIColor withHexString:@"#1a365e"],
        kColorOrange1: [UIColor withRGBA:254 green:107 blue:12 alpha:1],
        kColorDarkGreen: [UIColor withRGBA:22 green:145 blue:140 alpha:1],
        kColorDarkGreen3: [UIColor withHexString:@"#16918c"],
        kColorGray1: [UIColor withRGBA:83 green:88 blue:91 alpha:1],
        kColorPrimaryGray1: [UIColor withRGBA:83 green:88 blue:91 alpha:0.87],
        kColorSecondaryGray1: [UIColor withRGBA:83 green:88 blue:91 alpha:0.54],
        kColorGray2: [UIColor withHexString:@"#656668"],
        kColorGray3: [UIColor withRGBA:116 green:117 blue:119 alpha:1],
        kColorGray3: [UIColor withHexString:@"#747577"],
        kColorGray4: [UIColor withHexString:@"#858688"],
        kColorGray5: [UIColor withRGBA:149 green:150 blue:152 alpha:1],
        kColorGray7: [UIColor withHexString:@"#b8b8b8"],
        kColorGray8: [UIColor withHexString:@"#959698"],
        kColorGray9: [UIColor withHexString:@"#dbdbdb"],
        kColorGray10: [UIColor withRepeatingRGBA:237 alpha:1],
        kColorGreen1: [UIColor withHexString:@"#00B09B"],
        kColorGreen3: [UIColor withRGBA:1 green:194 blue:173 alpha:1],
        kColorGreen5: [UIColor withRGBA:63 green:210 blue:192 alpha:1],
        kColorPink1 : [UIColor withHexString:@"#D80056"],
        kColorPink3: [UIColor withHexString:@"#e74775"],
        kColorPink10: [UIColor withHexString:@"#fbe8ec"],
    }];
    [[ThemeManager sharedInstance] addThemeColor:cPrimaryPalette color:themeColor];

    [[NSUserDefaults standardUserDefaults] setObject:@"Bamilo-Sans" forKey:kFontRegularNameKey];
    [[NSUserDefaults standardUserDefaults] setObject:@"Bamilo-Sans-Light" forKey:kFontLightNameKey];
    [[NSUserDefaults standardUserDefaults] setObject:@"Bamilo-Sans-Bold" forKey:kFontBoldNameKey];
    [[NSUserDefaults standardUserDefaults] setObject:@"Bamilo-Sans" forKey:kFontMediumNameKey];
    [[NSUserDefaults standardUserDefaults] setObject:@"Bamilo-Sans-Black" forKey:kFontBlackNameKey];

//#ifdef IS_RELEASE
//    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"RITracking_Bamilo" ofType:@"plist"];
//#else
//    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"RITrackingDebug_Bamilo" ofType:@"plist"];
//#endif

//    [[RITrackingWrapper sharedInstance] startWithConfigurationFromPropertyListAtPath:plistPath launchOptions:launchOptions delegate:self];

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
//        UINavigationController *rootViewController = (UINavigationController*)self.window.rootViewController;
//        JARootViewController* mainController = (JARootViewController*) [rootViewController topViewController];
//        if(VALID_NOTEMPTY(mainController, JARootViewController)) {
//            mainController.notification = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
//        }

//        [[RITrackingWrapper sharedInstance] applicationDidReceiveRemoteNotification:[launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey]];
    }
    
    //#########################################################################################################
    //Start Crashlytics
    [Fabric with:@[[Crashlytics class]]];

    //Crashlytics Integration with PushWoosh
    //http://docs.pushwoosh.com/docs/crashlytics-integration
    NSString *userId = [[PushNotificationManager pushManager] getHWID];
    [[Crashlytics sharedInstance] setUserIdentifier:userId];

    //PUSH WOOSH
    //********************************************************************
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
    
    //SETUP TRACKERS
    //********************************************************************
    [TrackerManager addTrackerWithTracker:[EmarsysMobileEngageTracker sharedTracker]];
    [TrackerManager addTrackerWithTracker:[PushWooshTracker sharedTracker]];
    [TrackerManager addTrackerWithTracker:[GoogleAnalyticsTracker sharedTracker]];
    [TrackerManager addTrackerWithTracker:[AdjustTracker sharedTracker]];
    
    NSDictionary *configs = [[NSBundle mainBundle] objectForInfoDictionaryKey:kConfigs];
    if(configs) {
        NSString *isPushWooshBeta = [configs objectForKey:@"Pushwoosh_BETA"];
        if([isPushWooshBeta isEqualToString:@"1"]) {
            [TrackerManager sendTagWithTags:@{ @"Beta": isPushWooshBeta } completion:^(NSError *error) {
                if(error == nil) {
                    NSLog(@"TrackerManager > Beta > %@", isPushWooshBeta);
                }
            }];
        }
    }
    [EmarsysPredictManager setConfigs];
    return YES;
}

#ifdef __IPHONE_8_0
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
    //register to receive notifications
    [application registerForRemoteNotifications];
}

- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void(^)())completionHandler {
//    if(!VALID_NOTEMPTY(application, UIApplication) || UIApplicationStateActive != application.applicationState) {
//        [[RITrackingWrapper sharedInstance] applicationHandleActionWithIdentifier:identifier forRemoteNotification:userInfo];
//    }

    completionHandler();
}
#endif

- (BOOL)application:(UIApplication *)application continueUserActivity:(nonnull NSUserActivity *)userActivity restorationHandler:(nonnull void (^)(NSArray * _Nullable))restorationHandler {
    if ([[userActivity activityType] isEqualToString:NSUserActivityTypeBrowsingWeb]) {
        [Adjust appWillOpenUrl:[userActivity webpageURL]];
        [DeepLinkManager handleUrl:[Adjust convertUniversalLink:[userActivity webpageURL] scheme:[APP_NAME lowercaseString]]];
    }
    
    return YES;
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    
    [[PushNotificationManager pushManager] stopLocationTracking];
    id topViewController = [ViewControllerManager topViewController];
    NSString *screenName;

    if([topViewController conformsToProtocol:@protocol(PerformanceTrackerProtocol)]) {
        screenName = [topViewController getPerformanceTrackerScreenName];
    }

//    if(screenName) {
//        [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventCloseApp] data:[NSDictionary dictionaryWithObject:screenName forKey:kRIEventScreenNameKey]];
//    }
//
//    [[RITrackingWrapper sharedInstance] applicationDidEnterBackground:application];

    [[NSNotificationCenter defaultCenter] postNotificationName:kAppDidEnterBackground object:nil];
}

// In case the app was sent into the background when there was no network connection, we will use
// the background data fetching mechanism to send any pending Google Analytics data.
- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
//    [[RITrackingWrapper sharedInstance] applicationDidEnterBackground:application];
    completionHandler(UIBackgroundFetchResultNewData);
}

-(void)applicationDidBecomeActive:(UIApplication *)application {
    [application setApplicationIconBadgeNumber:0];

    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"appDidEnterForeground" object:nil]];
    PushNotificationManager *pushManager = [PushNotificationManager pushManager];
    [[EmarsysMobileEngage sharedInstance] sendLogin:[pushManager getPushToken] completion:nil];
    
    OpenAppEventSourceType openAppEventSourceType = [[AppManager sharedInstance] getOpenAppEventSource];
    
    if(openAppEventSourceType != OpenAppEventSourceTypePushNotification &&
       openAppEventSourceType != OpenAppEventSourceTypeDeeplink) {
        //EVENT: OPEN APP / DIRECT
        [TrackerManager postEventWithSelector:[EventSelectors openAppSelector] attributes:[EventAttributes openAppWithSource:OpenAppEventSourceTypeDirect]];
    }
    
    [TrackerManager sendTagWithTags:@{ @"AppOpenCount": @([UserDefaultsManager incrementCounter:kUDMAppOpenCount]) } completion:^(NSError *error) {
        if(error == nil) {
            NSLog(@"TrackerManager > AppOpenCount > %d", [UserDefaultsManager getCounter:kUDMAppOpenCount]);
        }
    }];
    
    //Reset to none for next app open
    [[AppManager sharedInstance] updateOpenAppEventSource:OpenAppEventSourceTypeNone];
    
    [[AppManager sharedInstance] updateScheduledAppIcons];
    [[AppManager sharedInstance] executeScheduledAppIcons];
    
    [[PushNotificationManager pushManager] startLocationTracking];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    
    self.startLoadingTime = [NSDate date];

    [[SessionManager sharedInstance] evaluateActiveSessions];

//    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
//    NSMutableDictionary *trackingDictionary = [[NSMutableDictionary alloc] init];
//
//    [trackingDictionary setValue:[infoDictionary valueForKey:@"CFBundleVersion"] forKey:kRILaunchEventAppVersionDataKey];
//    [trackingDictionary setValue:[JAUtils getDeviceModel] forKey:kRILaunchEventDeviceModelDataKey];
//
//    CGFloat duration = fabs([self.startLoadingTime timeIntervalSinceNow] * 1000);
//
//    [trackingDictionary setValue:[NSString stringWithFormat:@"%f", duration] forKey:kRILaunchEventDurationDataKey];

//    [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventOpenApp]
//                                              data:[trackingDictionary copy]];

    [[NSNotificationCenter defaultCenter] postNotificationName:kAppWillEnterForeground object:nil];
}

- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window {
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark - Push Notification
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
//    [[RITrackingWrapper sharedInstance] applicationDidRegisterForRemoteNotificationsWithDeviceToken:deviceToken];

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
    //PUSH WOOSH
    [[PushNotificationManager pushManager] handlePushReceived:userInfo];
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
//    [[RITrackingWrapper sharedInstance] applicationDidReceiveLocalNotification:notification];
}

#pragma mark - Open URL Scheme
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {

    [Adjust appWillOpenUrl:url = [GSDDeepLink handleDeepLink:url]];

    if (url) {
//        [[RITrackingWrapper sharedInstance] trackOpenURL:url];
        [DeepLinkManager handleUrl:url];
    
        //EVENT: OPEN APP / DEEP LINK
        [TrackerManager postEventWithSelector:[EventSelectors openAppSelector] attributes:[EventAttributes openAppWithSource:OpenAppEventSourceTypeDeeplink]];
        
        return YES;
    }

    return NO;
}

@end
