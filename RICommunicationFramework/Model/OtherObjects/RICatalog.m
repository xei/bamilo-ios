//
//  RICatalog.m
//  Jumia
//
//  Created by josemota on 9/16/15.
//  Copyright (c) 2015 Rocket Internet. All rights reserved.
//

#import "RICatalog.h"
#import "SearchPriceFilter.h"
#import "SearchFilterItem.h"
#import "RIProduct.h"

@implementation RICatalog

+ (RICatalog *)parseCatalog:(NSDictionary *)catalogDictionary forCountryConfiguration:(RICountryConfiguration *)configuration {
    RICatalog* newCatalog = [[RICatalog alloc] init];
    
    
    NSArray *filterItemsJSON = [catalogDictionary objectForKey:@"filters"];
    NSMutableArray *newFilters = [NSMutableArray new];
    if (filterItemsJSON.count) {
        [filterItemsJSON enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([[obj objectForKey:@"id"] isEqualToString:@"price"]) {
                SearchPriceFilter *priceFilter = [SearchPriceFilter new];
                [priceFilter mergeFromDictionary:obj useKeyMapping:YES error:nil];
                [newFilters addObject:priceFilter];
                newCatalog.priceFilterIndex = (int)idx;
            } else {
                SearchFilterItem *filterItem = [SearchFilterItem new];
                [filterItem mergeFromDictionary:obj useKeyMapping:YES error:nil];
                [newFilters addObject:filterItem];
            }
        }];
    }
    
    newCatalog.filters = [newFilters copy];
    
    NSDictionary *bannerJSON = [catalogDictionary objectForKey:@"banner"];
    
    if(bannerJSON) {
        newCatalog.banner = [RIBanner parseBanner:bannerJSON];
    }
    
    if ([[catalogDictionary objectForKey:@"title"] length]) {
        newCatalog.title = [catalogDictionary objectForKey:@"title"];
    }

    
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
    
    
    if ([catalogDictionary objectForKey:@"breadcrumb"]) {
        Breadcrumbs *breadcrumbs = [Breadcrumbs new];
        //This action should be refactored when RICatalog has been refactored.
        [breadcrumbs mergeFromDictionary:@{@"items": [catalogDictionary objectForKey:@"breadcrumb"]} useKeyMapping:YES error:nil];
        newCatalog.breadcrumbs = breadcrumbs;
    }
    
    return newCatalog;
}

@end
