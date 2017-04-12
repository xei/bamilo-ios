//
//  BaseSearchFilterItem.m
//  Bamilo
//
//  Created by Ali Saeedifar on 3/5/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "BaseSearchFilterItem.h"
#import "SearchFilterItem.h"
#import "SearchPriceFilter.h"

@implementation BaseSearchFilterItem
+ (NSString *)urlWithFiltersArray:(NSArray<BaseSearchFilterItem*>*)filtersArray {
    __block NSString* urlString = @"";
    [filtersArray enumerateObjectsUsingBlock:^(BaseSearchFilterItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *stringForFilter = [BaseSearchFilterItem urlWithFilter:obj];
        if (stringForFilter.length) {
            urlString = [NSString stringWithFormat:@"%@/%@", urlString, stringForFilter];
        }
    }];
    return urlString;
}

+ (NSString *)urlWithFilter:(BaseSearchFilterItem*)filter {
    NSString* urlString = nil;
    if (filter.uid.length) {
        if ([filter isKindOfClass:[SearchPriceFilter class]]) {
            SearchPriceFilter* priceFilter = (SearchPriceFilter*)filter;
                if (priceFilter.lowerValue != priceFilter.minPrice || priceFilter.upperValue != priceFilter.maxPrice) {
                    urlString = [NSString stringWithFormat:@"price/%ld%@%ld", (long)priceFilter.lowerValue, filter.filterSeparator, (long)priceFilter.upperValue];
                }
                if (priceFilter.discountOnly) {
                    if (urlString.length) {
                        urlString = [NSString stringWithFormat:@"%@/special_price/1", urlString];
                    } else {
                        urlString = @"special_price/1";
                    }
                }

        } else {
            for (SearchFilterItemOption* filterOption in ((SearchFilterItem *)filter).options) {
                if (filterOption.selected) {
                    if (!urlString) {
                        urlString = [NSString stringWithFormat:@"%@/%@", filter.uid, filterOption.value];
                    } else {
                        urlString = [NSString stringWithFormat:@"%@%@%@", urlString, filter.filterSeparator, filterOption.value];
                    }
                }
            }
        }
    }
    
    return urlString;
}
@end
