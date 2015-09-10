//
//  RIFilter.m
//  Jumia
//
//  Created by Telmo Pinto on 12/08/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "RIFilter.h"

@implementation RIFilterOption

+ (RIFilterOption *)parseFilterOption:(NSDictionary *)filterOptionJSON;
{
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
    }
    
    //initial state
    newFilterOption.selected = NO;
    newFilterOption.lowerValue = newFilterOption.min;
    newFilterOption.upperValue = newFilterOption.max;
    newFilterOption.discountOnly = NO;
    
    return newFilterOption;
}

@end

@implementation RIFilter

+ (NSString *)urlWithFiltersArray:(NSArray*)filtersArray
{
    NSString* urlString = nil;
    if (VALID_NOTEMPTY(filtersArray, NSArray)) {
        for (RIFilter* filter in filtersArray) {
            if (VALID_NOTEMPTY(filter, RIFilter)) {
                
                NSString* stringForFilter = [RIFilter urlWithFilter:filter];
                
                if (NOTEMPTY(stringForFilter)) {
                    
                    if (ISEMPTY(urlString)) {
                        urlString = stringForFilter;
                    } else {
                        urlString = [NSString stringWithFormat:@"%@&%@", urlString, stringForFilter];
                    }
                }
            }
        }
    }
    return urlString;
}

+ (NSString *)urlWithFilter:(RIFilter*)filter
{
    NSString* urlString = nil;
    
    if (VALID_NOTEMPTY(filter.uid, NSString) && VALID_NOTEMPTY(filter.options, NSArray) && 0 < filter.options.count) {
        
        if ([filter.uid isEqualToString:@"price"]) {
            RIFilterOption* filterOption = [filter.options firstObject];
            if (VALID_NOTEMPTY(filterOption, RIFilterOption)) {
                
                if (filterOption.lowerValue != filterOption.min || filterOption.upperValue != filterOption.max) {
                    urlString = [NSString stringWithFormat:@"price=%ld-%ld", (long)filterOption.lowerValue, (long)filterOption.upperValue];
                }
            }
        } else {
            NSString *brands = [NSString new];
            for (RIFilterOption* filterOption in filter.options) {
                
                if (filterOption.selected) {
                    
                    filterOption.val = [filterOption.val stringByReplacingOccurrencesOfString:@"&" withString:@"%26"];
                    filterOption.val = [filterOption.val stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
                    
                    if ([filter.uid isEqualToString:@"brand"]) {
                        if (!VALID_NOTEMPTY(brands, NSString)) {
                            brands = [NSString stringWithFormat:@"&q=%@", filterOption.val];
                        }else{
                            brands = [NSString stringWithFormat:@"%@--%@", brands, filterOption.val];
                        }
                    }
                    if (ISEMPTY(urlString)) {
                        NSString* filterUidString = filter.uid;
                        urlString = [NSString stringWithFormat:@"%@=%@", filterUidString, filterOption.val];
                    } else {
                        urlString = [NSString stringWithFormat:@"%@--%@", urlString, filterOption.val];
                    }
                }
            }
            
            if (VALID_NOTEMPTY(brands, NSString)) {
                urlString = [NSString stringWithFormat:@"%@%@", urlString, brands];
            }
            
        }
    }
    
    return urlString;
}

+ (NSArray *)parseFilters:(NSArray *)filtersJSON;
{
    NSMutableArray* newFiltersArray = [NSMutableArray new];
    
    if (VALID_NOTEMPTY(filtersJSON, NSArray)) {
        
        for (NSDictionary* filterJSON in filtersJSON) {
        
            if (VALID_NOTEMPTY(filterJSON, NSDictionary)) {
                RIFilter* newFilter = [RIFilter parseFilter:filterJSON];
                
                [newFiltersArray addObject:newFilter];
            }
        }
    }
    
    return [newFiltersArray copy];
}


+ (RIFilter *)parseFilter:(NSDictionary *)filterJSON;
{
    RIFilter* newFilter = [[RIFilter alloc] init];
    
    if (VALID_NOTEMPTY(filterJSON, NSDictionary)) {
        if ([filterJSON objectForKey:@"id"]) {
            newFilter.uid = [filterJSON objectForKey:@"id"];
        }
        if ([filterJSON objectForKey:@"name"]) {
            newFilter.name = [filterJSON objectForKey:@"name"];
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

@end
