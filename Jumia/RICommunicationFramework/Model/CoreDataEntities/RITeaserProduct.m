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

    if ([json objectForKey:@"sku"]) {
        product.uid = [json objectForKey:@"sku"];
    }
    
    if ([json objectForKey:@"name"]) {
        product.name = [json objectForKey:@"name"];
    }
    
    if ([json objectForKey:@"url"]) {
        product.url = [json objectForKey:@"url"];
    }
    
    if ([json objectForKey:@"brand"]) {
        product.brand = [json objectForKey:@"brand"];
    }
    
    if ([json objectForKey:@"max_price"]) {
        id tempObj = [json objectForKey:@"max_price"];
        
        if (![tempObj isKindOfClass:[NSNull class]]) {
            product.maxPrice = [json objectForKey:@"max_price"];
        }
    }
    
    if ([json objectForKey:@"price"]) {
        id tempObj = [json objectForKey:@"price"];
        
        if (![tempObj isKindOfClass:[NSNull class]]) {
            product.price = [json objectForKey:@"price"];
        }
    }
    
    if ([json objectForKey:@"max_special_price"]) {
        id tempObj = [json objectForKey:@"max_special_price"];
        
        if (![tempObj isKindOfClass:[NSNull class]]) {
            product.maxSpecialPrice = [json objectForKey:@"max_special_price"];
        }
    }
    
    if ([json objectForKey:@"max_saving_percentage"]) {
        id tempObj = [json objectForKey:@"max_saving_percentage"];
        
        if (![tempObj isKindOfClass:[NSNull class]]) {
            product.maxSavingPercentage = [json objectForKey:@"max_saving_percentage"];
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
