//
//  RITeaserImage.m
//  Comunication Project
//
//  Created by Miguel Chaves on 22/Jul/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "RITeaserImage.h"
#import "RITeaser.h"


@implementation RITeaserImage

@dynamic deviceType;
@dynamic imageUrl;
@dynamic url;
@dynamic teaserDescription;
@dynamic teaser;

+ (RITeaserImage *)parseTeaserImage:(NSDictionary *)json
{
    RITeaserImage *newImage = (RITeaserImage*)[[RIDataBaseWrapper sharedInstance] temporaryManagedObjectOfType:NSStringFromClass([RITeaserImage class])];
    
    if ([json objectForKey:@"image_url"]) {
        newImage.imageUrl = [json objectForKey:@"image_url"];
    } else if ([json objectForKey:@"path"]) {
        newImage.imageUrl = [json objectForKey:@"path"];
    }
    
    if ([json objectForKey:@"product_url"]) {
        newImage.url = [json objectForKey:@"product_url"];
    } else if ([json objectForKey:@"brand_url"]) {
        newImage.url = [json objectForKey:@"brand_url"];
    }
    
    if ([json objectForKey:@"device_type"]) {
        newImage.deviceType = [json objectForKey:@"device_type"];
    }
    
    if ([json objectForKey:@"description"]) {
        newImage.teaserDescription = [json objectForKey:@"description"];
    }
    
    return newImage;
}

+ (void)saveTeaserImage:(RITeaserImage *)image
{
    [[RIDataBaseWrapper sharedInstance] insertManagedObject:image];
    [[RIDataBaseWrapper sharedInstance] saveContext];
}

@end
