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

+(NSMutableDictionary *)attributes {
    NSMutableDictionary *attributes = [super attributes];
    
    [attributes setObject:[RICustomer getCustomerId] forKey:kEventLabel];
    [attributes setObject:@"Search" forKey:kEventAction];
    [attributes setObject:@"Catalog" forKey:kEventCategory];
    [attributes setObject:[RICustomer getCustomerGender] ?: cUNKNOWN_EVENT_VALUE forKey:kEventUserGender];
    
    return attributes;
}

+(NSString *)name {
    return @"Search";
}

@end
