//
//  RITeaserProduct.m
//  Comunication Project
//
//  Created by Miguel Chaves on 22/Jul/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "RITeaserProduct.h"
#import "RITeaser.h"


@implementation RITeaserProduct

@dynamic uid;
@dynamic name;
@dynamic url;
@dynamic brand;
@dynamic maxPrice;
@dynamic price;
@dynamic maxSpecialPrice;
@dynamic specialPrice;
@dynamic maxSavingPercentage;
@dynamic imageUrl;
@dynamic teaser;

+ (RITeaserProduct *)parseTeaserProduct:(NSDictionary *)json
{
    RITeaserProduct *product = (RITeaserProduct*)[[RIDataBaseWrapper sharedInstance] temporaryManagedObjectOfType:NSStringFromClass([RITeaserProduct class])];

    if ([json objectForKey:@"attributes"]) {
        NSDictionary *attributes = [json objectForKey:@"attributes"];
        
        if ([attributes objectForKey:@"sku"]) {
            product.uid = [attributes objectForKey:@"sku"];
        }
        
        if ([attributes objectForKey:@"name"]) {
            product.name = [attributes objectForKey:@"name"];
        }
        
        if ([attributes objectForKey:@"url"]) {
            product.url = [attributes objectForKey:@"url"];
        }
        
        if ([attributes objectForKey:@"brand"]) {
            product.brand = [attributes objectForKey:@"brand"];
        }
        
        if ([attributes objectForKey:@"max_price"]) {
            id tempObj = [attributes objectForKey:@"max_price"];
            
            if (![tempObj isKindOfClass:[NSNull class]]) {
                product.maxPrice = [attributes objectForKey:@"max_price"];
            }
        }
        
        if ([attributes objectForKey:@"price"]) {
            id tempObj = [attributes objectForKey:@"price"];
            
            if (![tempObj isKindOfClass:[NSNull class]]) {
                product.price = [attributes objectForKey:@"price"];
            }
        }
        
        if ([attributes objectForKey:@"max_special_price"]) {
            id tempObj = [attributes objectForKey:@"max_special_price"];
            
            if (![tempObj isKindOfClass:[NSNull class]]) {
                product.maxSpecialPrice = [attributes objectForKey:@"max_special_price"];
            }
        }
        
        if ([attributes objectForKey:@"max_saving_percentage"]) {
            id tempObj = [attributes objectForKey:@"max_saving_percentage"];
            
            if (![tempObj isKindOfClass:[NSNull class]]) {
                product.maxSavingPercentage = [attributes objectForKey:@"max_saving_percentage"];
            }
        }
        
    }
    
    if ([json objectForKey:@"images"]) {
        
        NSArray *imageList = [json objectForKey:@"images"];
        
        if (VALID_NOTEMPTY(imageList, NSArray)) {
            
            NSDictionary* imageDict = [imageList firstObject];
            
            if (VALID_NOTEMPTY(imageDict, NSDictionary) && [imageDict objectForKey:@"path"]) {
                product.imageUrl = [imageDict objectForKey:@"path"];
            }
        }
    }
    
    return product;
}

+ (void)saveTeaserProduct:(RITeaserProduct *)product
{
    [[RIDataBaseWrapper sharedInstance] insertManagedObject:product];
    [[RIDataBaseWrapper sharedInstance] saveContext];
}

@end
