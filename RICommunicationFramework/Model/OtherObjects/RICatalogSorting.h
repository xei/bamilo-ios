//
//  RICatalogSorting.h
//  Jumia
//
//  Created by Jose Mota on 27/05/16.
//  Copyright © 2016 Rocket Internet. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RICatalogSorting : NSObject

/*
 * IMPORTANT NOTICE
 * If the order of the catalog sorting changes,
 * we've to change it in the push notifications as well
 */
typedef NS_ENUM(NSInteger, RICatalogSortingEnum) {
    RICatalogSortingRating = 0,
    RICatalogSortingPopularity,
    RICatalogSortingNewest,
    RICatalogSortingPriceUp,
    RICatalogSortingPriceDown,
    RICatalogSortingName,
    RICatalogSortingBrand
};

+ (NSString*)urlComponentForSortingMethod:(RICatalogSortingEnum)sortingMethod;

+ (NSString*)sortingName:(RICatalogSortingEnum)sortingMethod;
+ (RICatalogSortingEnum)sortingEnum:(NSString *)sort;

@end
