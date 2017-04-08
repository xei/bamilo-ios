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

#pragma mark - Overrides
+(NSString *)name {
    return @"Search";
}

+(NSMutableDictionary *)attributes {
    NSMutableDictionary *attributes = [super attributes];
    
    return attributes;
}

@end
