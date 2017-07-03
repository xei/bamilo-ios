//
//  EventFactory.m
//  Bamilo
//
//  Created by Narbeh Mirzaei on 4/8/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "EventFactory.h"

@implementation EventFactory

+(NSDictionary *)login:(NSString *)loginMethod success:(BOOL)success {
    NSMutableDictionary *attributes = [LoginEvent attributes];
    
    [attributes setObject:loginMethod forKey:kEventMethod];
    [attributes setObject:@(success) forKey:kEventSuccess];
    
    return attributes;
}

+(NSDictionary *)signup:(NSString *)signupMethod success:(BOOL)success {
    NSMutableDictionary *attributes = [SignUpEvent attributes];
    
    [attributes setObject:signupMethod forKey:kEventMethod];
    [attributes setObject:@(success) forKey:kEventSuccess];
    
    return attributes;
}

+(NSDictionary *)logout:(BOOL)success {
    NSMutableDictionary *attributes = [LogoutEvent attributes];
    
    [attributes setObject:@(success) forKey:kEventSuccess];
    
    return attributes;
}

+(NSDictionary *)openApp:(OpenAppEventSourceType)source {
    NSMutableDictionary *attributes = [OpenAppEvent attributes];
    
    switch (source) {
        //DIRECT
        case OPEN_APP_SOURCE_DIRECT:
            [attributes setObject:@"direct" forKey:kEventSource];
        break;
            
        //DEEPLINK
        case OPEN_APP_SOURCE_DEEPLINK:
            [attributes setObject:@"deeplink" forKey:kEventSource];
        break;
        
        //PUSH NOTIFICATION
        case OPEN_APP_SOURCE_PUSH_NOTIFICATION:
            [attributes setObject:@"push_notification" forKey:kEventSource];
        break;
            
        //NONE
        default:
            break;
    }
    
    return attributes;
}

+(NSDictionary *)addToFavorites:(NSString *)categoryUrlKey success:(BOOL)success {
    NSMutableDictionary *attributes = [AddToFavoritesEvent attributes];
    
    [attributes setObject:categoryUrlKey ?: cUNKNOWN_EVENT_VALUE forKey:kEventCategoryUrlKey];
    [attributes setObject:@(success) forKey:kEventSuccess];
    
    return attributes;
}

+(NSDictionary *)addToCart:(NSString *)sku basketValue:(long)basketValue success:(BOOL)success {
    NSMutableDictionary *attributes = [AddToCartEvent attributes];
    
    [attributes setObject:sku ?: cUNKNOWN_EVENT_VALUE forKey:kEventSKU];
    [attributes setObject:@(basketValue) ?: cUNKNOWN_EVENT_VALUE forKey:kEventBasketValue];
    [attributes setObject:@(success) forKey:kEventSuccess];
    
    return attributes;
}

+(NSDictionary *)purchase:(NSString *)categories basketValue:(long)basketValue success:(BOOL)success {
    NSMutableDictionary *attributes = [PurchaseEvent attributes];

    [attributes setObject:categories ?: cUNKNOWN_EVENT_VALUE forKey:kEventCategories];
    [attributes setObject:@(basketValue) ?: cUNKNOWN_EVENT_VALUE forKey:kEventBasketValue];
    [attributes setObject:@(success) forKey:kEventSuccess];
    
    return attributes;
}

+(NSDictionary *)search:(NSString *)categoryUrlKey keywords:(NSString *)keywords {
    NSMutableDictionary *attributes = [SearchEvent attributes];
    
    [attributes setObject:categoryUrlKey ?: cUNKNOWN_EVENT_VALUE forKey:kEventCategoryUrlKey];
    [attributes setObject:keywords ?: cUNKNOWN_EVENT_VALUE forKey:kEventKeywords];
    
    return attributes;
}

+(NSDictionary *)viewProduct:(NSString *)categoryUrlKey price:(long)price {
    NSMutableDictionary *attributes = [ViewProductEvent attributes];
    
    [attributes setObject:categoryUrlKey ?: cUNKNOWN_EVENT_VALUE forKey:kEventCategoryUrlKey];
    [attributes setObject:@(price) ?: cUNKNOWN_EVENT_VALUE forKey:kEventPrice];
    
    return attributes;
}

+(NSDictionary *) tapRecommectionInScreenName:(NSString *)screenName logic:(NSString *)logic {
    NSMutableDictionary *attributes = [TapRecommendationEvent attributes];
    
    [attributes setObject:@"Emarsys" forKey:kGAEventCategory];
    [attributes setObject:@"click" forKey:kGAEventActionName];
    [attributes setObject:[NSString stringWithFormat:@"%@ %@", screenName, logic] forKey:kGAEventLabel];
    
    return attributes;
}

@end
