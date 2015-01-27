//
//  RISeller.m
//  Jumia
//
//  Created by Telmo Pinto on 21/01/15.
//  Copyright (c) 2015 Rocket Internet. All rights reserved.
//

#import "RISeller.h"
#import "RIProduct.h"


@implementation RISeller

@dynamic name;
@dynamic url;
@dynamic minDeliveryTime;
@dynamic maxDeliveryTime;
@dynamic reviewAverage;
@dynamic reviewTotal;
@dynamic product;


+ (RISeller*)parseSeller:(NSDictionary*)sellerJSON
{
    RISeller* newSeller = (RISeller*)[[RIDataBaseWrapper sharedInstance] temporaryManagedObjectOfType:NSStringFromClass([RISeller class])];
    
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
        newSeller.minDeliveryTime = [sellerJSON objectForKey:@"max_delivery_time"];
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

#pragma mark - Save method

+ (void)saveSeller:(RISeller*)seller
{
    [[RIDataBaseWrapper sharedInstance] insertManagedObject:seller];
    [[RIDataBaseWrapper sharedInstance] saveContext];
}

@end
