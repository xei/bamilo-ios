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
@synthesize product;

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
        float f = [[variation objectForKey:@"special_price"] floatValue];
        newVariation.specialPrice = [NSNumber numberWithFloat:f];
    }
    else newVariation.specialPrice = nil;
    
    if (VALID_NOTEMPTY([variation objectForKey:@"price"], NSString)) {
        float f = [[variation objectForKey:@"price"] floatValue];
        newVariation.price = [NSNumber numberWithFloat:f];
    }
    
    if ([variation objectForKey:@"sku"]) {
        newVariation.sku = [variation objectForKey:@"sku"];
    }
    if ([variation objectForKey:@"image"]) {
        
        RIImage* image = [RIImage parseImage:variation];
        image.variation = newVariation;
        newVariation.image = image;
    }
    
    return newVariation;
}

@end
