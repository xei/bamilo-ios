//
//  SearchFilterItem.m
//  Bamilo
//
//  Created by Ali Saeedifar on 3/4/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "SearchFilterItem.h"

@implementation SearchFilterItem
+ (JSONKeyMapper *)keyMapper {
    return [[JSONKeyMapper alloc] initWithModelToJSONDictionary:@{
          @"uid": @"id",
          @"name": @"name",
          @"multi": @"multi",
          @"options": @"option",
          @"filterSeparator": @"filter_separator"
    }];
}
@end
