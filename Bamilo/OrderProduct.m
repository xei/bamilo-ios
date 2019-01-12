//
//  OrderProduct.m
//  Bamilo
//
//  Created by Ali Saeedifar on 2/28/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "OrderProduct.h"

@implementation OrderStatus
@end

@implementation OrderReturn
@end


@implementation OrderProductAction
@end


@implementation OrderProductOnlineReturnAction
@end

@implementation OrderProductCallReturnAction
@end


@implementation OrderProduct

+ (JSONKeyMapper *)keyMapper {
    return [[JSONKeyMapper alloc] initWithModelToJSONDictionary:@{
          @"sku": @"sku",
          @"brand": @"brand",
          @"name": @"name",
          @"size": @"size",
          @"imageURL": @"image",
          @"delivery": @"delivery",
          @"status":@"status",
          @"returns":@"returns",
          @"price":@"price",
          @"formatedPrice": @"price",
          @"quantity":@"quantity",
          @"actions":@"actions",
          @"caculatedDeliveryTime":@"calculated_delivery_time"
          }];
}

-(BOOL)mergeFromDictionary:(NSDictionary *)dict useKeyMapping:(BOOL)useKeyMapping error:(NSError *__autoreleasing *)error {
    [super mergeFromDictionary:dict useKeyMapping:useKeyMapping error:error];
    
    if (self.price) {
        NSString *priceString = [NSString stringWithFormat:@"%lld", self.price];
        self.formatedPrice = [priceString formatPriceWithCurrency];
    }
    
    if (VALID_NOTEMPTY([dict objectForKey:@"actions"], NSArray)) {
    
        [self.actions removeAllObjects];
        
        NSArray *actionsArray = [dict objectForKey:@"actions"];
        for (NSDictionary *actionObj in actionsArray) {
            NSString *actionType = [actionObj objectForKey:@"type"];
            
            NSString *onlineReturnTarget = [actionObj objectForKey:@"target"];
            if ([actionType isEqualToString:@"online_return"] && onlineReturnTarget.length) {
                
                OrderProductOnlineReturnAction *action = [OrderProductOnlineReturnAction new];
                action.targetString = [actionObj objectForKey:@"target"];
                action.returnableQty = [actionObj objectForKey:@"returnable_quantity"];
                [self.actions addObject:action];
                
            } else if([actionType isEqualToString:@"call_return"]) {
                OrderProductCallReturnAction *action = [OrderProductCallReturnAction new];
                action.callReturnTextTitle = [actionObj objectForKey:@"text_title"];
                action.callReturnTextBody1 = [actionObj objectForKey:@"text_body1"];
                action.callReturnTextBody2 = [actionObj objectForKey:@"text_body2"];
                action.returnableQty = [actionObj objectForKey:@"returnable_quantity"];
                [self.actions addObject:action];
            }
        }
    }
    
    return YES;
}

@end
