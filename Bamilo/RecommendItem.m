//
//  RecommendItem.m
//  Bamilo
//
//  Created by Ali Saeedifar on 4/10/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "RecommendItem.h"

@implementation RecommendItem

+ (JSONKeyMapper *)keyMapper {
    return [[JSONKeyMapper alloc] initWithModelToJSONDictionary:@{
                                                                  @"sku": @"item",
                                                                  @"brandName": @"brand",
                                                                  @"categoryPath": @"category",
                                                                  @"link": @"link",
                                                                  @"imageUrl": @"image",
                                                                  @"price": @"price",
                                                                  @"dicountedPrice":@"msrp",
                                                                  @"name":@"title"
                                                                  }];
}

- (NSString *)formattedPrice {
    return [self.price formatPriceWithCurrency];
}

- (NSString *)formattedDiscountedPrice {
    return [self.dicountedPrice formatPriceWithCurrency];
}

+ (RecommendItem *)instanceWithEMRecommendationItem:(EMRecommendationItem *)item {
    NSError *error;
    RecommendItem *instance = [[RecommendItem alloc] init];
    [instance mergeFromDictionary:item.data useKeyMapping:YES error:&error];
    return instance;
}

@end
