//
//  OrderList.m
//  Bamilo
//
//  Created by Ali saiedifar on 2/28/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "OrderList.h"

@implementation OrderList
+ (JSONKeyMapper *)keyMapper {
    return [[JSONKeyMapper alloc] initWithModelToJSONDictionary:@{
                                                                  @"orders":@"orders",
                                                                  @"totalOrdersCount": @"total_orders"
                                                                  }];
}

- (BOOL)mergeFromDictionary:(NSDictionary *)dict useKeyMapping:(BOOL)useKeyMapping error:(NSError *__autoreleasing *)error {
    [super mergeFromDictionary:dict useKeyMapping:useKeyMapping error:error];
    [self.orders enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj mergeFromDictionary:[dict objectForKey:@"orders"][idx] useKeyMapping:YES error:nil];
    }];
    return YES;
}
@end
