//
//  RIAd4PushTracker.m
//  RITracking
//
//  Created by Miguel Chaves on 20/Mar/14.
//  Copyright (c) 2014 Miguel Chaves. All rights reserved.
//

#import "RIAd4PushTracker.h"
#import "BMA4SNotification.h"
#import "BMA4STracker.h"
#import "BMA4SInAppNotification.h"
#import "BMA4STracker+Analytics.h"
#import "GAIFields.h"
#import "RIGoogleAnalyticsTracker.h"
#import "JAAppDelegate.h"
#import "JAHomeViewController.h"

@implementation RIAd4PushTracker

NSString * const kRIAdd4PushUserID = @"kRIAdd4PushUserID";
NSString * const kRIAdd4PushPrivateKey = @"kRIAdd4PushPrivateKey";
NSString * const kRIAdd4PushDeviceToken = @"kRIAdd4PushDeviceToken";

@synthesize queue;

- (id)init
{
    NSLog(@"Initializing Ad4Push tracker");
    
    if ((self = [super init])) {
        self.queue = [[NSOperationQueue alloc] init];
        self.queue.maxConcurrentOperationCount = 1;
    }
    return self;
}

#pragma mark - RITracker protocol

- (void)applicationDidLaunchWithOptions:(NSDictionary *)options
{
    RIDebugLog(@"Add4Push tracker tracks application launch");
    
    NSString *userId = [RITrackingConfiguration valueForKey:kRIAdd4PushUserID];
    NSString *privateKey = [RITrackingConfiguration valueForKey:kRIAdd4PushPrivateKey];
    NSString *deviceToken = [RITrackingConfiguration valueForKey:kRIAdd4PushDeviceToken];
    
    if (!userId) {
        RIRaiseError(@"Missing user ID in tracking properties");
        return;
    }
    
    if (!privateKey) {
        RIRaiseError(@"Missing private key in tracking properties");
        return;
    }
    
    if (!deviceToken) {
        RIRaiseError(@"Missing device token in tracking properties");
        return;
    }
    
    [BMA4STracker setDebugMode:YES];
    
    [BMA4STracker trackWithPartnerId:userId
                          privateKey:privateKey
                             options:options];
    
    dispatch_async(dispatch_get_main_queue(), ^{
       [[BMA4SNotification sharedBMA4S] didFinishLaunchingWithOptions:options]; 
    });
}

#pragma mark - RINotificationTracking protocol

- (void)applicationDidRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{    
    RIDebugLog(@"Ad4Push - Registering for remote notifications.");
    
    id tracker = [BMA4SNotification sharedBMA4S];
    
    if (!tracker) {
        RIRaiseError(@"Missing Ad4Push tracker");
        return;
    }
    
    [[BMA4SNotification sharedBMA4S] registerDeviceToken:deviceToken];
}

- (void)applicationDidReceiveRemoteNotification:(NSDictionary *)userInfo
{
    RIDebugLog(@"Ad4Push - Received remote notification: %@", userInfo);
    
    id tracker = [BMA4SNotification sharedBMA4S];
    
    if (!tracker) {
        RIRaiseError(@"Missing Ad4Push tracker");
        return;
    }
    
    [[BMA4SNotification sharedBMA4S] didReceiveRemoteNotification:userInfo];
    
    [self handleNotificationWithDictionary:userInfo];
}

- (void)applicationDidReceiveLocalNotification:(UILocalNotification *)notification
{
    RIDebugLog(@"Ad4Push - Received local notification: %@", notification);
    
    id tracker = [BMA4SNotification sharedBMA4S];
    
    if (!tracker) {
        RIRaiseError(@"Missing Ad4Push tracker");
        return;
    }
    
    [[BMA4SNotification sharedBMA4S] didReceiveLocalNotification:notification];
}

#pragma mark - RIOpenURL protocol

-(void)trackOpenURL:(NSURL *)url
{
    RIDebugLog(@"Ad4Push - Tracking url: %@", url);
    
    id tracker = [BMA4SNotification sharedBMA4S];
    
    if (!tracker) {
        RIRaiseError(@"Missing Ad4Push tracker");
        return;
    }
    
    [[BMA4SNotification sharedBMA4S] applicationHandleOpenUrl:url];
    
    [self handlePushNotificationWithOpenURL:url];
}

#pragma mark - RIEcommerceEventTracking

-(void)trackCheckoutWithTransactionId:(NSString *)idTransaction
                                total:(RITrackingTotal *)total
{
    RIDebugLog(@"Ad4Push - Tracking checkout");
    
    id tracker = [BMA4SNotification sharedBMA4S];
    
    if (!tracker) {
        RIRaiseError(@"Missing Ad4Push tracker");
        return;
    }
    
    [BMA4STracker trackPurchaseWithId:idTransaction
                             currency:total.currency
                           totalPrice:[total.net doubleValue]];
}

-(void)trackProductAddToCart:(RITrackingProduct *)product
{
    RIDebugLog(@"Ad4Push - Tracking add product to cart: %@", product.name);
    
    id tracker = [BMA4SNotification sharedBMA4S];
    
    if (!tracker) {
        RIRaiseError(@"Missing Ad4Push tracker");
        return;
    }

    [BMA4STracker trackCartWithId:nil
            modificationWithLabel:product.name
                 forArticleWithId:product.identifier
                         category:product.category
                            price:[product.price doubleValue]
                         currency:product.currency
                         quantity:[product.quantity longValue]];
}

-(void)trackRemoveFromCartForProductWithID:(NSString *)idTransaction
                                  quantity:(NSNumber *)quantity
{

}

#pragma mark - Private methods for deeplinkg

- (void)handleNotificationWithDictionary:(NSDictionary *)notification
{
    if (notification != nil && [notification objectForKey:@"UTM"] != nil && [[notification objectForKey:@"UTM"] length] > 0)
    {
        NSString *campaignName = [NSString stringWithFormat:@"%@",[notification objectForKey:@"UTM"]];
        
        NSDictionary *campaignData = [NSDictionary dictionaryWithObjectsAndKeys:
                                      @"push", kGAICampaignSource,
                                      @"referrer",kGAICampaignMedium,
                                      campaignName, kGAICampaignName,
                                      @"ad_variation1",kGAICampaignContent,
                                      @"keyword",kGAICampaignKeyword,
                                      @"1",kGAICampaignId, nil];
        
        [[RIGoogleAnalyticsTracker sharedInstance] trackCampaignWithDictionay:campaignData];
    }
    
    if (notification != nil && [notification objectForKey:@"u"] != nil)
    {
        UINavigationController *navigationController = [self getNavigationController];
        UIStoryboard *storyboard = [self getCurrentStoryBoard];
        BOOL iPadInterface = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? YES : NO;
        
        NSString *urlString = [notification objectForKey:@"u"];
        NSString *forthLetter = @"";
        NSString *cartPositionString = @"";

        if ([urlString length] >= 7)
        {
            cartPositionString = [urlString substringWithRange:NSMakeRange(3, 4)];
        }
        
        if ([urlString length] >= 4)
        {
            forthLetter = [urlString substringWithRange:NSMakeRange(3, 1)];
        }
        
        if (VALID(navigationController, UINavigationController))
        {
            if ([forthLetter isEqualToString:@""])
            {
                [self pushHomeViewControllerWithNavigationController:navigationController
                                                       andStoryboard:storyboard
                                                    andiPadInterface:iPadInterface];
            } //else if ([forthLetter isEqualToString:@"d"]) {
//                [self pushProductDetailViewControllerWithNavigationController:navigationController
//                                                                andStoryboard:storyboard
//                                                             andiPadInterface:iPadInterface
//                                                                 andURLString:urlString];
//            } else if ([forthLetter isEqualToString:@"c"]) {
//                [self pushCatalogViewControllerWithNavigationController:navigationController
//                                                          andStoryboard:storyboard
//                                                       andiPadInterface:iPadInterface
//                                                           andURLString:urlString];
//            } else if ([forthLetter isEqualToString:@"l"]) {
//                [self pushLoginViewControllerWithNavigationController:navigationController
//                                                        andStoryboard:storyboard
//                                                     andiPadInterface:iPadInterface];
//                
//            } else if ([forthLetter isEqualToString:@"r"]) {
//                [self pushRegistrationViewControllerWithNavigationController:navigationController
//                                                               andStoryboard:storyboard
//                                                            andiPadInterface:iPadInterface];
//            }
        }
    }
}

- (void)handlePushNotificationWithOpenURL:(NSURL *)url
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
        if ([facebookSchema isEqualToString:urlScheme])
        {
            UINavigationController *navigationController = [self getNavigationController];
            UIStoryboard *storyboard = [self getCurrentStoryBoard];
            BOOL iPadInterface = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? YES : NO;
            
            [self pushHomeViewControllerWithNavigationController:navigationController
                                                   andStoryboard:storyboard
                                                andiPadInterface:iPadInterface];
            
            return;
        }
        
        NSString *path = [NSString stringWithString:url.path];
        NSString *urlHost = [NSString stringWithString:url.host];
        NSString *urlQuery = nil;
        
        if (url.query != nil) {
            if ([url.query length] >= 5) {
                if (![[url.query substringToIndex:4] isEqualToString:@"ADXID"]) {
                    NSRange range = [url.query rangeOfString:@"?ADXID"];
                    if (range.location != NSNotFound) {
                        NSString *paramsWithoutAdXData = [url.query substringToIndex:range.location];
                        urlQuery = [NSString stringWithFormat:@"?%@",paramsWithoutAdXData];
                        path = [url.path stringByAppendingString:urlQuery];
                    } else {
                        urlQuery = [NSString stringWithFormat:@"?%@",url.query];
                        path = [url.path stringByAppendingString:urlQuery];
                    }
                }
            }
        }
        
        if (![urlHost isEqualToString:@"com.jumia.ios.dev"])
        {
            path = [urlHost stringByAppendingString:path];
        }
        else
        {
            path = [path substringFromIndex:1];
        }
        
        NSDictionary *dict = [self parseQueryString:[url query]];
        
        NSMutableDictionary *urlDictionary = [NSMutableDictionary dictionaryWithObject:path forKey:@"u"];
        
        NSString *temp = [dict objectForKey:@"UTM"];
        
        if (temp)
        {
            [urlDictionary addEntriesFromDictionary:dict];
        }
        
        [self handleNotificationWithDictionary:urlDictionary];
    }
}

#pragma mark - Push view controllers

- (void)pushHomeViewControllerWithNavigationController:(UINavigationController *)navigationController
                                         andStoryboard:(UIStoryboard *)storyboard
                                      andiPadInterface:(BOOL)iPadInterface
{
    JAHomeViewController *homeViewController = [storyboard instantiateViewControllerWithIdentifier:@"homeViewController"];
    
    [navigationController setViewControllers:@[homeViewController]
                                    animated:YES];
}

#pragma mark - Auxiliar methods

- (UINavigationController *)getNavigationController
{
    JAAppDelegate *appDelegate = (JAAppDelegate *)[[UIApplication sharedApplication] delegate];
    UINavigationController *tempNavController = (UINavigationController *)appDelegate.window.rootViewController;
    
    return tempNavController;
}

- (UIStoryboard *)getCurrentStoryBoard
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return [UIStoryboard storyboardWithName:@"Main_iPad" bundle:nil];
    } else {
        return [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
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

@end
