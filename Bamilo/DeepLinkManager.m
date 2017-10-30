//
//  DeepLinkManager.m
//  Bamilo
//
//  Created by Ali Saeedifar on 3/25/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "DeepLinkManager.h"
#import "ThreadManager.h"
#import "URLUtility.h"
#import "Bamilo-Swift.h"
#import "JAExternalPaymentsViewController.h"


static NSMutableArray<NSURL *> *deepLinkPipe;
static BOOL isListenersReady;


@implementation DeepLinkManager

+ (void)handleUrl:(NSURL *)url {
    
    if (!isListenersReady) {
        [DeepLinkManager addToQueue:url];
        return;
    }
    
    if (url.scheme) {
    
        NSDictionary *queryDictionary = [URLUtility parseQueryString:url];
        
        if ([queryDictionary objectForKey:kUTMSource] ||
            [queryDictionary objectForKey:kUTMMedium] ||
            [queryDictionary objectForKey:kUTMCampaign] ||
            [queryDictionary objectForKey:kUTMTerm] ||
            [queryDictionary objectForKey:kUTMContent]) {
            [[GoogleAnalyticsTracker sharedTracker] trackCampaignDataWithCampaignDictionary:queryDictionary];
        }
        
        NSArray *pathComponents = [[url.path componentsSeparatedByString:@"/"] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"length > 0"]];
        if (!pathComponents.count) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kShowHomeScreenNotification object:nil];
            return;
        }
        
        NSString *targetKey = [pathComponents objectAtIndex:0];
        NSString *argument = pathComponents.count > 1 ? [pathComponents objectAtIndex:1] : nil;
        NSMutableString *filterString = [NSMutableString new];
        if(queryDictionary && queryDictionary.allKeys.count) {
            for(NSString *urlQueryKey in queryDictionary) {
                [filterString appendFormat:@"%@/%@/", urlQueryKey, [queryDictionary objectForKey:urlQueryKey]];
            }
        }
        
        if ([DeepLinkManager searchWithTarget:targetKey argument:argument filter:filterString] ||
            [DeepLinkManager sellerPageWithTargetKey:targetKey argument:argument] ||
            [DeepLinkManager specialViewWithTarget:targetKey]) {
            return;
        }
        
        // ---- handle some special views with special params ----
        if ([targetKey isEqualToString:@"d"] && argument.length) {
            // PDV - bamilo://ir/d/BL683ELACCDPNGAMZ?size=1
            NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithDictionary:@{@"sku": argument, @"show_back_button" :@(NO)}];
            if([queryDictionary objectForKey:@"size"]) {
                [userInfo setObject:[queryDictionary objectForKey:@"size"] forKey:@"size"];
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:kDidSelectTeaserWithPDVUrlNofication object:nil userInfo:userInfo];
        } else if ([targetKey isEqualToString:@"s"] && argument.length) {
            // Catalog view - search term
            [[NSNotificationCenter defaultCenter] postNotificationName:kMenuDidSelectOptionNotification object:@{ @"index": @(99), @"name": STRING_SEARCH, @"text": argument }];
        } else if ([targetKey isEqualToString:@"externalPayment"]) {
            // externalPayment - bamilo://ir/externalPayment?orderNum=<OrderNumber>&success=<BOOL>
            if ([[MainTabBarViewController topViewController] isKindOfClass:[JAExternalPaymentsViewController class]]) {
                RICart *cart = ((JAExternalPaymentsViewController *)[MainTabBarViewController topViewController]).cart;
                if (cart && [queryDictionary objectForKey:@"orderNum"] && [queryDictionary objectForKey:@"success"]) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:kShowCheckoutThanksScreenNotification object:nil userInfo:@{@"order_number": [queryDictionary objectForKey:@"orderNum"], kCart: cart, @"success": [queryDictionary objectForKey:@"success"]}];
                }
            }
        }
    }
}

+ (BOOL)specialViewWithTarget:(NSString *)targetKey {
    NSDictionary *targetKeyToNotificationMap = @{
                                                 kCart  : kOpenCartNotification,
                                                 @"w"   : kShowSavedListScreenNotification,
                                                 @"o"   : kShowMyOrdersScreenNotification,
                                                 @"l"   : kShowAuthenticationScreenNotification,
                                                 @"r"   : kShowSignUpScreenNotification,
                                                 @"rv"  : kShowRecentlyViewedScreenNotification,
                                                 @"rc"  : kShowRecentSearchesScreenNotification,
                                                 @"news": kShowEmailNotificationsScreenNotification
                                                 };
    
    if ([targetKeyToNotificationMap objectForKey:targetKey]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:[targetKeyToNotificationMap objectForKey:targetKey] object:nil];
        return YES;
    }
    return NO;
}

+ (BOOL)sellerPageWithTargetKey:(NSString *)targetKey argument:(NSString *)argument {
    NSMutableDictionary* categoryDictionary = [NSMutableDictionary new];
    
    if (argument.length) {
        [categoryDictionary setObject:argument forKey:@"category_url_key"];
    }
    
    NSDictionary *sortingMap = @{
                                 @"scbr" : @"BEST_RATING",  //best rating
                                 @"scp"  : @"POPULARITY",   //popularity
                                 @"scin" : @"NEW_IN",       //new items
                                 @"scpu" : @"PRICE_UP",     //price up
                                 @"scpd" : @"PRICE_DOWN",   //price down
                                 @"scn"  : @"NAME",         //name
                                 @"scb"  : @"BRAND"         //brand
                                 };
    
    if ([sortingMap objectForKey:targetKey] && argument.length) {
        [categoryDictionary setObject:[sortingMap objectForKey:targetKey] forKey:@"sorting"];
        [[NSNotificationCenter defaultCenter] postNotificationName:kOpenSellerPage object:categoryDictionary];
        return YES;
    }
    
    return NO;
}

+ (BOOL)searchWithTarget:(NSString *)targetKey argument:(NSString *)argument filter:(NSString *)filter {
    BOOL successfullyHandled = NO;
    
    NSMutableDictionary* categoryDictionary = [NSMutableDictionary new];
    if (argument.length) {
        [categoryDictionary setObject:argument forKey:@"category_url_key"];
    }
    
    if (filter.length) {
        [categoryDictionary setObject:filter forKey:@"filter"];
    }
    
    NSDictionary *sortingMap = @{
                                 @"cbr" : @"BEST_RATING",  //best rating
                                 @"cp"  : @"POPULARITY",   //popularity
                                 @"cin" : @"NEW_IN",       //new items
                                 @"cpu" : @"PRICE_UP",     //price up
                                 @"cpd" : @"PRICE_DOWN",   //price down
                                 @"cn"  : @"NAME",         //name
                                 @"cb"  : @"BRAND"         //brand
                                 };
    
    if ([targetKey isEqualToString:@"c"] && argument.length) {
        // Catalog view - category url
        // Do nothing more, everyThing is fine
        successfullyHandled = YES;
    } else if ([sortingMap objectForKey:targetKey] && argument.length) {
        [categoryDictionary setObject:[sortingMap objectForKey:targetKey] forKey:@"sorting"];
        successfullyHandled = YES;
    }

    if (successfullyHandled) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kMenuDidSelectLeafCategoryNotification object:categoryDictionary];
        return YES;
    }
    
    return NO;
}


+ (void)addToQueue:(NSURL *)url {
    if (!deepLinkPipe) {
        deepLinkPipe = [[NSMutableArray alloc] init];
    }
    
    [deepLinkPipe insertObject:url atIndex:0];
}

+ (void)listenersReady {
    isListenersReady = YES;
    [DeepLinkManager popAndPerform];
}

+ (void)popAndPerform {
    NSURL *target = [deepLinkPipe lastObject];
    if (target) {
        [deepLinkPipe removeLastObject];
        [DeepLinkManager handleUrl:target];
    }
}

@end
