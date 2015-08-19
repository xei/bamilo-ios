//
//  RIImage.m
//  Comunication Project
//
//  Created by Telmo Pinto on 17/07/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "RIImage.h"
#import "RIProduct.h"
#import "RIVariation.h"


@implementation RIImage

@dynamic format;
@dynamic height;
@dynamic url;
@dynamic width;
@dynamic product;
@dynamic variation;

+ (RIImage*)parseImage:(NSDictionary*)image;
{
    RIImage* newImage = (RIImage*)[[RIDataBaseWrapper sharedInstance] temporaryManagedObjectOfType:NSStringFromClass([RIImage class])];
    
    if ([image objectForKey:@"url"]) {
        newImage.url = [image objectForKey:@"url"];
    }
    if ([image objectForKey:@"path"]) {
        newImage.url = [image objectForKey:@"path"];
    }
    if ([image objectForKey:@"image"]) {
        newImage.url = [image objectForKey:@"image"];
    }
    
    if ([image objectForKey:@"format"]) {
        newImage.format = [image objectForKey:@"format"];
    }
    
    if ([image objectForKey:@"width"]) {
        newImage.width = [image objectForKey:@"width"];
    }
    
    if ([image objectForKey:@"height"]) {
        newImage.height = [image objectForKey:@"height"];
    }
    
    return newImage;
}

+ (void)saveImage:(RIImage*)image andContext:(BOOL)save
{
    if (VALID_NOTEMPTY(image.variation, RIVariation)) {
        [RIVariation saveVariation:image.variation andContext:NO];
    }
    
    [[RIDataBaseWrapper sharedInstance] insertManagedObject:image];
    if (save) {
        [[RIDataBaseWrapper sharedInstance] saveContext];
    }
    
}

@end

