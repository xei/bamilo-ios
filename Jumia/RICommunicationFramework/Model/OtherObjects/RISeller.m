//
//  RISeller.m
//  Jumia
//
//  Created by Telmo Pinto on 20/08/15.
//  Copyright (c) 2015 Rocket Internet. All rights reserved.
//

#import "RISeller.h"

@implementation RISeller

+ (RISeller*)parseSeller:(NSDictionary*)sellerJSON
{
    RISeller* newSeller = [[RISeller alloc] init];
    
    if ([sellerJSON objectForKey:@"id"]) {
        newSeller.uid = [sellerJSON objectForKey:@"id"];
    }
    if ([sellerJSON objectForKey:@"name"]) {
        newSeller.name = [sellerJSON objectForKey:@"name"];
    }
    if ([sellerJSON objectForKey:@"url"]) {
        newSeller.url = [sellerJSON objectForKey:@"url"];
    }
    if ([sellerJSON objectForKey:@"min_delivery_time"]) {
        newSeller.minDeliveryTime = [sellerJSON objectForKey:@"min_delivery_time"];
    }
    if ([sellerJSON objectForKey:@"max_delivery_time"]) {
        newSeller.maxDeliveryTime = [sellerJSON objectForKey:@"max_delivery_time"];
    }
    if ([sellerJSON objectForKey:@"is_global"]) {
        newSeller.isGlobal = ((NSNumber *)[sellerJSON objectForKey:@"is_global"]).boolValue;
    }
    
    if ([sellerJSON objectForKey:@"reviews"]) {
        NSDictionary *reviewsDic = [sellerJSON objectForKey:@"reviews"];
        if (VALID_NOTEMPTY(reviewsDic, NSDictionary)) {
            if (VALID_NOTEMPTY([reviewsDic objectForKey:@"average"], NSNumber)) {
                newSeller.reviewAverage = [reviewsDic objectForKey:@"average"];
            }
            if (VALID_NOTEMPTY([reviewsDic objectForKey:@"total"], NSNumber)) {
                newSeller.reviewTotal = [reviewsDic objectForKey:@"total"];
            }
        }
    }
    
    return newSeller;
}

@end
