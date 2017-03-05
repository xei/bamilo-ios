//
//  SearchFilterItemOption.m
//  Bamilo
//
//  Created by Ali saiedifar on 3/4/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "SearchFilterItemOption.h"

@implementation SearchFilterItemOption
+ (JSONKeyMapper *)keyMapper {
    return [[JSONKeyMapper alloc] initWithModelToJSONDictionary:@{
      @"name": @"label",
      @"value":@"val",
      @"colorHexValue":@"hex_value",
      @"colorImageUrl":@"image_url",
      @"average":@"average",
      @"productsCount":@"total_products"
  }];
}
@end
