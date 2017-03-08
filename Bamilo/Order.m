//
//  Order.m
//  Bamilo
//
//  Created by Ali saiedifar on 2/28/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "Order.h"

@implementation Order
#pragma mark - JSONModel
+ (JSONKeyMapper *)keyMapper {
    return [[JSONKeyMapper alloc] initWithModelToJSONDictionary:@{
          @"orderId":@"number",
          @"creationDate":@"date",
          @"price":@"total",
          @"formattedPrice":@"total",
          @"shippingAddress": @"shipping_address",
          @"billingAddress":@"billing_address",
          @"products":@"products",
          @"paymentReference":@"payment.transaction_reference",
          @"paymentDescription":@"payment.transaction_description",
          @"paymentMethod":@"payment.title"
    }];
}


- (NSString *)formattedPrice {
    if (self.price) {
        return [NSString stringWithFormat:@"%@ %@", [[self.price formatPrice] numbersToPersian], STRING_CURRENCY];
    }
    return nil;
}

- (BOOL)mergeFromDictionary:(NSDictionary *)dict useKeyMapping:(BOOL)useKeyMapping error:(NSError *__autoreleasing *)error {
    [super mergeFromDictionary:dict useKeyMapping:useKeyMapping error:error];
    
    
    
    [self.products enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
       [obj mergeFromDictionary:[dict objectForKey:@"products"][idx] useKeyMapping:YES error:nil];
    }];
    
    if ([dict objectForKey:@"order_number"]) {
        self.orderId = [dict objectForKey:@"order_number"];
    }
    if ([dict objectForKey:@"creation_date"] || [dict objectForKey:@"date"]) {
        NSString *dateString = [dict objectForKey:@"creation_date"] ?: [dict objectForKey:@"date"];
        NSDateFormatter *df = [NSDateFormatter new];
        [df setDateFormat: [dict objectForKey:@"creation_date"] ? @"yyyy-MM-dd HH:mm:ss" : @"yyyy-MM-dd"];
        self.creationDate = [df dateFromString:dateString];
    }
    if ([dict objectForKey:@"grand_total"]) {
        self.price = [dict objectForKey:@"grand_total"];
    }
    
    if ([dict objectForKey:@"payment"]) {
        if ([[dict objectForKey:@"payment"] objectForKey:@"label"]) {
            self.paymentMethod = [[dict objectForKey:@"payment"] objectForKey:@"label"];
        }
        if ([[dict objectForKey:@"payment"] objectForKey:@"txnref"]) {
            self.paymentReference = [[dict objectForKey:@"payment"] objectForKey:@"txnref"];
        }
        if ([[dict objectForKey:@"payment"] objectForKey:@"status_description"]) {
            self.paymentDescription = [[dict objectForKey:@"payment"] objectForKey:@"status_description"];
        }
    }
    
    return YES;
}

@end
