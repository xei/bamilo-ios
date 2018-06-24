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
    NSMutableDictionary *dict = [self generateCommonAttributesUsingAttributes:attributes];
    dict[kEventMethod] = attributes[kEventMethod];
    dict[kEventSuccess] = attributes[kEventSuccess];
    [self postEventByName:@"Login" attributes:[dict copy]];
}

- (void)logoutWithAttributes:(NSDictionary<NSString *,id> *)attributes {
    NSMutableDictionary *dict = [self generateCommonAttributesUsingAttributes:attributes];
    [self postEventByName:@"Logout" attributes:[dict copy]];
}

- (void)signupWithAttributes:(NSDictionary<NSString *,id> *)attributes {
    NSMutableDictionary *dict = [self generateCommonAttributesUsingAttributes:attributes];
    dict[kEventMethod] = attributes[kEventMethod];
    dict[kEventSuccess] = attributes[kEventSuccess];
    [self postEventByName:@"SignUp" attributes:[dict copy]];
}

- (void)appOpenedWithAttributes:(NSDictionary<NSString *,id> *)attributes {
    NSMutableDictionary *dict = [self generateCommonAttributesUsingAttributes:attributes];
    [self postEventByName:@"OpenApp" attributes:dict];
}

- (void)addToCartWithAttributes:(NSDictionary<NSString *,id> *)attributes {
    NSMutableDictionary *dict = [self generateCommonAttributesUsingAttributes:attributes];
    Product *product = ((Product *)attributes[kEventProduct]);
    dict[kEventSKU] = product.sku ?: cUNKNOWN_EVENT_VALUE;
    dict[kEventBasketValue] = [product getNSNumberPrice] ?: cUNKNOWN_EVENT_VALUE;
    dict[kEventSuccess] = attributes[kEventSuccess];
    [self postEventByName:@"AddToCart" attributes:[dict copy]];
}

- (void)removeFromCartWithAttributes:(NSDictionary<NSString *,id> *)attributes {
    NSMutableDictionary *dict = [self generateCommonAttributesUsingAttributes:attributes];
    dict[kEventSKU] = [((Product *)attributes[kEventProduct]) sku] ?: cUNKNOWN_EVENT_VALUE;
    [self postEventByName:@"RemoveFromCart" attributes:[dict copy]];
}

- (void)addToWishListWithAttributes:(NSDictionary<NSString *,id> *)attributes {
    NSMutableDictionary *dict = [self generateCommonAttributesUsingAttributes:attributes];
    dict[kEventCategoryUrlKey] = [((RIProduct *)attributes[kEventProduct]) categoryUrlKey] ?: cUNKNOWN_EVENT_VALUE;
    [self postEventByName:@"AddToFavorites" attributes:[dict copy]];
}

- (void)purchasedWithAttributes:(NSDictionary<NSString *,id> *)attributes {
    NSMutableDictionary *dict = [self generateCommonAttributesUsingAttributes:attributes];
    dict[kEventCategories] = [EventUtilities getEventCategories:attributes[kEventCart]];
    dict[kEventBasketValue] = ((RICart *)attributes[kEventCart]).cartEntity.cartValue;
    dict[kEventSuccess] = attributes[kEventSuccess];
    [self postEventByName:@"Purchase" attributes:[dict copy]];
}

- (void)searchWithAttributes:(NSDictionary<NSString *,id> *)attributes {
    NSMutableDictionary *dict = [self generateCommonAttributesUsingAttributes:attributes];
    RITarget *searchTarget = attributes[kEventSearchTarget];
    dict[kEventCategoryUrlKey] = searchTarget.targetType == CATALOG_CATEGORY ? searchTarget.node : cUNKNOWN_EVENT_VALUE;
    dict[kEventKeywords] = searchTarget.targetType == CATALOG_SEARCH ? searchTarget.node :cUNKNOWN_EVENT_VALUE;
    [self postEventByName:@"Search" attributes:[dict copy]];
}

- (void)viewProductWithAttributes:(NSDictionary<NSString *,id> *)attributes {
    NSMutableDictionary *dict = [self generateCommonAttributesUsingAttributes:attributes];
    dict[kEventCategoryUrlKey] = ((RIProduct *)attributes[kEventProduct]).categoryUrlKey ?: cUNKNOWN_EVENT_VALUE;
    dict[kEventPrice] = ((RIProduct *)attributes[kEventProduct]).price ?: cUNKNOWN_EVENT_VALUE;
    [self postEventByName:@"ViewProduct" attributes:[dict copy]];
}


#pragma mark://Helper funcitons
- (NSMutableDictionary *)generateCommonAttributesUsingAttributes:(NSDictionary *)attributes {
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:@{
                                                           kEventAppVersion: attributes[kEventAppVersion],
                                                           kEventPlatform: attributes[kEventPlatform],
                                                           kEventConnection: attributes[kEventConnection],
                                                           kEventDate:  attributes[kEventDate],
                                                           }];
    
    NSString *userEmail = [RICustomer getCurrentCustomer].email;
    if([userEmail length]) {
        NSArray *userEmailDomainComponents = [EmailUtility getEmailDomain:userEmail];
        if(userEmailDomainComponents) {
            [dict setObject:userEmailDomainComponents[0] forKey:kEventEmailDomain]; //gmail
        }
    }
    
    NSString *gender = [RICustomer getCustomerGender];
    if([gender length]) {
        [dict setValue:gender forKey:kEventUserGender];
    }
    
    return dict;
}

@end
