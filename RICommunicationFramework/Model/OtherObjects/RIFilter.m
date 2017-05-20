//
//  RIFilter.m
//  Jumia
//
//  Created by Telmo Pinto on 12/08/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "RIFilter.h"

@implementation RIFilterOption

+ (RIFilterOption *)parseFilterOption:(NSDictionary *)filterOptionJSON {
    RIFilterOption* newFilterOption = [[RIFilterOption alloc] init];
    
    if (VALID_NOTEMPTY(filterOptionJSON, NSDictionary)) {
        if ([filterOptionJSON objectForKey:@"label"]) {
            newFilterOption.name = [filterOptionJSON objectForKey:@"label"];
        }
        if ([filterOptionJSON objectForKey:@"val"]) {
            newFilterOption.val = [filterOptionJSON objectForKey:@"val"];
        }
        if ([filterOptionJSON objectForKey:@"max"]) {
            NSNumber *max = [filterOptionJSON objectForKey:@"max"];
            newFilterOption.max = [max integerValue];
        }
        if ([filterOptionJSON objectForKey:@"min"]) {
            NSNumber *min = [filterOptionJSON objectForKey:@"min"];
            newFilterOption.min = [min integerValue];
        }
        if ([filterOptionJSON objectForKey:@"interval"]) {
            NSNumber *interval = [filterOptionJSON objectForKey:@"interval"];
            newFilterOption.interval = [interval integerValue];
        }
        if ([filterOptionJSON objectForKey:@"hex_value"]) {
            newFilterOption.colorHexValue = [filterOptionJSON objectForKey:@"hex_value"];
        }
        if ([filterOptionJSON objectForKey:@"image_url"]) {
            newFilterOption.colorImageUrl = [filterOptionJSON objectForKey:@"image_url"];
        }
        if (VALID_NOTEMPTY([filterOptionJSON objectForKey:@"average"], NSNumber)) {
            newFilterOption.average = [filterOptionJSON objectForKey:@"average"];
        }
        if (VALID_NOTEMPTY([filterOptionJSON objectForKey:@"total_products"], NSNumber)) {
            newFilterOption.totalProducts = [filterOptionJSON objectForKey:@"total_products"];
        }
    }
    
    //initial state
    newFilterOption.selected = NO;
    newFilterOption.lowerValue = newFilterOption.min;
    newFilterOption.upperValue = newFilterOption.max;
    newFilterOption.discountOnly = NO;
    
    return newFilterOption;
}

- (RIFilterOption*)copy
{
    RIFilterOption* newFilterOption = [[RIFilterOption alloc] init];
    newFilterOption.name = [self.name copy];
    newFilterOption.val = [self.val copy];
    newFilterOption.max = self.max;
    newFilterOption.min = self.min;
    newFilterOption.interval = self.interval;
    newFilterOption.colorHexValue = [self.colorHexValue copy];
    newFilterOption.colorImageUrl = [self.colorImageUrl copy];
    newFilterOption.average = [self.average copy];
    newFilterOption.totalProducts = [self.totalProducts copy];
    newFilterOption.selected = self.selected;
    newFilterOption.lowerValue = self.lowerValue;
    newFilterOption.upperValue = self.upperValue;
    newFilterOption.discountOnly = self.discountOnly;

    return newFilterOption;
}

@end

@implementation RIFilter

+ (NSString *)urlWithFiltersArray:(NSArray*)filtersArray {
    NSString* urlString = @"";
    for (RIFilter* filter in filtersArray) {
        NSString* stringForFilter = [RIFilter urlWithFilter:filter];
        if (stringForFilter.length) {
            urlString = [NSString stringWithFormat:@"%@/%@", urlString, stringForFilter];
        }
    }
    return urlString;
}

+ (NSString *)urlWithFilter:(RIFilter*)filter {
    NSString* urlString = nil;
    
    if (filter.uid.length && filter.options.count > 0) {
        
        if ([filter.uid isEqualToString:@"price"]) {
            RIFilterOption* filterOption = [filter.options firstObject];
            if (filterOption) {
                if (filterOption.lowerValue != filterOption.min || filterOption.upperValue != filterOption.max) {
                    urlString = [NSString stringWithFormat:@"price/%ld%@%ld", (long)filterOption.lowerValue, filter.filterSeparator, (long)filterOption.upperValue];
                }
                if (filterOption.discountOnly) {
                    if (urlString.length) {
                        urlString = [NSString stringWithFormat:@"%@/special_price/1", urlString];
                    } else {
                        urlString = @"special_price/1";
                    }
                }
            }
        } else {
            for (RIFilterOption* filterOption in filter.options) {
                
                if (filterOption.selected) {
                    
                    //filterOption.val = [filterOption.val stringByReplacingOccurrencesOfString:@"&" withString:@"%26"];
                    //filterOption.val = [filterOption.val stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
                    
                    if (!urlString) {
                        NSString* filterUidString = filter.uid;
                        urlString = [NSString stringWithFormat:@"%@/%@", filterUidString, filterOption.val];
                    } else {
                        urlString = [NSString stringWithFormat:@"%@%@%@", urlString, filter.filterSeparator, filterOption.val];
                    }
                }
            }
        }
    }
    
    return urlString;
}

+ (NSArray *)parseFilters:(NSArray *)filtersJSON {
    NSMutableArray* newFiltersArray = [NSMutableArray new];
    
    if (VALID_NOTEMPTY(filtersJSON, NSArray)) {
        
        for (NSDictionary* filterJSON in filtersJSON) {
        
            if (VALID_NOTEMPTY(filterJSON, NSDictionary)) {
                RIFilter* newFilter = [RIFilter parseFilter:filterJSON];
                
                if (VALID_NOTEMPTY(newFilter, RIFilter)) {
                    if ([newFilter.uid isEqualToString:@"category"]) {
                        //do nothing
                    } else {
                        [newFiltersArray addObject:newFilter];    
                    }
                }
            }
        }
    }
    
    return [newFiltersArray copy];
}


+ (RIFilter *)parseFilter:(NSDictionary *)filterJSON {
    RIFilter* newFilter = [[RIFilter alloc] init];
    
    if (filterJSON) {
        if ([filterJSON objectForKey:@"id"]) {
            newFilter.uid = [filterJSON objectForKey:@"id"];
        }
        if ([filterJSON objectForKey:@"name"]) {
            newFilter.name = [filterJSON objectForKey:@"name"];
        }
        if ([filterJSON objectForKey:@"filter_separator"]) {
            newFilter.filterSeparator = [filterJSON objectForKey:@"filter_separator"];
        }
        if ([[newFilter.name uppercaseString] isEqualToString:[@"category" uppercaseString]]) {
            return nil;
        }
        
        if ([filterJSON objectForKey:@"multi"]) {
            NSNumber* multi = [filterJSON objectForKey:@"multi"];
            newFilter.multi = [multi boolValue];
        }
        
        id options = [filterJSON objectForKey:@"option"];
        
        if (VALID_NOTEMPTY(options, NSArray)) {
            
            NSMutableArray* newFilterOptionsArray = [NSMutableArray new];
            for (NSDictionary* filterOptionJSON in options) {
                RIFilterOption* newFilterOption = [RIFilterOption parseFilterOption:filterOptionJSON];
                
                [newFilterOptionsArray addObject:newFilterOption];
            }
            newFilter.options = [newFilterOptionsArray copy];
            
        } else if (VALID_NOTEMPTY(options, NSDictionary)) {
            
            NSMutableArray* newFilterOptionsArray = [NSMutableArray new];
            RIFilterOption* newFilterOption = [RIFilterOption parseFilterOption:options];
            [newFilterOptionsArray addObject:newFilterOption];
            newFilter.options = [newFilterOptionsArray copy];
        }
    }
    
    return newFilter;
}

+ (NSArray*)copyFiltersArray:(NSArray*)filtersArray {
    NSMutableArray* newFiltersArray = [NSMutableArray new];
    for (RIFilter* filter in filtersArray) {
        [newFiltersArray addObject:filter];
    }
    return [newFiltersArray copy];
}

//- (RIFilter*)copy {
//    RIFilter* newFilter = [[RIFilter alloc] init];
//    
//    newFilter.uid = [self.uid copy];
//    newFilter.name = [self.name copy];
//    newFilter.multi = self.multi;
//    newFilter.filterSeparator = [self.filterSeparator copy];
//    NSMutableArray* newOptions = [NSMutableArray new];
//    for (RIFilterOption* option in self.options) {
//        RIFilterOption* newOption = [option copy];
//        [newOptions addObject:newOption];
//    }
//    newFilter.options = [newOptions copy];
//    
//    return newFilter;
//}

@end
