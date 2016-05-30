//
//  RICatalogSorting.m
//  Jumia
//
//  Created by Jose Mota on 27/05/16.
//  Copyright © 2016 Rocket Internet. All rights reserved.
//

#import "RICatalogSorting.h"

@implementation RICatalogSorting

+ (NSString*)urlComponentForSortingMethod:(RICatalogSortingEnum)sortingMethod
{
    NSString* urlComponent = @"";
    
    switch (sortingMethod) {
        case RICatalogSortingRating:
            urlComponent = @"sort/rating/dir/desc";
            break;
        case RICatalogSortingNewest:
            urlComponent = @"sort/newest/dir/desc";
            break;
        case RICatalogSortingPriceUp:
            urlComponent = @"sort/price/dir/asc";
            break;
        case RICatalogSortingPriceDown:
            urlComponent = @"sort/price/dir/desc";
            break;
        case RICatalogSortingName:
            urlComponent = @"sort/name/dir/asc";
            break;
        case RICatalogSortingBrand:
            urlComponent = @"sort/brand/dir/asc";
            break;
        case RICatalogSortingPopularity:
            urlComponent = @"sort/popularity/dir/desc";
            break;
        default:
            break;
    }
    
    return urlComponent;
}

+ (NSString*)sortingName:(RICatalogSortingEnum)sortingMethod
{
    NSString* sortingName = @"";
    
    switch (sortingMethod) {
        case RICatalogSortingRating:
            sortingName = @"Rating";
            break;
        case RICatalogSortingNewest:
            sortingName = @"Newest";
            break;
        case RICatalogSortingPriceUp:
            sortingName = @"Price up";
            break;
        case RICatalogSortingPriceDown:
            sortingName = @"Price down";
            break;
        case RICatalogSortingName:
            sortingName = @"Name";
            break;
        case RICatalogSortingBrand:
            sortingName = @"Brand";
            break;
        default: //RICatalogSortingPopularity
            sortingName = @"Popularity";
            break;
    }
    
    return sortingName;
}

+ (RICatalogSortingEnum)sortingEnum:(NSString *)sort
{
    if ([sort isEqualToString:@"BEST_RATING"])
    {
        return RICatalogSortingRating;
    }else if ([sort isEqualToString:@"NEW_IN"])
    {
        return RICatalogSortingNewest;
    }else if ([sort isEqualToString:@"PRICE_UP"])
    {
        return RICatalogSortingPriceUp;
    }else if ([sort isEqualToString:@"PRICE_DOWN"])
    {
        return RICatalogSortingPriceDown;
    }else if ([sort isEqualToString:@"NAME"])
    {
        return RICatalogSortingName;
    }else if ([sort isEqualToString:@"BRAND"])
    {
        return RICatalogSortingBrand;
    }
    //    else if ([sort isEqualToString:@"POPULARITY"])
    return RICatalogSortingPopularity;
}

@end
