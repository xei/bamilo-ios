//
//  RIVariation.m
//  Comunication Project
//
//  Created by Telmo Pinto on 17/07/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "RIVariation.h"
#import "RIImage.h"
#import "RIProduct.h"


@implementation RIVariation

@synthesize brand;
@synthesize name;
@synthesize price;
@synthesize specialPrice;
@synthesize sku;
@synthesize image;
@synthesize shop_first;

+ (RIVariation *)parseVariation:(NSDictionary*)variation;
{
    RIVariation* newVariation = [[RIVariation alloc] init];
    
    if ([variation objectForKey:@"brand"]) {
        newVariation.brand = [variation objectForKey:@"brand"];
    }
    if ([variation objectForKey:@"name"]) {
        newVariation.name = [variation objectForKey:@"name"];
    }
    if ([variation objectForKey:@"special_price"]) {
        newVariation.specialPrice = [NSNumber numberWithLong:[[variation objectForKey:@"special_price"] longLongValue]];
    }
    else newVariation.specialPrice = nil;
    
    if (VALID_NOTEMPTY([variation objectForKey:@"price"], NSString)) {
        newVariation.price = [NSNumber numberWithLong:[[variation objectForKey:@"price"] longLongValue]];
    }
    
    if ([variation objectForKey:@"sku"]) {
        newVariation.sku = [variation objectForKey:@"sku"];
    }
    if ([variation objectForKey:@"image"]) {
        
        RIImage* image = [RIImage parseImage:variation];
        newVariation.image = image;
    }
    
    if ([variation objectForKey:@"shop_first"]) {
        newVariation.shop_first = (BOOL)[variation objectForKey:@"shop_first"];
    }
    
    return newVariation;
}

@end
