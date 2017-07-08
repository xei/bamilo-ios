//
//  EmarsysBaseTracker.m
//  Bamilo
//
//  Created by Ali Saeedifar on 7/8/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "EmarsysBaseTracker.h"
#import "EmailUtility.h"
#import "EventUtilities.h"
#import "Bamilo-Swift.h"

@interface EmarsysBaseTracker()<EventTrackerProtocol>

@end

@implementation EmarsysBaseTracker

- (void)postEventByName:(NSString *)eventName attributes:(NSDictionary *)attributes {
    return;
}

#pragma mark - EventTrackerProtocol
- (void)loginWithAttributes:(NSDictionary<NSString *,id> *)attributes {
    NSMutableDictionary *dict = [self extractCommonAttributes:attributes];
    RICustomer *user = attributes[kEventUser];
    if(user) {
        //Email Domain
        NSArray *userEmailDomainComponents = [EmailUtility getEmailDomain:user.email];
        if(userEmailDomainComponents) {
            [dict setObject:userEmailDomainComponents[0] forKey:kEventEmailDomain]; //gmail
        }
    }
    dict[kEventMethod] = attributes[kEventMethod];
    dict[kEventSuccess] = attributes[kEventSuccess];
    [self postEventByName:@"Login" attributes:[dict copy]];
}

- (void)logoutWithAttributes:(NSDictionary<NSString *,id> *)attributes {
    [self postEventByName:@"Logout" attributes:attributes];
}

- (void)signupWithAttributes:(NSDictionary<NSString *,id> *)attributes {
    NSMutableDictionary *dict = [self extractCommonAttributes:attributes];
    RICustomer *user = attributes[kEventUser];
    if(user) {
        //Email Domain
        NSArray *userEmailDomainComponents = [EmailUtility getEmailDomain:user.email];
        if(userEmailDomainComponents) {
            [dict setObject:userEmailDomainComponents[0] forKey:kEventEmailDomain]; //gmail
        }
    }
    dict[kEventMethod] = attributes[kEventMethod];
    dict[kEventSuccess] = attributes[kEventSuccess];
    [self postEventByName:@"SignUp" attributes:[dict copy]];
}

- (void)appOpendWithAttributes:(NSDictionary<NSString *,id> *)attributes {
    [self postEventByName:@"OpenApp" attributes:attributes];
}

- (void)addToCartWithAttributes:(NSDictionary<NSString *,id> *)attributes {
    NSMutableDictionary *dict = [self extractCommonAttributes:attributes];
    dict[kEventSKU] = [((RIProduct *)attributes[kEventProduct]) sku] ?: cUNKNOWN_EVENT_VALUE;
    dict[kEventBasketValue] = [((RIProduct *)attributes[kEventProduct]) price] ?: cUNKNOWN_EVENT_VALUE;
    dict[kEventSuccess] = attributes[kEventSuccess];
    [self postEventByName:@"AddToCart" attributes:[dict copy]];
}

- (void)addToWishListWithAttributes:(NSDictionary<NSString *,id> *)attributes {
    NSMutableDictionary *dict = [self extractCommonAttributes:attributes];
    dict[kEventCategoryUrlKey] = [((RIProduct *)attributes[kEventProduct]) categoryUrlKey] ?: cUNKNOWN_EVENT_VALUE;
    [self postEventByName:@"AddToFavorites" attributes:[dict copy]];
}

- (void)purchasedWithAttributes:(NSDictionary<NSString *,id> *)attributes {
    NSMutableDictionary *dict = [self extractCommonAttributes:attributes];
    dict[kEventCategories] = [EventUtilities getEventCategories:attributes[kEventCart]];
    dict[kEventBasketValue] = ((RICart *)attributes[kEventCart]).cartEntity.cartValue;
    dict[kEventSuccess] = attributes[kEventSuccess];
    [self postEventByName:@"Purchase" attributes:[dict copy]];
}

- (void)searchWithAttributes:(NSDictionary<NSString *,id> *)attributes {
    NSMutableDictionary *dict = [self extractCommonAttributes:attributes];
    RITarget *searchTarget = attributes[kEventSearchTarget];
    dict[kEventCategoryUrlKey] = searchTarget.targetType == CATALOG_CATEGORY ? searchTarget.node : cUNKNOWN_EVENT_VALUE;
    dict[kEventKeywords] = searchTarget.targetType == CATALOG_CATEGORY ? searchTarget.node :cUNKNOWN_EVENT_VALUE;
    [self postEventByName:@"Search" attributes:[dict copy]];
}

- (void)viewProductWithAttributes:(NSDictionary<NSString *,id> *)attributes {
    NSMutableDictionary *dict = [self extractCommonAttributes:attributes];
    dict[kEventCategoryUrlKey] = ((RIProduct *)attributes[kEventProduct]).categoryUrlKey ?: cUNKNOWN_EVENT_VALUE;
    dict[kEventPrice] = ((RIProduct *)attributes[kEventProduct]).price ?: cUNKNOWN_EVENT_VALUE;
    [self postEventByName:@"ViewProduct" attributes:[dict copy]];
}


#pragma mark://Helper funcitons
- (NSMutableDictionary *)extractCommonAttributes:(NSDictionary *)attributes {
    return [NSMutableDictionary dictionaryWithDictionary:@{
                                                           kEventAppVersion: attributes[kEventAppVersion],
                                                           kEventPlatform: attributes[kEventPlatform],
                                                           kEventConnection: attributes[kEventConnection],
                                                           kEventDate:  attributes[kEventDate],
                                                           }];
}

@end
