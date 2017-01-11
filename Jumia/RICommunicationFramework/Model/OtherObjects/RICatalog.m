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

+ (RICatalog *)parseCatalog:(NSDictionary *)catalogDictionary forCountryConfiguration:(RICountryConfiguration *)configuration {
    RICatalog* newCatalog = [[RICatalog alloc] init];
    
    NSArray* filtersJSON = [catalogDictionary objectForKey:@"filters"];
    
    if (filtersJSON.count) {
        newCatalog.filters = [RIFilter parseFilters:filtersJSON];
    }
    
    NSDictionary *bannerJSON = [catalogDictionary objectForKey:@"banner"];
    
    if(bannerJSON) {
        newCatalog.banner = [RIBanner parseBanner:bannerJSON];
    }
    
    if ([[catalogDictionary objectForKey:@"title"] length]) {
        newCatalog.title = [catalogDictionary objectForKey:@"title"];
    }
    
    //_UNS
//    NSArray* categoriesArray = [NSArray new];
//    if (VALID_NOTEMPTY([catalogDictionary objectForKey:@"categories"], NSString)) {
//        categoriesArray = [[catalogDictionary objectForKey:@"categories"] componentsSeparatedByString:@","];
//    }
    
    newCatalog.totalProducts = [catalogDictionary objectForKey:@"total_products"];
    
    NSArray* results = [catalogDictionary objectForKey:@"results"];
    
    if (results.count) {
        
        NSMutableArray* products = [NSMutableArray new];
        
        for (NSDictionary* productJSON in results) {
            
            RIProduct* product = [RIProduct parseProduct:productJSON country:configuration];
            [products addObject:product];
        }
        
        newCatalog.products = [products copy];
    }
    
    newCatalog.sort = VALID_NOTEMPTY_VALUE([catalogDictionary objectForKey:@"sort"], NSString);
    
    return newCatalog;
}

@end
