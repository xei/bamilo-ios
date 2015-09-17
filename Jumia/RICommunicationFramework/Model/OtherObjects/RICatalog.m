//
//  RICatalog.m
//  Jumia
//
//  Created by josemota on 9/16/15.
//  Copyright (c) 2015 Rocket Internet. All rights reserved.
//

#import "RICatalog.h"
#import "RIFilter.h"
#import "RIProduct.h"

@implementation RICatalog

+ (RICatalog *)parseCatalog:(NSDictionary *)catalogDictionary forCountryConfiguration:(RICountryConfiguration *)configuration
{
    RICatalog* newCatalog = [[RICatalog alloc] init];
    
    NSArray* filtersJSON = [catalogDictionary objectForKey:@"filters"];
    
    if (VALID_NOTEMPTY(filtersJSON, NSArray)) {
        
        newCatalog.filters = [RIFilter parseFilters:filtersJSON];
        
    }
    
    NSDictionary *bannerJSON = [catalogDictionary objectForKey:@"banner"];
    
    if(VALID_NOTEMPTY(bannerJSON, NSDictionary))
    {
        newCatalog.banner = [RIBanner parseBanner:bannerJSON];
    }
    
    if (VALID_NOTEMPTY([catalogDictionary objectForKey:@"title"], NSString)) {
        newCatalog.title = [catalogDictionary objectForKey:@"title"];
    }
    
    NSArray* categoriesArray = [NSArray new];
    if (VALID_NOTEMPTY([catalogDictionary objectForKey:@"categories"], NSString)) {
        categoriesArray = [[catalogDictionary objectForKey:@"categories"] componentsSeparatedByString:@","];
    }
    
    newCatalog.totalProducts = [catalogDictionary objectForKey:@"total_products"];
    
    NSArray* results = [catalogDictionary objectForKey:@"results"];
    
    if (VALID_NOTEMPTY(results, NSArray)) {
        
        NSMutableArray* products = [NSMutableArray new];
        
        for (NSDictionary* productJSON in results) {
            
            RIProduct* product = [RIProduct parseProduct:productJSON country:configuration];
            [products addObject:product];
        }
        
        newCatalog.products = [products copy];
    }
    
    return newCatalog;
}

@end
