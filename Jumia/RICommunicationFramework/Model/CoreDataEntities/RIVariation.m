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

@dynamic brand;
@dynamic name;
@dynamic price;
@dynamic specialPrice;
@dynamic sku;
@dynamic image;
@dynamic product;

+ (RIVariation *)parseVariation:(NSDictionary*)variation;
{
    RIVariation* newVariation = (RIVariation*)[[RIDataBaseWrapper sharedInstance] temporaryManagedObjectOfType:NSStringFromClass([RIVariation class])];
    
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

+ (void)saveVariation:(RIVariation*)variation andContext:(BOOL)save;
{
    if (variation.image) {
        NSArray *images = [[RIDataBaseWrapper sharedInstance] allEntriesOfType:NSStringFromClass([RIImage class])];
        if (![images containsObject:variation.image]) {
            [[RIDataBaseWrapper sharedInstance] insertManagedObject:variation.image];
        }
    }
    
    [[RIDataBaseWrapper sharedInstance] insertManagedObject:variation];
    if (save) {
        [[RIDataBaseWrapper sharedInstance] saveContext];
    }
    
}

@end
