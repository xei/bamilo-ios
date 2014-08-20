//
//  JAAppDelegate.m
//  Jumia
//
//  Created by Pedro Lopes on 24/07/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JAAppDelegate.h"
#import <FacebookSDK/FacebookSDK.h>
#import <HockeySDK/HockeySDK.h>

@interface JAAppDelegate ()

@end

@implementation JAAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
#if defined(DEBUG) && DEBUG
    
    [[BITHockeyManager sharedHockeyManager] configureWithIdentifier:@"9e886b9cb1a1dbb18eb575c7582ab3c9"];
    [[BITHockeyManager sharedHockeyManager].crashManager setCrashManagerStatus:BITCrashManagerStatusAutoSend];
    [[BITHockeyManager sharedHockeyManager] startManager];
    
    // we will run authenticateInstallation only if it is a from hockey
#if defined(HOCKEY) && HOCKEY
    [[BITHockeyManager sharedHockeyManager].authenticator authenticateInstallation];
#endif
    
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"RITrackingDebug" ofType:@"plist"];
#else
    [[BITHockeyManager sharedHockeyManager] configureWithIdentifier:@"9e886b9cb1a1dbb18eb575c7582ab3c9"];
    [[BITHockeyManager sharedHockeyManager] startManager];
    
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"RITracking" ofType:@"plist"];
#endif
    
    
    [[RITrackingWrapper sharedInstance] startWithConfigurationFromPropertyListAtPath:plistPath
                                                                       launchOptions:launchOptions];
    
    [FBLoginView class];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    
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
    
    return urlWasHandled;
}

@end
