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
#import "ViewControllerManager.h"

@implementation DeepLinkManager

+ (void)handleUrl:(NSURL *)url {
    if (url.scheme) {
        //I don't know what the hell is this, but I keep it (`UTM` in queryString!!)
        NSDictionary *queryDictionary = [URLUtility parseQueryString:url];
        if ([queryDictionary valueForKey:@"UTM"]) {
            [[RITrackingWrapper sharedInstance] trackCampaignWithName:[[queryDictionary valueForKey:@"UTM"] objectForKey:@"UTM"]];
        }
            
        NSArray *pathComponents = [[url.path componentsSeparatedByString:@"/"] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"length > 0"]];
        if (!pathComponents.count) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kShowHomeScreenNotification object:nil];
            return;
        }
        NSString *targetKey = [pathComponents objectAtIndex:0];
        NSString *argument = pathComponents.count > 1 ? [pathComponents objectAtIndex:1] : nil;
        NSString *filterString = url.query ? [url.query stringByReplacingOccurrencesOfString:@"=" withString:@"/"] : nil;
        
        
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
            [[NSNotificationCenter defaultCenter] postNotificationName:kMenuDidSelectOptionNotification object:@{@"index": @(99),
                                                                                                                 @"name": STRING_SEARCH,
                                                                                                                 @"text": argument
                                                                                                                 }];
        } else if ([targetKey isEqualToString:@"camp"] && argument.length) {
            [[ViewControllerManager centerViewController] openTargetString:[RITarget getTargetString:CAMPAIGN node:argument]];
        } else if ([targetKey isEqualToString:@"ss"] && argument.length) {
            [[ViewControllerManager centerViewController] openTargetString:[RITarget getTargetString:STATIC_PAGE node:argument]];
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
                                 @"scbr" : @(0), //best rating
                                 @"scp"  : @(1), //popularity
                                 @"scin" : @(2), //new items
                                 @"scpu" : @(3), //price up
                                 @"scpd" : @(4), //price down
                                 @"scn"  : @(5), //name
                                 @"scb"  : @(6)  //brand
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
                                 @"cbr" : @(0), //best rating
                                 @"cp"  : @(1), //popularity
                                 @"cin" : @(2), //new items
                                 @"cpu" : @(3), //price up
                                 @"cpd" : @(4), //price down
                                 @"cn"  : @(5), //name
                                 @"cb"  : @(6)  //brand
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

@end
