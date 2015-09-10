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

@dynamic link;
@dynamic sku;
@dynamic image;
@dynamic product;

+ (RIVariation *)parseVariation:(NSDictionary*)variation;
{
    RIVariation* newVariation = (RIVariation*)[[RIDataBaseWrapper sharedInstance] temporaryManagedObjectOfType:NSStringFromClass([RIVariation class])];
    
    if ([variation objectForKey:@"link"]) {
        newVariation.link = [variation objectForKey:@"link"];
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
