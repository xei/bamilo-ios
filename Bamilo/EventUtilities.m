//
//  EventUtilities.m
//  Bamilo
//
//  Created by Narbeh Mirzaei on 4/12/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "EventUtilities.h"
#import "RICartItem.h"

@implementation EventUtilities

+(NSString *)getEventCategories:(RICart *)cart {
    NSMutableArray *categories = [NSMutableArray array];
    
    for(RICartItem *item in cart.cartEntity.cartItems) {
        [categories addObject:item.categoryUrlKey];
    }
    
    return [categories componentsJoinedByString:@","];
}

+(NSString *)getSearchKeywords:(NSString *)query {
    if(query == nil) {
        return nil;
    }
    
    return [[query componentsSeparatedByString:@" "] componentsJoinedByString:@","];
}

@end
