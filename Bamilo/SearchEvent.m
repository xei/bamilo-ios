//
//  SearchEvent.m
//  Bamilo
//
//  Created by Narbeh Mirzaei on 3/25/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "SearchEvent.h"
#import "RICustomer.h"

@implementation SearchEvent

NSString *const kSearchEventNumberOfProducts = @"SearchEventNumberOfProducts";
NSString *const kSearchEventKeywords = @"SearchEventKeywords";

+(NSMutableDictionary *)event {
    NSMutableDictionary *event = [super event];
    
    [event setObject:[RICustomer getCustomerId] forKey:kEventLabel];
    [event setObject:@"Search" forKey:kEventAction];
    [event setObject:@"Catalog" forKey:kEventCategory];
    [event setObject:[RICustomer getCustomerGender] ?: cUNKNOWN_EVENT_VALUE forKey:kEventUserGender];
    
    return event;
}

+(NSString *)name {
    return @"Search";
}

@end
