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

+(NSDictionary *)addToFavorites:(NSString *)category {
    NSMutableDictionary *attributes = [AddToFavoritesEvent attributes];
    
    [attributes setObject:category forKey:kEventCategory];
    
    return attributes;
}

+(NSDictionary *)addToCart:(NSString *)category basketValue:(int)basketValue {
    NSMutableDictionary *attributes = [AddToCartEvent attributes];
    
    [attributes setObject:category forKey:kEventCategory];
    [attributes setObject:@(basketValue) forKey:kEventBasketValue];
    
    return attributes;
}

@end
